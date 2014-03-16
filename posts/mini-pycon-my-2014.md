<!-- 
.. title: Mini PyCon MY 2014
.. slug: mini-pycon-my-2014
.. date: 2014/03/16 08:19:20
.. tags: draft, pycon, python
.. link: 
.. description: 
.. type: text
-->

This is the first mini PyCon held in Malaysia so congratulation to the [team][1] that
finally make it happened. It just 1 day event filled with tracks on various topic
related to python. Due to the space limitation, all sessions being held serially in
a single room. Having attend a number of PyCon APAC last time in SG, I'm quite happy
that I managed to follow all the sessions in this mini pycon. It quite frustrating when
you have to decide between two interesting sessions because it run in parallel in two
different places. Below are some quick notes from the sessions that I managed to recall.

* Sphinx and Read The Docs - Eric Holscher
    - Defacto documentation tools in Python Community.
    - While RTD and Sphinx are both valuable tools that we have in Python,
      I can't really stand RST for writing. It kind of Latex where everytime I need
      to write, I have to read the documentation again to look for all the syntax.
    - I have only used RTD once in the past, for writing my [unfinished book](http://asas-django.rtfd.org)
      on django.

* Python on Google App Engine - Desmond Lua
    - Quite an interesting talk.
    - Everything you did probably would cost money so you have to give extra
      attention on how you write your app.
    - I had a thought of moving [Cari Harga Barang](http://harga.smach.net) to App Engine
      in order to save some money on the hosting and also the time to manage it but look
      like it will cost more with App Engine since there's lot of write operations to store
      all the items and keep it updated daily.

* Boosting Productivity with IPython - Boey Pak Cheong
    - Finally, I had a visual on what Ipython Notebook really is. In fact, in the
      later talk, the presenter was using IPython Notebook to show and demonstrate
      his python code snippet.

* Python Powered Cloud - Joseph Ziegler
    - This imo the most interesting talk.
    - I have long heard about Elastic Beanstalk (EB) but never had a chance to give it a try.
    - EB probably what I have been looking on how to deploy our apps.
    - The only downside of EB is that it based on RHEL which mean for
      organization that been using Ubuntu, it will be a huge leap to migrate.
    - Another cool stuff shown in this talk, the [bees army](https://github.com/newsapps/beeswithmachineguns).
      It being used to DDOS the website in order to demo how EB auto scaling work. Still
      wondering how this thing went out of my radar ;).

* Python in Embedded and Robotics Development - Yap Wen Jiun
    - I'm not into robotic (yet), maybe until my kid ready to play around
      with computer and all the stuff.
    - There's a kind of OS for robotic stuff call [ROS](http://wiki.ros.org/).

* Creating Powerful RESTful API Services with Django Tastypie - Leong Seh Hui
    - We used Django Rest Framework for one of our app in development.
    - The speaker however never used DRF so unable to get his insight on the
      differences between both framework.
    - Looking at [Why Tastypie section](https://github.com/toastdriven/django-tastypie#why-tastypie)
      which say 'You DON'T want to have to write your own serializer to make the output right.',
      ok, that sound true.
    - Tastypie way of hooking the Resource into urls.py also captured my attention since it
      look similar to what I'm doing with my little library [django-viewrouter](https://bitbucket.org/k4ml/django-viewrouter).

[1]:http://www.pycon.my/mini-pycon-my-2014/staff 
