#lang info

(define name "raco-static-web")
(define collection "raco-static-web")
(define version "0.9.3")
(define deps '("base" "web-server-lib"))
(define build-deps '())
(define pkg-authors '(samdphillips@gmail.com))
(define raco-commands
  '(("static-web" raco-static-web "runs a webserver serving files from the given directory" 10)))
