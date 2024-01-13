#lang racket/base

(require "sendy.rkt"
         "lowkey/console.rkt"
         "lowkey/options.rkt"
         punct/fetch
         punct/doc
         racket/cmdline
         racket/list
         racket/match
         racket/runtime-path
         txexpr)

(provide (all-defined-out))

(define-runtime-path options.ini "options.ini")
(define opt (make-options-ref options.ini))
(define check-only (make-parameter #f))

(module+ raco
  (define filename
    (command-line #:program "raco news"
                  #:once-each
                  [("-c" "--check-only") "Only check links, do not upload campaign"
                                         (check-only #t)]
                  #:args (filename)
                  filename))
  (raco-news-command filename))
  
(define (raco-news-command filename)
  (define doc (display/check-file filename))
  (and doc (for-each display/link-check (list-link-urls doc)))
  (unless (check-only)
    (and (display/api-check opt)
         (display/campaign-create doc opt))))

(define (display/check-file filename)
  (define maybe-doc
    (cond
      [(file-exists? filename)
       (with-handlers ([exn:fail? (λ (e) (format "Fatal: ~a" (object-name e)))])
         (get-doc filename))]
      [else (format "File doesn’t exist: ~a" filename)]))
  (match maybe-doc
    [(? string? err) (printc #f err) #f]
    [(var d) (printc #t (format "Loaded ~a" filename)) d]))

(define (display/api-check opt-proc)
  (define (task str) (format "Sendy API check… ~a" str))
  (define endpoint (opt-proc 'sendy-endpoint))
  (match (check-api opt-proc)
    [(list 'success _ _)
     (printc #t (task "success!"))
     #true]
    [(list 'error 200 msg)
     (printc #f (task msg))
     #false]
    [(list 'error -inf.0 msg)
     (printc #f (task (format "Fatal: ~a" msg endpoint)))
     #false]
    [(list 'error code msg)
     (printc #f (task (format "~a ~a returned from ~a" code msg endpoint)))
     #false]))

(define (display/campaign-create doc opt-proc)
  (apply printc (create-campaign doc opt-proc)))

(define (link? tx)
  (and (list? tx) (eq? 'link (car tx))))

(define (list-link-urls doc)
  (define link-xprs (findf*-txexpr `(root ,@(document-body doc)) link?))
  (remove-duplicates
   (for/list ([xpr (in-list link-xprs)])
     (attr-ref xpr 'dest))))

(define (display/link-check url)
  (match (check-link url)
    [(list 200 msg)
     (printc #t (format "~a: ~a" msg url) 200) #t]
    [(list code msg)
     (printc #f (format "~a: ~a" msg url) code) #f]))
