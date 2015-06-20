<!-- 
.. link: 
.. description: 
.. tags: javascript
.. date: 2013/12/04 01:54:03
.. title: Javascript Self Invoking Function
.. slug: javascript-self-invoking-function
-->

While peeking into Twitter [Bootstrap js][1] code, I noticed function being defined like this:-

```javascript
+function ($) { "use strict";

    // ALERT CLASS DEFINITION
    // ======================

    var dismiss = '[data-dismiss="alert"]'
    var Alert   = function (el) {
      $(el).on('click', dismiss, this.close)
}
...
```
Noticed the `+` sign before the keyword `function`. At first I thought it could some typo slipping through the commit but after some google, it turn out that [just another way][2] to define self invoking function in JavaScript. Those who has been writing some JavaScript, or deal with some JS library probably already familiar with a common idiom to write code like below:-

```javascript
(function($) {
    $('#some_dom_id').click( ....);
})(jQuery);
```

<!--TEASER_END -->
Above also a self invoking function. The primary reason the code being written this way is to avoid introducing unnecessary variable to the global scope. JavaScript does not has namespace so any variable defined in any part of the code (except those in function prefixed with `var`) exists as global variable. Since most code, except for (libraries) only need to manipulate the dom and does not need to expose any variables for others to use, it best if we can execute the code in isolation without adding new state to the global scope (window).

The only isolation exists in JavaScript is the function scope and since JavaScript support anonymous function, this can be a perfect match. Just define an anonymous function and immediately call the function. Logically, we'll try to define function like this:-

```javascript
function () {
    alert('hello');
}();
```
This however would result in syntax error since the parser expect an identifier (name) after the function keyword. In other word, above code is a statement rather than an expression that create some value. Fortunately in JavaScript, anything that we wrap inside a parantheses will be treated as an expression and JavaScript will evaluate the expression, yielding it's value. For example, `(1)` will yield a value `1` while `(1 + 1)` will yield a value `2`. So what if try to evaluate a function ?

```javascript
(function () { alert('hello'); });
```

It will yield a function as a result, which what we want. In above code, the parser will know that inside the parantheses is an expression and it should evaluate it, just like it evaluate 1 + 1 and produce 2. So what the result of evaluation function expression ? A function. So now we have a function at hand, we can call it.

```javascript
(function () { alert('hello'); })();
```
Now we know the story behind the cryptic syntax of JavaScript code commonly found on the Net. But it turn out that defining function inside a parantheses is not the only way to tell the parser to treat it as function expression instead of statement. We can also prefix the function with some arithmetic operator and the parser will happily treat it as an expression. So the above code can also be written like this:-

```javascript
+function () { alert('hello'); }();
```

[1]:https://github.com/twbs/bootstrap/blob/8a74264344489e8b9e10c5c5e2098bb75116b8bd/js/alert.js#L21
[2]:http://stackoverflow.com/questions/13341698/javascript-plus-sign-in-front-of-function-name
