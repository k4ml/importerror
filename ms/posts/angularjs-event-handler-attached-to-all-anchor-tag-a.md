<!-- 
.. link: 
.. description: 
.. tags: javascript, angularjs
.. date: 2013/11/18 01:19:58
.. title: Angularjs: Event handler attached to all anchor tag 'a'
.. slug: angularjs-event-handler-attached-to-all-anchor-tag-a
-->

Noticed today that angular [modify the behavior][1] of 'a' tag to include some event handler by default. Discover this after getting error `Object #<g> has no method 'on'` error in my dev console. The error actually showing up after I added jquery to the page but the fact that angular attaching event to all 'a' tag really suprising. I have some 'normal' links I don't want any fancy behavior, just a link. Found a [post on how to create new directive to disable the behavior][2] but for now I manage to escape from this by simply not using angular together with jquery.

[1]:http://docs.angularjs.org/api/ng.directive:a
[2]:http://badwing.com/angularjs-heavy-handed-anchor-tag-disable-directive/
