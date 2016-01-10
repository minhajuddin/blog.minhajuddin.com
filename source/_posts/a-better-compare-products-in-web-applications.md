title: A better compare view for products in web applications
date: 2012-10-10
tags:
- ecommerce
- diff
- ux
---

We, software developers use diffs all the time, to check how the code has changed over time. However, there are a lot of popular web applications which would benefit from a simple diff but don't use them. Whenever I try to compare two products on ecommerce sites they give me a nice table showing the differences, but to *actually* see what is different I have to read each cell to compare them.

![A popular indian ecommerce site](https://substancehq.s3.amazonaws.com/static_asset/5075a5d803b04d0d70001731/Selection_034.jpeg)

As you can see from the above screenshot most of the things being compared are the same. However there is no easy signal to the user (The yellow highlight was added by me)

Here is a diff of two versions of a readme from one of my projects

![Code diff](https://substancehq.s3.amazonaws.com/static_asset/5075a77003b04d129f00082f/Selection_036.jpeg)

You can see that there are 66 + 27 lines which are hidden from the view because they are the *exact same*. They don't matter to me because nothing has changed in those lines. However, in the product comparison, I *have* to read each and every feature to find the differences. It would be great to have these kind of diffs for product comparison. Just hide the features which are the same or show some kind of color coding which convey that two products have the same feature.
