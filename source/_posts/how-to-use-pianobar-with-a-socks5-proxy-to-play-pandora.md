title: How to use pianobar with a socks5 proxy to play pandora
date: 2016-10-27 15:57:00
tags:
- Pianobar
- Pandora
- socks5
- Proxy
---

I love pandora, However, I live in India where pandora is doesn't stream.
I got around this by proxying over socks5. Here is how you can do it.

 1. First you need access to a socks 5 proxy, If you have an ssh server running in the US or any country where pandora streams, you can spin up a proxy connection by running the following command
    `ssh -D 1337 -f -C -q -N username@yourserver.com`
 2. Once you have this running you'll need to change your pianobar config to make it use this proxy
    ~~~
    # ~/.config/pianobar/config
    password = yoursecretpasswordinplaintext
    user = youremail
    proxy = socks5://localhost:1337/
    ~~~

Once you have this setup, you can just run the `pianobar` command and it will start playing your favorite music.
