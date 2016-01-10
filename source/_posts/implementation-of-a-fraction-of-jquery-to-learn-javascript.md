title: Implementation of a fraction of jQuery to learn javascript
date: 2012-09-28
tags:
- jquery
- javascript
- learn
---

Today, I took a small session for a few of our trainees on javascript. And they wanted me to show the use of jQuery. One of them asked how jQuery is different than javascript. I demonstrated it by implementing a tiny fraction of jQuery. Hope it helps others understand javascript and jQuery better.

Here are the different versions of a calcuator.

###Version 1. Using jQuery 
~~~html
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
<script type="text/javascript">
  $(function(){
      $('#add').click(function(){
        var result = +$('#first-operand').val() + +$('#second-operand').val()
        $('#op').html(result);
      })
  })
</script>
<input type="text" id="first-operand" />
<input type="text" id="second-operand" />
<button id='add'>Add</button>
<div id="op">
  Result
</div>
~~~

###Version 2. Using plain javascript
~~~html
<script type="text/javascript">
  window.onload = function(){
    document.getElementById('add').onclick = function(){
      var result = +document.getElementById('first-operand').value + +document.getElementById('second-operand').value;
      document.getElementById('op').innerHTML = result;
    }
  }
</script>
<input type="text" id="first-operand" />
<input type="text" id="second-operand" />
<button id='add'>Add</button>
<div id="op">
</div>
~~~

###Version 3. Using our simple jQuery like code

~~~html
<script type="text/javascript">
  //Our tiny fraction of jQuery
  window.$ = function(id){
    var selectedElement = document.getElementById(id);
    return selectedElement;
  }
</script>
<script type="text/javascript">
  window.onload = function(){
    $('add').onclick = function(){
      var result = +$('first-operand').value + +$('second-operand').value;
      $('op').innerHTML = result;
    }
  }
</script>
<h2>Initial version using jQuery</h2>
<input type="text" id="first-operand" />
<input type="text" id="second-operand" />
<button id='add'>Add</button>
<div id="op">
</div>
~~~

###Version 4. Using a bit more jQueryesque code

~~~html
<script type="text/javascript">
  //Our tiny fraction of jQuery
  function JqueryElement(el){
    this.el = el;
    this.val = function(){
      return el.value;
    }
    this.click = function(callback){
      el.onclick = callback;
    }
    this.html = function(html){
      el.innerHTML = html;
    }
  }
  window.$ = function(id){
    var selectedElement = document.getElementById(id);
    return new JqueryElement(selectedElement);
  }
</script>

<script type="text/javascript">
  window.onload = function(){
    $('add').click(function(){
      var result = +$('first-operand').val() + +$('second-operand').val();
      $('op').html(result);
    })
  }
</script>
<h2>Initial version using jQuery</h2>
<input type="text" id="first-operand" />
<input type="text" id="second-operand" />
<button id='add'>Add</button>
<div id="op">
</div>
~~~

### Version 5. With chaining and jquery like onload syntax
~~~html
<script type="text/javascript">
//Our tiny fraction of jQuery
function JqueryElement(el) {
  this.el = el;
  this.val = function(newValue) {
    if (arguments.length > 0) {
      el.value = newValue;
      return this;
    }
    return el.value;
  }
  this.click = function(callback) {
    el.onclick = callback;
    return this;
  }
  this.html = function(html) {
    if (arguments.length > 0) {
      el.innerHTML = html;
      return this;
    }
    return el.innerHTML;
  }
}
window.$ = function(id) {
  if(typeof id == 'function'){
    //input argument is a callback function to be called on window.onload
    window.onload = id;
    return;
  }
  var selectedElement = document.getElementById(id);
  return new JqueryElement(selectedElement);
}

</script>

<script type="text/javascript">
  $(function(){
    $('add').click(function(){
      var result = +$('first-operand').val() + +$('second-operand').val();
      $('op').html(result);
    })
  })
</script>
<h2>Initial version using jQuery</h2>
<input type="text" id="first-operand" />
<input type="text" id="second-operand" />
<button id='add'>Add</button>
<div id="op">
</div>
~~~

This was just for demonstration purpose for our trainees. As they say nothing in programming is magic.
