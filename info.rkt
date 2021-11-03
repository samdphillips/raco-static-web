#lang info

(define name "raco-static-web")
(define collection "raco-static-web")
(define version "0.9.2")
(define deps '("base" "web-server-lib"))
(define build-deps '())
(define pkg-authors '(samdphillips@gmail.com))
(define raco-commands
  '(("static-web" raco-static-web "runs a webserver serving files for the current directory" 10)))
