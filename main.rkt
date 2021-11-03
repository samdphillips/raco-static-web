#lang racket/base

(require (for-syntax racket/base)
         net/url
         racket/path
         racket/runtime-path
         (prefix-in log: web-server/dispatchers/dispatch-log)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         (prefix-in static-files: web-server/dispatchers/dispatch-files)
         (prefix-in lift: web-server/dispatchers/dispatch-lift)
         web-server/configuration/responders
         web-server/dispatchers/dispatch
         web-server/dispatchers/filesystem-map
         web-server/http/request-structs
         web-server/http/xexpr
         web-server/web-server)

(define-runtime-path web-server-collection '(lib "web-server"))

(define (relative-path-url-to-root p)
  (define simple-path (simplify-path p))
  (define rel-path (find-relative-path (current-directory) simple-path))
  (cond
    [(equal? simple-path rel-path) (url #f #f #f #f #t null null #f)]
    [else
      (define pp
        (for/list ([d (in-list (explode-path rel-path))])
          (path/param (path->string d) null)))
      (url #f #f #f #f #t pp null #f)]))

(define (make-file-link path)
  (define basename
    (path->string
      (file-name-from-path path)))
  (define rel-to-pwd
    (find-relative-path (current-directory) path))
  `(li (a ([href ,rel-to-pwd]) ,basename)))

(define (files-list path)
  (for/list ([f (directory-list path #:build? #t)])
    (define name (path->string (file-name-from-path f)))
    (define u (relative-path-url-to-root f))
    `(li (a ([href ,(url->string u)]) ,name))))

(define (directory-lister:make #:url->path url->path)
  (lift:make
    (lambda (req)
      (define-values (path pieces) (url->path (request-uri req)))
      (unless (directory-exists? path)
        (next-dispatcher))
      (response/xexpr
        `(html
           (body
             (h1 ,(url->string (request-uri req)))
             ,@(files-list path)))))))

(module* main #f
  (define url->path
    (make-url->path (current-directory)))

  (void
    (serve #:port 8000
           #:dispatch
           (sequencer:make
             (log:make #:format
                       (log:log-format->format 'apache-default)
                       #:log-path (current-output-port))
             (static-files:make #:url->path url->path)
             (directory-lister:make #:url->path url->path)
             (lift:make
               (gen-file-not-found-responder
                 (simplify-path
                   (build-path web-server-collection 'up
                               "default-web-root" "conf"
                               "not-found.html")))))))

  (with-handlers ([exn:break? void]) (do-not-return)))

