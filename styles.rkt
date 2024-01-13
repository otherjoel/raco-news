#lang at-exp racket/base

(require "lowkey/css.rkt"
         racket/match
         racket/format
         racket/string)
         
(provide (all-defined-out))

;; Provides styles and attributes to use in HTML destined to be sent as the content of an email.

;; Helpers and constants
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define accent-color "#71862D")
(define link-color "#71862D") ; AABA16?
(define font-size '(font-size "17px"))
(define line-height '(line-height "25px"))
(define font-fam '(font-family "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'"))
(define heading-font '(font-family "'Iowan Old Style', 'Palatino Linotype', 'URW Palladio L', P052, serif"))
(define code-font '(font-family "ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, 'DejaVu Sans Mono', monospace"))


;; Styles
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; Email clients, you may know, are not only stupid when it comes to rendering HTML, they are all
;; stupid in their own unique ways. To counteract this, we not only inline a stylesheet within
;; the <head> of the HTML document, we also squirt styles into the style attribute of almost every
;; single tag.

;; Here we construct a reference of these styles in such a way that they can be grabbed for use
;; in individual tags by the renderer (email-renderer.rkt), as well as duplicated in the main
;; stylesheet.
(define attr
  (make-attr-ref
   `(body
     ,(style (zero 'margin)
             (zero 'padding)
             font-fam
             line-height
             '(color "#111")
             '(background-color "#fff")
             '(-webkit-font-smoothing antialiased)
             '(-webkit-text-size-adjust none)
             '(width "100%")
             '(height "100%")
             '(min-height "100%")
             '(position relative)
             '(font-variation-settings "'wdth' 95")))
   `(div.content
     (class "content")
     ,(style '(margin "0 auto 0 auto")
             '(width "600px")
             '(max-width "100%")
             '(padding "25px 8px 25px 8px")))
   `(div.web
     (class "web")
     ,(style '(margin "0 0 25px 0")
             '(width "100%")
             '(text-align right)
             '(color "#666")))               
   `(p
     ,(style '(margin "0 0 25px 0")
             (zero 'padding)
             font-size
             line-height
             font-fam))
   `(h2
     ,(style '(margin "0 auto 25px auto")
             line-height
             `(color ,accent-color)
             heading-font
             '(font-size "24px")
             '(font-style italic)
             '(font-weight bold)))
   `(a
     ,(style `(color ,link-color)))
   `(blockquote
     ,(style '(margin "0 0 0 25px")
             '(color "#625F50")))
   `(div.figure
     (class "figure")
     ,(style '(margin "0 auto 25px auto")
             '(display block)
             '(width "600px")
             '(max-width "100%")))
   `(img
     (loading "eager")
     (decoding "async")
     ,(style '(box-shadow "0 0 13px rgba(0, 0, 0, 0.125);")
             '(border none)
             '(display block)
             '(width "100%")
             '(max-width "100%")
             '(height auto)
             '(margin "0 0 13px 0")
             (zero 'padding)))
   `(div.figcaption
     ,(style (zero 'margin)
             (zero 'padding)
             '(display block)
             font-fam
             '(font-size "13px")
             '(line-height "13px")
             '(text-align right)
             '(color "#666")
             '(width "100%")
             '(height "auto")
             '(max-width "100%")))
   `(hr
     ,(style '(border none)
             '(outline none)
             `(border-bottom ,(format "1px solid ~a" link-color))
             '(margin "2rem 0 2rem 0")))
   `(p.meta
     (class "meta")
     ,(style '(margin "0 auto 25px auto")
             '(padding "17px")
             font-size
             line-height
             '(color "#666")
             '(background-color "#eee")
             '(border-radius "8px")))
   `(code
     ,(style code-font
             '(color "#625F50")
             '(line-height "18px")
             '(font-size "13px")))
   `(ol
     ,(style '(margin "0 0 25px 0")))
   `(ul
     ,(style '(margin "0 0 25px 0")))
   `(li
     ,(style (zero 'margin)
             font-size
             line-height))))

(define (css tag)
  (format "~a { ~a }\n" tag (attr tag 'style)))

(define css-stylesheet
  @~a{<style type="text/css">
 body,
 h1, h2, h3, h4,
 p,
 ol, ul, li,
 blockquote,
 div {
  margin: 0;
 }

 * {
  box-sizing: border-box;
 }

 html {
  font-size: 17px;
  min-height: 100%;
  background-color: #fff;
 }

 @css['body]

 @css['div.content]

 @css['hr]

 h1 {
  display: none;
 }

 @css['h2]

 h3 {
  font-family: @(cadr heading-font);
  text-align: center;
  font-style: italic;
  font-weight: normal;
  font-size: 22px;
  line-height: 25px;
  margin: 0 auto 25px auto;
 }

 @css['p]

 a,
 a:link,
 a:visited {
  color: hsl(12, 76%, 55%);
 }

 a:active,
 a:hover {
  color: #111;
 }

 @css['p.meta]

 p.meta a,
 p.meta a:link,
 p.meta a:visited {
  color: #666;
 }

 p.meta a:active {
  color: #111;
 }

 @css['ul]

 @css['ol]

 @css['img]

 /* gmail */
 span.emoji img {
  display: inline !important;
  width: auto !important;
  max-width: none !important;
  min-height: 0 !important;
 }

 @css['div.web]

 div.web a,
 div.web a:link,
 div.web a:visited {
  color: #666;
 }

 div.web a:hover,
 div.web a:active {
  color: @link-color;
 }

 @css['div.figure]

 div.figure picture, div.figure img {
  display: block;
  width: 100%;
  height: auto;
  max-width: 100%;
  margin: 0 0 13px 0;
  padding: 0 0 0 0;
  box-shadow: 0 0 13px rgba(0, 0, 0, 0.125);
 }

 div.figure picture.no-shadow, div.figure img.no-shadow {
  box-shadow: none;
  background: transparent;
 }

 div.figure picture.blend {
  mix-blend-mode: multiply;
 }

 @css['div.figcaption]

 div.figcaption a,
 div.figcaption a:link,
 div.figcaption a:visited {
  text-decoration-color: #666;
  color: #666;
 }

 div.figcaption a:hover,
 div.figcaption a:active {
  text-decoration-color: @accent-color;
  color: @accent-color;
 }

 @css['blockquote]
  
 small {
  text-transform: uppercase;
  font-size: 14px;
 }

 pre {
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
  font-size: 13px;
  line-height: 18px;
  margin-left: 25px;
  color: #625F50;
 }

 @css['code]

 span.nobr {
  white-space: nowrap;
 }

 </style>
 })