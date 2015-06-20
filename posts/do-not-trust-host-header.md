<!-- 
.. link: 
.. description: 
.. tags: apache, http, security
.. date: 2013/09/25 16:00:00
.. title: Do not trust HOST header
.. slug: do-not-trust-host-header
-->

This is nasty and definitely unexpected. While reading through the [article][1], I still have a feeling that this is not possible (at least on ubuntu) since default install of apache always create a default vhost that can act as catch-all handler in case user pass nonsense Host header but this paragraph opened my eye:-

However, the arguably ultimate authority on virtual hosting, RFC2616, has the following to say:

>5.2 The Resource Identified by a Request
>[...]
>If Request-URI is an absoluteURI, the host is part of the Request-URI. Any Host header field value in the request MUST be ignored.
>The result? On Apache and Nginx (and all compliant servers) it's possible to route requests with arbitrary host headers to any application present by using an absolute URI:
> POST https://addons.mozilla.org/en-US/firefox/users/pwreset HTTP/1.1
> Host: evil.com

For so long I think HOST header is the definitive source to determine which site to serve under virtual hosting. A quick test proved this newly found fact:-

```console
echo -en "GET /password-reset/ HTTP/1.1\r\nHost: evil.com\r\n\r\n" | nc 102.256.89.57 80
HTTP/1.1 200 OK
Date: Wed, 25 Sep 2013 07:54:00 GMT
Server: Apache/2.2.22 (Ubuntu)
Last-Modified: Fri, 13 Sep 2013 08:07:54 GMT
ETag: "25a9c-b1-4e63f5a01c982"
Accept-Ranges: bytes
Content-Length: 177
Vary: Accept-Encoding
Content-Type: text/html
X-Pad: avoid browser bug

<html><body><h1>It works!</h1>
<p>This is the default web page for this server.</p>
<p>The web server software is running but no content has been added, yet.</p>
</body></html>
```

So we still safe, apache serve the default vhost. But this one:-

```console
echo -en "GET http://www.mysite.com/password-reset/ HTTP/1.1\r\nHost: evil.com\r\n\r\n" | nc 102.256.89.57 80
```

Give you the page of mysite.com ! Fortunately Django 1.5 has fixed for this. Better check if your app depend on the HOST header to build absolute url.

[1]:http://www.skeletonscribe.net/2013/05/practical-http-host-header-attacks.html
