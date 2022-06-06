#lang racket/base

(require net/mime-type
         net/url
         racket/cmdline
         racket/exn
         racket/file
         racket/format
         racket/match
         racket/path
         racket/runtime-path
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

(define-runtime-path favicon-path "favicon.png")

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

(define folder-up-icon
  (~a "data:image/png;base64,"
      "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IAr"
      "s4c6QAAALZJREFUSEvtldsNgzAMRQ8bdBNGKN2kTNaO0m7AKGxA5YhIQc"
      "3DJqXwAd+Xe3xty2nY+Gs29uevgBdwzSQagBswWlKHCSbFj2ZIDBBr2wW"
      "QhK2iCJGIVtIuZuATpOZihTgfbQJl4U62KPRwgPu8aX0m0uoEYv6YjZ9A"
      "CrIKEJr74lMQMyBmnoOYAWG7S6tcvUUnwLW79oRXDVlzMooAjYlG83XsS"
      "g+OxtRr3kD3i34XobUD3R/wAbP4MRlJ8mCBAAAAAElFTkSuQmCC"))

(define root-url
  (url #f #f #f #f #t null null #f))

(define up-url
  (url #f #f #f #f #f (list (path/param 'up null)) null #f))

(define (relative-path-url-to-root p)
  (define simple-path (simplify-path p))
  (define rel-path (find-relative-path (current-directory) simple-path))
  (cond
    [(equal? simple-path rel-path) root-url]
    [else
     (define pp
       (for/list ([d (in-list (explode-path rel-path))])
         (path/param (path->string d) null)))
     (url #f #f #f #f #t pp null #f)]))

(define (make-file-link icon url text)
  `(li (a ([href ,(url->string url)])
          (img ([src ,icon]
                [style "vertical-align: middle"]) "")
          ,text)))

(define (files-list path)
  (for/list ([f (directory-list path #:build? #t)])
    (define name (path->string (file-name-from-path f)))
    (define u (relative-path-url-to-root f))
    (define icon
      (if (directory-exists? f) folder-icon file-icon))
    (make-file-link icon u name)))

(define (make-template-xexpr title-string body)
  `(html
     (head
       (title ,title-string))
       (link ([rel "icon"]
              [type "image/png"]
              [href "favicon.png"]))
     (body
       (h1 ,title-string)
       (hr)
       ,body)))

(define (directory-lister:make #:url->path url->path)
  (lift:make
   (lambda (req)
     (define-values (path pieces) (url->path (request-uri req)))
     (unless (directory-exists? path)
       (next-dispatcher))
     (define root-path?
       (match pieces [(list 'same ...) #t] [_ #f]))
     (define title-string
       (~a "Directory of "
           (url->string (request-uri req))))
     (response/xexpr
      (make-template-xexpr title-string
                           `(ul ,@(if root-path?
                                      null
                                      (list (make-file-link folder-up-icon up-url "..")))
                                ,@(files-list path)))))))

(define (favicon-request? req)
  (match (url-path (request-uri req))
    [(list (path/param "favicon.png" '())) #t]
    [_ #f]))

(define (favicon:make)
  (lift:make
    (lambda (req)
      (with-handlers ([exn:fail?
                        (λ (e) (log-error
                                 "an error occurred serving favicon~%  ~a"
                                 (exn->string e))
                               (next-dispatcher))])
        (cond
          [(favicon-request? req)
           (response/full 200 #"OK" (current-seconds) #"image/png" null
                          (list (file->bytes favicon-path)))]
          [else (next-dispatcher)])))))

(define (not-found req)
  (response/xexpr
   #:code 404
   #:message #"Not Found"
   #:seconds (current-seconds)
   #:mime-type #f
   (make-template-xexpr "Error response"
                        '(div (p "Error code: 404")
                              (p "Message: File not found.")))))

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
              (static-files:make #:url->path url->path
                                 #:path->mime-type path-mime-type)
              (favicon:make)
              (directory-lister:make #:url->path url->path)
              (lift:make not-found)))))

  (displayln (~a "Now serving " BASE " from http://localhost:" PORT))

  (with-handlers ([exn:break? void]) (do-not-return))
  (shutdown-server))

