title: HTTP
date: 2013-05-19
tags:
- http
- for-sohel
---

HTTP is a protocol used by computers to communicate with each other.
A protocol is just a series of rules/steps which need to be followed for communication.
e.g. If you want to buy a chocolate from the mall, you can go to the mall,
find the chocolate put it in a shopping cart, go to the checkout counter and pay the bill.
This can be thought of as a protocol, In this example, the steps are not very strict,
but in computer protocols there is no scope for ambiguity. 

HTTP is used whenever you visit a website. HTTP lays out the rules the
communication between your browser and the web server. Here is an example of
what happens when you open enter  cosmicvent.com in your browser and hit enter:


1) The browser finds the IP address of cosmicvent.com (which at the moment is 176.9.113.5).
2) It sends it a text message using another protocol called TCP/IP. The message
    looks something like this:


    GET / HTTP/1.1
    Host: cosmicvent.com
    Connection: keep-alive
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
    User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31
    Accept-Encoding: gzip,deflate,sdch
    Accept-Language: en-US,en;q=0.8,hi;q=0.6,te;q=0.4
    Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
    Cookie: __utma=223412489.1036637458.1339923857.1366442947.1368767056.19; __utmz=223412489.1339923857.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)


  This is called an HTTP 'Request', It says that the browser is 'making' a 'GET'
  request using the 'HTTP/1.1' protocol and that the browser is looking for a
  'document' called '/' of type 'html' or 'xhtml'. The 'User-Agent' has information about
  the version of the browser.

3) Now, the webserver which is the software running on google sends an HTTP
    'Response' which looks like the following:


    HTTP/1.1 200 OK
    Server: nginx/1.0.11
    Content-Type: text/html; charset=utf-8
    Keep-Alive: timeout=20
    Status: 200 OK
    Cache-Control: max-age=60, private
    X-UA-Compatible: IE=Edge,chrome=1
    ETag: "39a5d8d65c963b21615df87157699c2e"
    X-Request-Id: 8a9bce4126abb10ca9fdd1e76a1ea520
    X-Runtime: 0.059963
    X-Rack-Cache: miss
    Transfer-Encoding: chunked
    Date: Sun, 19 May 2013 17:38:22 GMT
    X-Varnish: 2087699445
    Age: 0
    Via: 1.1 varnish
    Connection: keep-alive

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <!--[if lt IE 7 ]> <html class="ie6" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
      <!--[if IE 7 ]>    <html class="ie7" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
        <!--[if IE 8 ]>    <html class="ie8" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
          <!--[if IE 9 ]>    <html class="ie9" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
            <!--[if (gt IE 9)|!(IE)]><!--> <html xmlns="http://www.w3.org/1999/xhtml"> <!--<![endif]-->
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

                <link rel="sitemap" type="application/xml" title="Sitemap" href="/sitemap.xml" />
                <title>
                  Home - Cosmicvent Software
                </title>


  Now this text is understood by the browser, the browser reads the header which
  is the part above the empty line (above <!doctype html>). The response says
  that the server is also using the 'HTTP/1.1' protocol, the 200 and OK mean
  that the response was 'successful' and it didn't fail (The 200 is a status
  code, and HTTP has many status codes with different meanings, you might have
  seen 404 Not found in a browser, that means the document requested by the
  browser could not be found by the webserver). It also tells us when this
  document was sent, and some more information which is understood by the
  server. Another important Header is the 'Content-Type' which tells the browser
  what type of document the response is. In this example it says the content
  type is an html document. So, the browser renders it as an html page. If the
  content type was an image, the response would have something like: 'Content-Type: image/png', 
  which would tell the browser to render it as an image. What follows after the
  empty line (the <!doctype html>...) is the actual content.
  
  An analogy for an HTTP Response is a mail package. The cover of the mail package has
  information about the package like the weight of the package, the address to
  which it is to be delivered, its contents. And when you open the package it
  contains the actual items. An HTTP response is similar but it has different
  information in the 'Header' (the package wrapping). This information is
  sometimes also called meta data. And, the actual document comes after an empty
  line after the header.

You can read more about HTTP here: https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol
