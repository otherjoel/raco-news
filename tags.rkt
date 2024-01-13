#lang racket/base

;; “Tag functions” for use in newsletter source files

(provide (all-defined-out))

(define (unsubscribe [link-text "unsubscribe"])
  `(unsubscribe ,link-text))

(define (webversion [link-text "You can view this newsletter on the web →"])
  `(webversion ,link-text))

(define (meta . elems)
  `(meta [[block "single"]] ,@elems))
