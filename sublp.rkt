#!/usr/bin/env racket

#lang racket/base

(require rackunit
         racket/bool
         racket/cmdline
         racket/list
         racket/system
         racket/string
         file/glob
         "./utils/file.rkt"
         "./utils/project.rkt")

; Void -> [Listof String]
; Returns all the paths to set in env SUBLP_PATH
(define (get-project-directories)
  (let ([env (getenv "SUBLP_PATH")])
    (unless env
      (raise "SUBLP_PATH environment variable is not set."))
    (string-split env ":")))

(define (get-project-file-paths lst)
  (let ([paths (map (lambda (p) (glob (build-path p "*.sublime-project"))) lst)]) (flatten paths)))

(define verbose-mode (make-parameter #f))
(define path-to-open
  (command-line
   #:program "sublp"
   #:once-each [("-v" "--verbose") "Print extra debugging information." (verbose-mode #t)]
   #:args args
   (cond
     [(empty? args) (path->string (current-directory))]
     [else (last args)])))

(define (get-project path)
  (let* ([dirlst (get-project-directories)]
         [pathlst (get-project-file-paths dirlst)]
         [plst (map create-project pathlst)]
         [p (find-project-by-path plst path-to-open)])
    (when (verbose-mode)
      (printf "Paths to search for Sublime Text project files: \n\t~a\n" (string-join dirlst "\n\t"))
      (printf "Project files:\n\t~a\n" (string-join (map path->string pathlst) "\n\t")))
    p))

(define (open-file-with-subl path)
  (when (verbose-mode)
    (printf "Opening file: ~a\n" path))
  (system (string-join (list "subl" "--launch-or-new-window" path))))

(define (open-project-with-subl path)
  (let ([path-str (path->string path)])
    (when (verbose-mode)
      (printf "Opening project: ~a\n" path-str))
    (system (string-join (list "subl" "--launch-or-new-window" "--project" path-str)))))

(module* main #f
  (when (verbose-mode)
    (printf "Debug messages: ON\n"))
  (let* ([expanded-path (build-absolute-directory-path path-to-open)]
         [project (get-project expanded-path)]
         [status (if (false? project)
                     (open-file-with-subl path-to-open)
                     (open-project-with-subl (project-file project)))])
    (when (verbose-mode)
      (printf "Running 'subl' succeeded: ~a\n" status))))
