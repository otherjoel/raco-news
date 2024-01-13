#lang racket/base

(require racket/match)

(provide (all-defined-out))

(define color:reset #"\e(B\e[m")
(define color:bold #"\e[1m")
(define color:red #"\e[31m")
(define color:green #"\e[32m")
(define color:yellow #"\e[33m")
(define color:gray #"\e[90m")

(define (printc good? message [code #f])
  (define-values (bip bip-color msg-color)
    (match (list good? code)
      [(list #t #f) (values " ✔ " color:green color:reset)]
      [(list #f #f) (values " ✘ " color:red color:yellow)]
      [(list #t c) (values (format "~a" code) color:green color:reset)]
      [(list #f c) (values (format "~a" code) color:red color:yellow)]))
  (parameterize ([current-output-port (current-error-port)])
    (write-bytes color:gray)
    (write-char #\[)
    (write-bytes bip-color)
    (write-string bip)
    (write-bytes color:gray)
    (write-string "]  ")
    (write-bytes msg-color)
    (write-string (format "~a" message))
    (write-bytes color:reset)
    (write-char #\newline)))