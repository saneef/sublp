#!/usr/bin/env racket

#lang racket

(require rackunit
         racket/cmdline
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
     [(empty? args) (current-directory)]
     [else (last args)])))

(define (find-project path)
  (let* ([dirs (get-project-directories)]
         [pfiles (get-project-file-paths dirs)]
         [data (map create-project pfiles)]
         [project (find-project-by-path data path-to-open)])
    project))

(define (open-file path)
  (when (verbose-mode)
    (printf "Opening file: ~a\n" path))
  (system (string-join (list "subl" "--launch-or-new-window" path))))

(define (open-project path)
  (let ([path-str (path->string path)])
    (when (verbose-mode)
      (printf "Opening project: ~a\n" path-str))
    (system (string-join (list "subl" "--launch-or-new-window" "--project" path-str)))))

(module* main #f
  (when (verbose-mode)
    (printf "Debug messages: ON\n"))
  (let* ([expanded-path (build-absolute-directory-path path-to-open)]
         [project (find-project expanded-path)])
    (if (false? project) (open-file path-to-open) (open-project (project-file project)))))