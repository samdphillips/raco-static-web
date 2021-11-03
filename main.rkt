#lang racket/base

(require net/url
         racket/cmdline
         racket/format
         racket/path
         raco/command-name
         (prefix-in log: web-server/dispatchers/dispatch-log)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         (prefix-in static-files: web-server/dispatchers/dispatch-files)
         (prefix-in lift: web-server/dispatchers/dispatch-lift)
         web-server/dispatchers/dispatch
         web-server/dispatchers/filesystem-map
         web-server/http/request-structs
         web-server/http/response-structs
         web-server/http/xexpr
         web-server/web-server)

(define file-icon
  (~a "data:image/png;base64,"
      "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IAr"
      "s4c6QAAAJRJREFUSEvtldsRQDAQRU9KUgGlUBml0IGOGDMYr82NWf7ie5"
      "2zuUk2gZ+/8DOfFEENtC8aGYFiq1eCt/AbNyZ4gquGptWw11k/HOHNIaJ"
      "PBFd4B9w6M/ZEruAJvrA+E2wg69C4I4oJBqASx1VGlBqF5ckCOTByRDmi"
      "9JnjvmgybFFgvgc9UDrpp5mlpqPTRdKj75LMzaksGaIVe9kAAAAASUVOR"
      "K5CYII="))

(define folder-icon
  (~a "data:image/png;base64,"
      "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IAr"
      "s4c6QAAAH5JREFUSEvtlcsNgDAMQ18nAzaHDRiFDUBFAvGpiKOqnNJz6h"
      "c7VZpofFJjfX4FjED34WgGBmDxuL46WIWLbogXIPSwl+Q0stvbDBQHKuD"
      "ULjmoHfzR6K4TgNJMIiLzpUZEEZGZgFzw2kXWhyMrAxPQP5edR0CurV3N"
      "Jqg5YAORiSQZT6N44AAAAABJRU5ErkJggg=="))

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

(define (files-list path)
  (for/list ([f (directory-list path #:build? #t)])
    (define name (path->string (file-name-from-path f)))
    (define u (relative-path-url-to-root f))
    (define icon
      (if (directory-exists? f) folder-icon file-icon))
    `(li (a ([href ,(url->string u)])
            (img ([src ,icon]
                  [style "vertical-align: middle"]) "")
            (span ,name)))))

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
         (ul ,@(files-list path))))))))

(define (not-found req)
  (response/full 404 #"Not Found" (current-seconds) #f null null))

(module* main #f
  (define BASE (current-directory))
  (define PORT 8000)
  (command-line
   #:program (short-program+command-name)
   #:once-each
   [("-p" "--port") port [(format "Port to listen on (default: ~s)" PORT)]
    (let ([portn (string->number port)])
      (unless (exact-positive-integer? portn)
        (raise-user-error
         (format "~a: bad port number: ~e" (short-program+command-name) port)))
      (set! PORT portn))]
   [("-d" "--dir") dir "Base directory (default: current directory)"
    (set! BASE (string->path dir))]
   #:args ()
   (void))

  (define shutdown-server
    (parameterize ([current-directory BASE])
      (define url->path
        (make-url->path (current-directory)))
      (serve #:port PORT
             #:dispatch
             (sequencer:make
              (log:make #:format
                        (log:log-format->format 'apache-default)
                        #:log-path (current-output-port))
              (static-files:make #:url->path url->path)
              (directory-lister:make #:url->path url->path)
              (lift:make not-found)))))

  (displayln (~a "Now serving " BASE " from http://localhost:" PORT))

  (with-handlers ([exn:break? void]) (do-not-return))
  (shutdown-server))

