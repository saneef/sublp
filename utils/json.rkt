#lang racket

(require rackunit
         json
         "./run-cmd.rkt")

(provide sanitize-json
         parse-json)

; String -> String
; Sanitizes JSON using Terser (https://terser.org) minifier.
; Primarily meant to remove comments and
; fix JS Object syntax from JSON strings
(define (sanitize-json str)
  (let* ([js (~a "module.exports=" str ";")]
         [minified-js (run-cmd "terser" js "--format" "comments=0" "--format" "quote_keys=1")]
         [minified-json-match (regexp-match #rx"module.exports=(.*);" minified-js)])
    (cond
      [(list? minified-json-match) (car (cdr minified-json-match))]
      [else str])))

(module+ test
  (define sample-json #<<--
{
  "a-proper-key" : null,
  "another_key": [1,2,3],
}
--
    )

  (define sample-json-with-comments
    #<<--
{
  // A comment
  "a-proper-key" : null,
  another_key: [1,2,3],
  /* error-key: 0 */
}
--
    )

  (define sample-sanitized-json "{\"a-proper-key\":null,\"another_key\":[1,2,3]}")

  (check-equal? (sanitize-json "[ ]") "[]")
  (check-equal? (sanitize-json "[ /* a comment */ ]") "[]")
  (check-equal? (sanitize-json "[\n// a comment \n]") "[]")
  (check-equal? (sanitize-json sample-json) sample-sanitized-json)
  (check-equal? (sanitize-json sample-json-with-comments) sample-sanitized-json))

; String -> jsexpr
; Parse given JSON string, str, to jsexpr.
; Sanitizes the str if needed.
(define (parse-json str)
  (let ([parse (lambda (s) (string->jsexpr s #:null #f))])
    (with-handlers ([exn:fail:read? (lambda (e) (parse (sanitize-json str)))]) (parse str))))

(module+ test
  (check-equal? (parse-json "{\"a-proper-key\":null,a_improper_key:0}")
                '#hasheq((a-proper-key . #f) (a_improper_key . 0)))
  (check-equal? (parse-json "{\n//A Comment\n\"a-proper-key\":null,a_improper_key:0}")
                '#hasheq((a-proper-key . #f) (a_improper_key . 0)))
  (check-equal? (parse-json "[]") '())
  (check-equal? (parse-json "null") #f))
