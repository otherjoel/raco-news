# News

“News” is a utility I wrote for generating/uploading well-designed email campaigns in [Sendy][1]
from source files written in [Punct][3] (Markdown+Racket). I use it to publish my [Port Watchers][2]
newsletter.

[1]: https://sendy.co 
[2]: https://joeldueck.com/newsletter.html
[3]: https://joeldueck.com/what-about/punct/

[Sendy][3] is a great tool for self-hosting lists and sending large (or small) volumes of email to
those lists via Amazon SES, but it is not as convenient as services like Tinyletter or Buttondown
for sending simple, well-designed newsletters. It does not assist you at all with HTML formatting or
provide useful defaults, does not check your links for you, and does not automatically generate
a plain-text version of your email.

“News” fills those gaps. You can find some screenshots and a dime tour of how it works in [this
toot][4].

[4]: https://tilde.zone/@joeld/111109880904831727

## Setup

Prerequisites:

* “News” is a command-line Racket program, so you need [Racket][6] and you need its `bin` folder
  added to your “PATH”.
* You will need to [install Punct][5] separately (it is not on the Racket package server).
* You also need to buy and [set up Sendy][7], which includes setting up an AWS account to use
  Amazon’s Simple Email Service (SES).

Clone this repository, and from within its main folder, run `raco pkg install --link`. This will
install the folder as a Racket package.

[5]: https://github.com/otherjoel/punct
[6]: https://docs.racket-lang.org/getting-started/index.html
[7]: https://sendy.co/get-started

Finally, create an `options.ini` file in the repo’s folder and add these options to it:

    sendy-api-key: <your-API-key-here>
    brand-id: 1
    base-url: https://example.com
    sendy-endpoint: https://example.com/sendy/api
    from-name: Your Name
    from-email: me@example.com

The `brand-id` is the ID of the “Brand” you create for your newsletter within Sendy. The API key is
available in your Sendy installation’s “Settings” screen.

## Use

Write your newsletter in [Punct][3] and add `news/tags` to the `#lang` line. This provides the
`webversion`, `meta` and `unsubscribe` functions.

Here’s an example newsletter:

    #lang punct news/tags

    ---
    title: This Becomes Your Subject
    ---

    •(webversion)

    # First Issue

    •meta{Hi, you’re getting this because you subscribed, but you can •(unsubscribe) if you want.}

    Etc. Add [a link](https://ipcow.com) for good measure.

Your source files can reside anywhere, they don’t have to be in this repo’s folder.

When ready, run `raco news yourfile.md.rkt`:

    $ raco news yourfile.md.rkt
    [ ✔ ]  Loaded yourfile.md.rkt
    [200]  OK: https://ipcow.com
    [ ✔ ]  Sendy API check… success!
    [ ✔ ]  Campaign created

The command checks all the links in your source file, and creates a new campaign in Sendy that
contains both an HTML and plain text version of your newsletter.


