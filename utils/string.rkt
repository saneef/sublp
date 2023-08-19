#lang racket/base

(require rackunit
         racket/string)

(provide quote-string)

(define (quote-string str)
  (string-join (list "\"" str "\"") ""))

(module+ test
  (check-equal? (quote-string "a") "\"a\""))
