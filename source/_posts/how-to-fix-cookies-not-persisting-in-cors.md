title: How to fix cookies not persisting using CORS
date: 2025-02-17 09:38:44
tags:
- cors
- cookies
- backend
- SPA
- frontend
- axios
- fetch
---

I have been toying around with React to refresh my frontend skills (The last
time I used full stack seriously was with backbone.js 😂). While building this
app, I wanted to use cookies to store a JWT token from the backend. I did not
want the jwt token to be stored in local storage because of the security implications.

Here is my reference app with the problem: The commit with the code that has the problem: https://github.com/minhajuddin/blog-samples/pull/1/commits/adbf276d649af049e56866306983ce653c187c96#diff-f3a80d02e5834a09d590f34b0af1f6c33a4397fd7c4a2eb6847380f228983542R44-R63

Here is the relevant code:

```go
rg.POST("/login", func(c *gin.Context) {
    // NOTE: You would want to check username/password here
    c.SetCookie("_auth", "awesome.jwt.token", 3600, "", "", false, true)

    c.JSON(http.StatusOK, gin.H{"message": "Logged in via cookie"})
})

rg.GET("/me", func(c *gin.Context) {
    jwt, err := c.Cookie("_auth")
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Cookie not found"})
        return
    }

    if jwt != "awesome.jwt.token" {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"user": "minhajuddin", "id": 1})
})
```

And, here is the javascript code that makes the request https://github.com/minhajuddin/blog-samples/pull/1/commits/adbf276d649af049e56866306983ce653c187c96#diff-b7726e02edfe1248f6ca02c671344d08f10f81801e755e28c0b8448ce3f50833R27-R34

```js
document.getElementById('login').addEventListener('click', function() {
  axios.post("http://localhost:8001/api/v1/login").then(response =>
    dbg(response)
  ).catch(error =>
      dbug(error.response)
  )
});

document.getElementById('me').addEventListener('click', function() {
  axios.get("http://localhost:8001/api/v1/me").then(response =>
    dbg(response)
  ).catch(error =>
    dbg(error.response)
  )

```

And, looking at the network tab in the browser, I see that the cookie is being set, but it is not being sent with the subsequent requests.

{% asset_img logged-in-cookie-response.png Sending a login request which shows Cookie in the response%}
{% asset_img nocookie-response.png No Cookie in the next request 😞 %}


## The fix

The problem is that we are not using the `withCredentials` option in axios, this is required for cookies to be sent with the request. Let's fix the code:

```js
document.getElementById('me').addEventListener('click', function() {
  axios.get("http://localhost:8001/api/v1/me", {withCredentials: true}).then(response =>
    dbg(response)
  ).catch(error =>
    dbg(error.response)
  )
```

## The real fix

This still didn't fix the problem for me and I was pulling my hair when I finally figured that the withCredentials option needs to be set even for the code that does the authentication. Let's fix that:


```js
    document.getElementById('login').addEventListener('click', function() {
      axios.post("http://localhost:8001/api/v1/login", {}, { withCredentials: true }).then(response =>
        dbg(response)
      ).catch(error =>
          dbug(error.response)
      )

    });
```

Now, the cookies are being sent with the request and the backend is able to read the cookie and authenticate the user.
{% asset_img fixed.png Yay! Cookies in the subsequent requests 😀🍪🍪 %}

I hope this helps you fix your CORS cookie problems.

Happy hacking! 🚀

P.S: You could also set the withCredentials option globally for axios like so:

```js
axios.defaults.withCredentials = true
```
