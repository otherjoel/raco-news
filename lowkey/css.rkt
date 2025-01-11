#lang racket/base

(require racket/match
         racket/string)

(provide (all-defined-out))

;; Converts (style '(border none) 'font-size "25px")
;; to      '(style "box-sizing: border-box; border: none; font-size: 25px;")
(define (style . vals)
  (list 'style
        (string-join
         (let loop ([strs '()]
                    [vs vals])
           (match vs
             ['() (cons "box-sizing: border-box;" (reverse strs))]
             [(or (list* (list a b) v) (list* a b v))
              (loop (cons (format "~a: ~a;" a b) strs) v)])))))

;; Returns a function that maps tag names to lists of attributes
(define (make-attr-ref . tag-attr-pairs)
  (define tag-map
    (for/hash ([tp (in-list tag-attr-pairs)])
      (values (car tp) (cdr tp))))
  (lambda (tag [single-attr #f])
    (define attrs (hash-ref tag-map tag '()))
    (if single-attr
        (for/first ([a (in-list attrs)]
                    #:when (eq? single-attr (car a)))
          (cadr a))
        attrs)))

;; Shorthand
(define (zero tag) `(,tag "0 0 0 0"))
