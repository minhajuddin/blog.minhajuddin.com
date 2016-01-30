title: Removing duplication in ERB views using content_for
date: 2016-01-30 18:56:35
tags:
- DRY
- Duplication
- ERB
---

While writing code to show themes in Zammu, I had to show the same button in two places on the same page.
The easy way is to duplicate the code. But that causes problems with maintainability.

e.g.

~~~html
<%= content_for :secondary_nav do %>
  <!-- <<<<<<<<<<<<<<<<<<<<<<<<< FIRST COPY -->
  <%= form_tag("/") do %>
    <button class='btn btn-lg btn-primary push-top-10'>Looks good, let's clone this</button>
  <% end %>
<% end %>

<div class="row">

  <div class="col-md-4">
    <div class="thumbnail">
    ...
    </div>
  </div>

  <div class="col-md-8">
    <dl>....</dl>
    <!-- <<<<<<<<<<<<<<<<<<<<<<<<< SECOND COPY -->
    <%= form_tag("/") do %>
      <button class='btn btn-lg btn-primary push-top-10'>Looks good, let's clone this</button>
    <% end %>
  </div>

</div>
~~~

To remove duplication I just used a `content_for` and captured the code that had to be duplicated and used `yield` to spit it out in the two places.
The changed code is:

~~~html

<%= content_for :clone_btn do %>
  <%= form_tag("/") do %>
    <button class='btn btn-lg btn-primary push-top-10'>Looks good, let's clone this</button>
  <% end %>
<% end %>

<%= content_for :secondary_nav do %>
  <!-- <<<<<<<<<<<<<<<<<<<<<<<<< FIRST COPY -->
  <%= yield(:clone_btn) %>
<% end %>

<div class="row">

  <div class="col-md-4">
    <div class="thumbnail">
    ...
    </div>
  </div>

  <div class="col-md-8">
    <dl>....</dl>
    <!-- <<<<<<<<<<<<<<<<<<<<<<<<< SECOND COPY -->
    <%= yield(:clone_btn) %>
  </div>

</div>
~~~

Now if I have to change the button, I have to do it only in one place. Our code is DRY as a bone :)
