#lang info

(define collection "news")
(define pkg-desc "Email newsletter framework")
(define version "1.0")
(define raco-commands '(("news" (submod news/command raco) "Upload an email newsletter to Sendy" #f)))

(define deps '("base"
               "http-easy-lib"
               "punct-lib"
               "txexpr"))
(define build-deps '("at-exp-lib"))

(define pkg-authors '(joel))
(define license 'BlueOak-1.0.0)
