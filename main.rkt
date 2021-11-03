#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         racket/path
         racket/string
         racket/list)

(define servlet-path "/static-files")
(define segments-to-drop (length (string-split servlet-path "/")))

(define (files-list path)
  (define files (directory-list path #:build? #t))
  (define links
    (map (λ (path)
           (let* ([basename (file-name-from-path path)]
                  [basename-text (path->string basename)]
                  [rel-to-pwd (find-relative-path (current-directory) path)]
                  [dir-link (path->string (build-path servlet-path rel-to-pwd))]
                  [file-link (string-append "/" (path->string rel-to-pwd))])
             `(li (a ([href ,(if (directory-exists? path) dir-link file-link)])
                     ,basename-text))))
         files))
  `(ul ,@links))

(serve/servlet
  (λ (req)
    (define path-segments
      (map path/param-path
           (drop (url-path (request-uri req)) segments-to-drop)))
    (define file-or-dir (apply build-path (current-directory) path-segments))
    (if (directory-exists? file-or-dir)
      (response/xexpr
        `(html (body
                 (h1 ,(path->string file-or-dir))
                 ,(files-list file-or-dir))))
      (response/xexpr
        #:code 404
        `(html (body
                 (h1 ,(path->string file-or-dir) " Not found"))))))
  #:extra-files-paths (list (current-directory))
  #:servlet-path servlet-path
  #:servlet-regexp (regexp (format "^~a" (regexp-quote servlet-path)))
  #:servlet-current-directory (current-directory))
