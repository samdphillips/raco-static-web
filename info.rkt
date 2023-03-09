#lang info

(define name "raco-static-web")
(define collection "raco-static-web")
(define version "1.1")
(define deps '("base" "mime-type-lib" "net-lib" "version-case" "web-server-lib"))
(define build-deps '())
(define pkg-authors '(samdphillips@gmail.com))
(define license 'Apache-2.0)
(define raco-commands
  '(["static-web"
     (submod raco-static-web main)
     "runs a webserver serving files from the given directory"
     10]))

