title: How to integrate a simple contact form on your blog or website
date: 2012-06-17
tags:
- simpleform
- utility
- lego
- form
---

Here is a simple tool which I built, which allows you to setup a simple contact form in a jiffy. Well, you may ask: *How is it different than the popular solutions like wufoo and google document forms?*

![Flexible](https://substancehq.s3.amazonaws.com/static_asset/4fdda24d03b04d2a600007a0/elastigirl.jpg)

**It's flexible and It gets out of your way!**

It doesn't force you to use styles from some generic templates, Using Simple Form you can hand craft your html form without the annoying iframes. Simple Form just needs the correct *form action* and *method*. The rest of the html is in your control.

>Simple Form allows you to setup forms with any kind of data (other than file uploads) in 2 easy steps:

>Setup your form using the following code:

~~~html
<form action="http://getsimpleform.com/messages?form_api_token=<form_api_token>" method="post">

  <!-- the redirect_to is optional, the form will redirect to the referrer on submission -->
  <input type='hidden' name='redirect_to' value='<the complete return url e.g. http://fooey.com/thank-you.html>' />

  <!-- all your input fields here.... -->
  <input type='text' name='test' />

  <input type='submit' value='Test form' />
</form>
~~~
>Start tracking your form submissions from this url: http://getsimpleform.com/messages?api_token=&lt; api_token&gt; *You will also get an email whenever a new form entry is made*



Here is an example form: http://minhajuddin.com/hire-me ,Hope you find it useful
