#lang racket/base

(require web-server/servlet
         web-server/servlet-env)

(serve/servlet
  (lambda ignore
    (response/xexpr (list (string->symbol "html"))))
  #:launch-browser? #f
  #:extra-files-paths (list ".")
  #:servlet-path "")

