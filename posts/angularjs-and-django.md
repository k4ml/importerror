<!-- 
.. link: 
.. description: 
.. tags: draft, angularjs, javascript, django
.. date: 2013/11/09 01:23:24
.. title: Angularjs and Django
.. slug: angularjs-and-django
-->

It's been 7 month since the last time I touched angularjs, based on my last commit on toy project I'm working on while delving into angular. That's mean trying to get into my state of mind 7 months ago, definitely not easy. One of the reason why you should document all the stuff that you did before you forgot about it. The code I wrote is not commented but fortunately skimming at it once again, I manage to grasp angular concept again.

Spent half an hour figuring out why my angular binding didn't work. Using the poor man debugger (alert()), I knew that my code didn't executed at all. Looked into chromium dev console and I can see error being thrown on. One nice thing with the error now, it include contextual link to angularjs documentation explaining the error. My app was including `$ngResource` but it was included in separate js file.

http://django-angular.readthedocs.org/en/latest/integration.html
http://stackoverflow.com/questions/11872832/how-to-respond-to-clicks-on-a-checkbox-in-an-angularjs-directive
http://jsfiddle.net/Vbahole22/HmfHy/
http://docs.angularjs.org/guide/bootstrap
https://github.com/k4ml/myfuddle
