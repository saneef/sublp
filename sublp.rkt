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
         "./utils/project.rkt"
         "./utils/string.rkt")

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
  (command-line #:program "sublp"
                #:once-each
                [("-v" "--verbose") "Print extra debugging information." (verbose-mode #t)]
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

(define (open-with-subl path [project? #f])
  (let* ([path-str (if (path? path) (path->string path) path)]
         [quoted-path-str (quote-string path-str)]
         [base-command "subl --launch-or-new-window"]
         [params (if project? "--project" "")]
         [command (string-join (list base-command params quoted-path-str))])
    (when (verbose-mode)
      (printf "Opening: ~a\n" path-str))
    (system command)))

(module* main #f
  (when (verbose-mode)
    (printf "Debug messages: ON\n"))
  (let* ([expanded-path (build-absolute-directory-path path-to-open)]
         [project (get-project expanded-path)]
         [project? (not (false? project))]
         [status
          (if project? (open-with-subl (project-file project) #t) (open-with-subl path-to-open))])
    (when (verbose-mode)
      (printf "Running 'subl' succeeded: ~a\n" status))))
