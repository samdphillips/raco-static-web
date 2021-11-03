#lang racket/base
(require racket/cmdline
         raco/command-name
         web-server/web-server
         web-server/http/response-structs
         web-server/dispatchers/filesystem-map
         (prefix-in sequence: web-server/dispatchers/dispatch-sequencer)
         (prefix-in files: web-server/dispatchers/dispatch-files)
         (prefix-in lift: web-server/dispatchers/dispatch-lift))

(define PORT 8000)
(define BASE (current-directory))

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

(define (not-found req)
  (response/full 404 #"Not Found" (current-seconds) #f null null))

(define shutdown-server
  (serve #:port PORT
         #:dispatch
         (sequence:make
          (files:make #:url->path (make-url->path BASE))
          (lift:make not-found))))

;; Wait for Ctrl-C
(with-handlers ([exn:break? void])
  (sync never-evt))

(shutdown-server)
