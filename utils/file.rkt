#lang racket/base

(require rackunit)

(provide build-absolute-path
         build-absolute-directory-path
         equal-path?)

(define (build-absolute-path p)
  (simplify-path (path->complete-path (expand-user-path p))))

(define (build-absolute-directory-path p)
  (simplify-path (path->directory-path (expand-user-path p))))

; (or String Path) (or String Path) -> Boolean
; Checks if two paths are equal. Works with user path and trailing slash paths
(define (equal-path? p1 p2)
  (let ([v1 (build-absolute-directory-path p1)] [v2 (build-absolute-directory-path p2)])
    (equal? v1 v2)))

(module+ test
  (check-true (equal-path? "/root" "/root"))
  (check-true (equal-path? (build-path "/root") (build-path "/root")))
  (check-true (equal-path? "/root" "/root/")))
