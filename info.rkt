#lang info

(define name "raco-static-web")
(define collection "raco-static-web")
(define version "0.9.9")
(define deps '("base" "web-server-lib" "mime-type-lib"))
(define build-deps '())
(define pkg-authors '(samdphillips@gmail.com))
(define raco-commands
  '(("static-web"
     (submod raco-static-web main)
     "runs a webserver serving files from the given directory"
     10)))
