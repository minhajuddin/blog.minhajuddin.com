title: If you have an API make it curlable
date: 2016-01-13 12:37:05
tags:
- api
- design
- curl
---

These days APIs are everythere which is a good thing. However, many APIs are very tedious. You can tell if your API is easy to use by looking at how simple it is to curl it.

Take an example of the below API call, it is from a [stripe blog post demonstrating their use of ACH payments](https://stripe.com/blog/accept-ach-payments). See how easy it is to read and understand the call? Why can't all APIs be like this?


~~~sh
curl https://api.stripe.com/v1/charges \
  -u sk_test_BQokikJOvBiI2HlWgH4olfQ2: \
  -d amount=250000 \
  -d currency=usd \
  -d description="Corp Site License 2016" \
  -d customer=cus_7hyNnNEjxYuJOE \
  -d source=ba_17SYQs2eZvKYlo2CcV8BfFGz
~~~

**Anyway, if you are trying to design an API, Please, for the love of all that is holy make it curlable**
