#lang at-exp racket/base

(require "styles.rkt"
         html-printer
         net/url
         punct/doc
         punct/render/html
         racket/class
         racket/format
         racket/match
         racket/string)

(provide doc->html-email)

;; ("posts/first.html" "https://example.com") → "https://example.com/post/first.html"
;; ("https://msn.com/about" "https://example.com") → "https://example.com/about" (no change)
(define (unrel-link dest base)
  (cond
    [(not (url-scheme (string->url dest)))
     (url->string
      (combine-url/relative (string->url base) dest))]
    [else dest]))

;; "image-160.jpg 160w, image-320.jpg 320w"
;; "https://example.com"
;; → "https://example.com/image-160.jpg 160w, https://example.com/image-320.jpg 320w"
(define (unrel-srcset srcset-str base-url)
  (define srcs (string-split srcset-str #rx",\\s*"))
  (string-join
   (for/list ([src (in-list srcs)])
     (define parsed-src (string-split src))
     (string-join (cons (unrel-link (car parsed-src) base-url) (cdr parsed-src))))
   ", "))

;; 
(define (unrel-src/hrefs attrs base-url)
  (for/list ([attr (in-list attrs)])
    (match attr
      [(list (or 'href 'src) dest) (list (car attr) (unrel-link dest base-url))]
      [(list 'srcset sources) (list 'srcset (unrel-srcset sources base-url))]
      [_ attr])))

;; A custom HTML renderer for Punct documents destined for use as email.
;; Chief difference from the basic HTML renderer is that this one blasts
;; styling and attributes everywhere, to try and keep things looking good
;; in all email clients.
;;
(define email-html-render%
  (class punct-html-render%
    (init-field base-url)
    
    (define/override (render-paragraph content)
      `(p ,(attr 'p) ,@content))

    ;; all headings become h2
    (define/override (render-heading level elems)
      `(h2 ,(attr 'h2) ,@elems))

    (define/override (render-blockquote blocks)
      `(blockquote ,(attr 'blockquote) ,@blocks))

    (define/override (render-code elems)
      `(code ,(attr 'code) ,@elems))

    (define/override (render-code-block info elems)
      `(pre (code ,(attr 'code) ,@elems)))

    (define/override (render-thematic-break)
      `(hr ,(attr 'hr)))
    
    (define/override (render-itemization style start elems)
      (if (equal? start "")
          `(ul [[class ,style] ,@(attr 'ul)] ,@elems)
          `(ol [[class ,style] [start ,start] ,@(attr 'ol)] ,@elems)))
    (define/override (render-item elems) `(li ,(attr 'li) ,@elems))

    (define/override (render-image src title desc elems)
      `(div ,(attr 'div.figure)
            (img [[src ,(unrel-link src base-url)]
                  ,@(if desc `((alt ,desc)) '())
                  ,@(if title `((title ,title)) '())
                  ,@(attr 'img)])
            ,@(if desc (list `(div ,(attr 'div.figcaption) ,desc)) '())))

    (define/override (render-link dest title elems)
      `(a [[href ,(unrel-link dest base-url)] ,@(if title `((title ,title)) '()) ,@(attr 'a)] ,@elems))
    
    (super-new)))

(define (make-render-other base-url)
  (lambda (tag attributes elems)
    (match `(,tag ,attributes)
      [(list* 'meta _) `(p ,(attr 'p.meta) ,@elems)]
      [(list* 'webversion _) `(div ,(attr 'div.web) (webversion ,@elems))] ; Sendy converts <webversion>
      [_ (default-html-tag tag (unrel-src/hrefs attributes base-url) elems)])))

(define (doc->email-body doc base-url)
  (send (new email-html-render% [doc doc] [render-fallback (make-render-other base-url)] [base-url base-url]) render-document))

(define (doc->html-email doc base-url [lang "en"] [generator "exploded stars"])
  @~a{<!DOCTYPE html>
<html lang="@lang" dir="ltr">
<head>
<meta charset="utf-8">
<meta content="width=device-width" name="viewport">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes">
<meta name="format-detection" content="telephone=no, date=no, address=no, email=no, url=no">
<meta name="x-apple-disable-message-reformatting">
<meta name="generator" content="@generator">
<title>@(hash-ref (document-metas doc) 'title "")</title>
<base href="@base-url">
@css-stylesheet
</head>
<body xml:lang="@lang" style="@attr['body 'style]">
@(xexpr->html5
  #:add-breaks? #t
  `(div ,(attr 'div.content) ,@(cdr (doc->email-body doc base-url))))
</body>
</html>
})
