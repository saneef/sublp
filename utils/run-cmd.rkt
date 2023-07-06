#lang racket

(require rackunit)

(define (do-run-cmd cmd in . args)
  ; (printf "~a ~a ~a" cmd in args)
  (let* ([cmd-path (find-executable-path cmd)]
         [src-temp (make-temporary-file)]
         [dest-temp (make-temporary-file)]
         [stdin (open-input-file src-temp)]
         [stdout (open-output-file dest-temp #:exists 'truncate)])
    (display-to-file in src-temp #:mode 'text #:exists 'truncate)
    (define-values (sp sp-out sp-in sp-err) (subprocess stdout stdin #f cmd-path))
    (define err (port->string sp-err))
    (close-input-port stdin)
    (close-output-port stdout)
    (close-input-port sp-err)
    (subprocess-wait sp)
    (cond
      [(= 0 (subprocess-status sp)) (file->string dest-temp)]
      [else (raise-user-error err)])))

; String/Path String . [String] -> String
; Runs a command with provided 'in' piped as stdin and
; returns the result from stdout as String
(define (run-cmd cmd in . args)
  (cond
    [(nor (path? cmd) (string? cmd)) (raise-argument-error 'cmd "(or (path? cmd) (string? cmd))" cmd)]
    [(nor (false? in) (string? in)) (raise-argument-error 'in "(or (false? in) (string? in))" in)]
    [else (apply do-run-cmd cmd in args)]))

(module+ test
  (check-exn exn:fail:contract? (thunk (run-cmd #f #f)))
  (check-exn exn:fail:contract? (thunk (run-cmd "ls" #t)))
  (check-exn exn:fail:contract? (thunk (run-cmd "non-existent-command" #f)))
  (check-exn exn:fail:user? (thunk (run-cmd "grep" #f "-t")))
  (check-equal? (run-cmd (find-executable-path "cat") "hello") "hello"))

(provide run-cmd)
