<!-- 
.. title: PHP: Headers already sent and HTTP basic
.. slug: php-headers-already-sent-and-http-basic
.. date: 2014/03/03 14:37:42
.. tags: draft, php, http, headers
.. link: 
.. description: 
.. type: text
-->

If there's one error that must be encountered by all PHP developers, this:-

    Warning: Cannot modify header information - headers already sent by ...

probably one of it. Anyone who developing in PHP must at least once having issue
involving this. Lot of articles and answers have been written on this issue, and [this
answer on stackoverflow][so1] is one of the most comprehensive write up explaining the issue,
why it happen and how to fix it. So I don't plan to talk much on the PHP part in this post
but more on the HTTP part.

## What is HTTP ?
It's a protocol that govern how a piece of information can be exchanged over the Internet.
There are lot of protocols defined and being used on the Internet but HTTP definitely one
of the widely used protocol in form of what layman known as web, or World Wide Web (WWW).
The protocol is being defined as [RFC 2616][2616] and as we will later realized, it is a
text protocol. Being a text based protocol make it much easier to study and understand and
test it in practical manner since no special tools needed to actually implement the protocol.
Before we delved deeper into the protocol, let also clear up what actually meant by the word
protocol itself.

To put an analogy, when two human need to communicate with each other they both need to use
some sort of language that both of them will understand. Someone who only know Malay and try
to speak to another one that can only speak in English will definitely have some hard time
understanding each other. While we human can actually sort that kind of problem with other means
such as body language or facial expression, computers on the other hand are pretty dumb (or at
least haven't reach the human level of inteligence yet). So two computers that need to talk to
each other, they must use some common language - thus the protocol. Please note however the protocol
as being discussed here is more on high level protocol, or called as application layer. There are
other protocol that involved moving the bits over the wire but we're not going to discuss those.

As mentioned before, HTTP is a text protocol so when two computers (a client and a server) need to
communicate they will just sent a bunch of text as outlined by the protocol. So a client may send
the following to server:-

    GET /index.html HTTP/1.1

Above is just a plain text that will be sent by client to a socket on the server, and the server
on the other hand is required to return a response which also a plain text that may look like below:-

    HTTP/1.1 200 OK

    Hello world

I'd also mentioned above that we don't need any special tools to actually implement this protocol. Any
tools that can open a socket connection and let us send some text through it will do. So guess what tools
that most computers already have ? The `telnet`. Let's try to talk to a Google HTTP server and see what
we'll get:-

    $ telnet www.google.com 80
    Trying 173.194.126.80...
    Connected to www.google.com.
    Escape character is '^]'.
    GET /index.html HTTP/1.1

    HTTP/1.1 200 OK
    Date: Mon, 03 Mar 2014 15:19:22 GMT
    Expires: -1
    Cache-Control: private, max-age=0
    Content-Type: text/html; charset=ISO-8859-1
    Set-Cookie: PREF=ID=9862b6886e93da12:FF=0:TM=1393859962:LM=1393859962:S=Vlib8XNFMPHru-3K; expires=Wed, 02-Mar-2016 15:19:22 GMT; path=/; domain=.google.com
    Set-Cookie: NID=67=cC38fiwjW6qW5bcRzZuAAHmjY2qAwgPEM5m0QL3LuSoa_gtgzHgogLmZISsEovpLDRVLL4KcdhWXO-SmT6UJUfEJ3V6yn0xmp8XcLJfEFUJ92COvGcnxgi3oYHXZcguq; expires=Tue, 02-Sep-2014 15:19:22 GMT; path=/; domain=.google.com; HttpOnly
    P3P: CP="This is not a P3P policy! See http://www.google.com/support/accounts/bin/answer.py?hl=en&answer=151657 for more info."
    Server: gws
    X-XSS-Protection: 1; mode=block
    X-Frame-Options: SAMEORIGIN
    Alternate-Protocol: 80:quic
    Transfer-Encoding: chunked

    8000
    <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage"><head><meta content="Search the world's information, including webpages, images, videos and more. Google has many special features to help you find exactly what you're looking for." name="description"><meta content="noodp" name="robots"><meta itemprop="image" content="/images/google_favicon_128.png"><title>Google</title><script>(function(){  ...

Ok, probably too much stuff for a starter ;)

## Request/Response format   
Basically the meat of HTTP is defining what is the format for a request and response. Both request and response basically
using the same structure of content that is it is divided into 2 parts. The first part is called `headers` and the second
part known as `body`.

    POST /index.html HTTP/1.1   ||
    Host: www.google.com        ||> headers
    Accept: */*                 ||

    name=kamal&address=jb       ||> body

And the response:-

    HTTP/1.1 200 OK                                 ||
    Date: Mon, 03 Mar 2014 15:19:22 GMT             ||
    Expires: -1                                     ||> headers
    Cache-Control: private, max-age=0               ||
    Content-Type: text/html; charset=ISO-8859-1     ||

    <html><head><title>...</html>                   ||> body

When using browsers to submit the HTTP request, the body part will probably what you're typing in the forms and when receiving
back the response, the body part usually what actually being rendered by browsers as the web page. For a normal users,
the `headers` part usually not much a concern.

## PHP
So what all above has any relation to the problem highlighted at the beginning of this post ? PHP (unfortunately) manage
to hide (or in other word abstract out) all the low level details of the HTTP above through a simple language syntax.
So to give an output from your PHP script, you just use the `print` or `echo` statement and PHP will do the job of
'translating' it into HTTP format. So, the PHP script:-

```php
<?php
print 'hello world';
```

Might result in the following HTTP response:-

```console
HTTP/1.1 200 OK
Content-Type: text/html

hello world
```
What if we need to include a custom header in the response ? We use the `header()` function:-

```php
<?php
header('Content-Type: text/plain')
print 'hello world';
```
and it will be 'translated' as:-

```console
HTTP/1.1 200 OK
Content-Type: text/plain

hello world
```
What if we call `print` first and later on `header()`:-
```php
<?php
print 'hello world';
header('Content-Type: text/plain')
```
It will result in the following output:-

```console
HTTP/1.1 200 OK

hello world
Content-Type: text/plain
```
And if you still following along this far, you'll immediately noticed that the above output is wrong and
this is the reason why PHP refuse to take it and giving you the infamous error `Headers already sent ...`.

[so1]:http://stackoverflow.com/questions/8028957/how-to-fix-headers-already-sent-error-in-php
[2616]:https://www.ietf.org/rfc/rfc2616.txt
