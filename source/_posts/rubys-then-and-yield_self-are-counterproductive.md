title: Ruby's `then` and `yield_self` are counterproductive
date: 2020-05-19 22:08:07
tags:
- Ruby
- then
- yield_self
---

Ruby 2.6 has added a new method named `yield_self` (with an alias `then`), it is
supposed to be similar to Elixir/F#'s pipes but are really counter productive.

Compare the following examples:

```ruby
   base64_jwk = ENV['SSO_PARTNER_BASE64_JWK'] || raise("ENV SSO_PARTNER_BASE64_JWK missing")
   raw_jwk = Base64.decode64(base64_jwk)
   jwk_json = JSON.parse(raw_jwk)
   jwk = JOSE::JWK.from(jwk_json)
```
