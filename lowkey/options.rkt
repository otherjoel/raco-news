#lang racket/base
(require racket/file
         racket/match
         racket/runtime-path)

;;
;; Provides bindings to config options loaded from options.ini
;;

(provide make-options-ref)

;; Lightweight options file reader.

;; Line is a “comment” (ignored) if first non-whitespace character is #
(define (comment-or-whitespace? line)
  (regexp-match? #px"^\\s*(?:#.*|)$" line))

;; "key: value" → '(key "value")
(define (line->keyval line)
  (match (regexp-match #px"^\\s*([^ :]+)\\s*:\\s*(.+)$" line)
    [(list _ keystr val) (list (string->symbol keystr) val)]
    [_ #f]))

(define (make-options-ref filename #:defaults [opts-hash (hasheq)])
  (define lines (file->lines filename))
  (define opts
    (let loop ([remaining lines]
               [opts opts-hash])
      (match remaining
        [(list) opts]
        [(list* (? comment-or-whitespace?) rem) (loop rem opts)]
        [(list* line rem)
         (define new-opt (apply hash-set opts (line->keyval line)))
         (loop rem new-opt)])))
  (procedure-rename (lambda (sym) (hash-ref opts sym #f))
                    (string->symbol (format "hashref_~a" filename))))
