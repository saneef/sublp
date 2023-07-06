#lang racket

(require rackunit)
(require "./run-cmd.rkt")

; String -> String
; Sanitizes JSON using Terser (https://terser.org) minifier.
; Primarily meant to remove comments and
; fix JS Object syntax from JSON strings
(define (sanitize-json str)
  (let* ([js (~a "module.exports=" str ";")]
         [minified-js (run-cmd "terser" js)]
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

  (define sample-sanitized-json "{\"a-proper-key\":null,another_key:[1,2,3]}")

  (check-equal? (sanitize-json "[ ]") "[]")
  (check-equal? (sanitize-json "[ /* a comment */ ]") "[]")
  (check-equal? (sanitize-json "[\n// a comment \n]") "[]")
  (check-equal? (sanitize-json sample-json) sample-sanitized-json)
  (check-equal? (sanitize-json sample-json-with-comments) sample-sanitized-json))

(provide sanitize-json)
