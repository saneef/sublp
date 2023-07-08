#lang racket

(require rackunit
         "./file.rkt"
         "./json.rkt")

(provide (struct-out project)
         create-project
         find-project-by-path)

(struct project (file directories) #:prefab)

(define (get-folders-from-sb-project jse)
  (let* ([folders (hash-ref jse 'folders '())]
         [possible-paths (map (lambda (f) (hash-ref f 'path #f)) folders)]
         [paths (filter string? possible-paths)])
    (map build-absolute-directory-path paths)))
(module+ test
  (check-equal? (get-folders-from-sb-project '#hasheq((folders . (#hasheq((path . "~/tmp/sublp"))))))
                (list (build-absolute-directory-path "~/tmp/sublp"))))

(define (create-project p)
  (let* ([content (file->string p)]
         [path (build-absolute-path p)]
         [jse (parse-json content)]
         [directories (get-folders-from-sb-project jse)])
    (project path directories)))

(module+ test
  (check-equal? (create-project "../fixtures/test.sublime-project")
                (project (build-absolute-path "../fixtures/test.sublime-project")
                         (list (build-absolute-directory-path "~/tmp/sublp")))))

(define (project-include-folder? p f)
  (let* ([path (build-absolute-directory-path f)]
         [folders (project-directories p)]
         [r (filter (lambda (p) (equal-path? p path)) folders)])
    (not (empty? r))))

(module+ test
  (check-equal? (project-include-folder? (create-project "../fixtures/test.sublime-project")
                                         "~/tmp/sublp")
                #t)
  (check-equal? (project-include-folder? (create-project "../fixtures/another-test.sublime-project")
                                         "~/tmp/sublp")
                #f))

(define (find-project-by-path lst path)
  (let ([r (filter (lambda (p) (project-include-folder? p path)) lst)]) (if (empty? r) #f (first r))))
(module+ test
  (check-equal? (find-project-by-path
                 (list (create-project "../fixtures/another-test.sublime-project")
                       (create-project "../fixtures/test.sublime-project"))
                 "~/tmp/sublp")
                (create-project "../fixtures/test.sublime-project"))
  (check-equal?
   (find-project-by-path (list (create-project "../fixtures/another-test.sublime-project")
                               (create-project "../fixtures/test.sublime-project"))
                         "~/non-existent-path")
   #f))
