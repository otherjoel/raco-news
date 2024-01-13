#lang racket/base

(require "email-render.rkt"
         "lowkey/options.rkt"
         net/http-easy
         punct/doc
         punct/fetch
         punct/render/plaintext
         racket/match
         racket/string)

(provide check-api
         create-campaign
         check-link)

(define (api v endpoint)
  (format "~a/~a.php" endpoint v))

(define (get-lists opt-proc)
  (with-handlers ([exn? (λ (e) (object-name e))])
    (post (api 'lists/get-lists (opt-proc 'sendy-endpoint))
          #:form `((api_key . ,(opt-proc 'sendy-api-key))
                   (brand_id . ,(opt-proc 'brand-id))))))

(define (check-api opt-proc)
  (match (get-lists opt-proc)
    ;; Sendy always responds with HTTP 200, even when the response is an error.
    ;; It also responds with Content-Type: text/html even when the response body is JSON.
    [(response #:status-code 200
               #:status-message m
               #:body (regexp #rx"^[^{].*" (list b))) ; Doesn’t start with { = not JSON
     `(error 200 ,(format "Sendy error: ~a" b))]
    [(response #:status-code 200
               #:json j)
     (match (hash-keys (hash-ref j 'list1 (hasheq)))
       [(list-no-order 'id 'name) `(success 200 ,j)]
       [_ `(error 200 ,(format "Non-Sendy JSON response from ~a" (opt-proc 'sendy-endpoint)))])]
    [(response #:status-code c
               #:status-message m)
     `(error ,c ,m)]
    [(var v) `(error -inf.0 ,v)]))

(define (create-campaign doc opt-proc)
  (define title (hash-ref (document-metas doc) 'title))
  (define plaintext-version (doc->plaintext doc 65))
  (define html-version (doc->html-email doc (opt-proc 'base-url)))
  
  (define result
    (post (api 'campaigns/create (opt-proc 'sendy-endpoint))
          #:form `((api_key . ,(opt-proc 'sendy-api-key))
                   (from_name . ,(opt-proc 'from-name))
                   (from_email . ,(opt-proc 'from-email))
                   (reply_to . ,(opt-proc 'from-email))
                   (title . ,title)
                   (subject . ,title)
                   (plain_text . ,plaintext-version)
                   (html_text . ,html-version)
                   (brand_id . ,(opt-proc 'brand-id))
                   (track_opens . "0")
                   (track_clicks . "0"))))
  (match result
    [(response #:status-code 200
               #:body (regexp #rx"^Campaign.*" (list msg)))
     (list #true msg)]
    [(response #:status-code c
               #:body msg)
     (list #false msg)]))

;; Try an HTTP HEAD request for the URL.
;; If there is a response, returns the response code and message in a list.
;; Otherwise, returns (list #f "error message")
(define (check-link link-url)
  (with-handlers
      ([exn:fail:network:errno?
        (λ (e) (match-define (cons enum cat) (exn:fail:network:errno-errno e))
          (list #f (if (eq? cat 'gai)
                       "Error resolving hostname"
                       (format "~a error ~a" cat enum))))]
       [exn? (λ (e) (list #f (object-name e)))])
    (cond
      [(non-empty-string? link-url)
       (match (get link-url)
         [(response #:status-code c
                    #:status-message m)
          (list c m)])]
      [else (list #f "empty URL")])))
