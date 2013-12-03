<!-- 
.. link: 
.. description: 
.. tags: django, python
.. date: 2013/11/03 02:34:04
.. title: Django From Scratch
.. slug: django-from-scratch
-->

[TOC]

There are a lot of tutorials out there on Django and the official documentation also has one. For this post, I decided not to go through the typical route on how to get started with django. Let's 'ignore' the best practices and focus on what actually work and hopefully we can learn something along the way. So let's get started by downloading Django itself from the website.

<!-- TEASER_END -->

```console
$ wget -o django.tar.gz https://www.djangoproject.com/download/1.5.1/tarball/
$ tar xzf django.tar.gz 
$ ls
Django-1.5.1  django.tar.gz
$ ls Django-1.5.1/
AUTHORS  docs    INSTALL  MANIFEST.in  README.rst  setup.cfg  tests
django   extras  LICENSE  PKG-INFO     scripts     setup.py
```

What we're getting is called a Python package that supposed to be installed. But we're not going to install it, instead let just take what we really need. Take out the `django` directory and move to our current directory.

```console
$ mv Django-1.5.1/django .
```

One thing we should understand when get started with Django is that it's just Python. In Python the most important thing is to make sure we can import the module we want to use. Let's try to `import django`.

```console
$ python
Python 2.6.5 (r265:79063, Apr 16 2010, 13:09:56) 
[GCC 4.4.3] on linux2
Type "help", "copyright", "credits" or "license" for more information.

>>> import django
>>> django
<module 'django' from 'django/__init__.py'>
```

This is great, we 'have' django now so let's build some application with it. In any computer program, it's important to know what is the entry point to that program. In C program we have the `main()` function for example, in Java you specify a class for the JVM to load and that class must have the `static main()` method. So what is the entry point to django application ? There will be at least 2 entry points to django application. First let's called command line entry point (CLI) and second the WSGI entry point. Let's ignore what is WSGI and focus on executing django application from command line. This is the minimal python script that you can use to invoke django application:-

```console
$ cat main.py 
from django.core.management import execute_from_command_line

execute_from_command_line()
```

The filename can be anything but let's call it `main.py`. If you run that script with python, it will display a list of available sub-commands, along with some help message.

```console
python main.py
$ python main.py 
Usage: main.py subcommand [options] [args]
...
[django]
cleanup
compilemessages
createcachetable
dbshell
...
runserver
```

The sub-command we're interested with is the `runserver`. That will start a process that listen at port 8000 and ready to serve HTTP request. People call it web server, quite similar to that well known Apache. Of course this web server that come with Django is not meant to replace Apache and far from usable outside of this local machine but that will be in another post. Let's try to run the `runserver` command:-

```console
$ python main.py runserver
```

You'll get a message like this:-

    ImproperlyConfigured: Requested setting USE_I18N, but settings are not configured. You must either define the environment variable DJANGO_SETTINGS_MODULE or call settings.configure() before accessing settings.

So something not right, in order for Django to start up, you have to tell it how to configure itself. You have to provide some settings. The settings itself just another python module (there's another way to provide settings) which mean the module must be able to be imported from the python script that we use to run django. Let's create the settings module, name it `settings.py` (it can be anything):-

```console
$ touch settings.py
$ python
>>> import settings
>>> settings
<module 'settings' from 'settings.py'> 
```

Now that we have settings module in place, let's modify our `main.py`:-

```console
$ cat main.py
import os

from django.core.management import execute_from_command_line

os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'

execute_from_command_line()
```

Above, we hardcode the value of `DJANGO_SETTINGS_MODULE` environment variables to our settings module. Just like any environment variables, we can also specify it when we run our script:-

```console
$ DJANGO_SETTINGS_MODULE=settings python main.py
```

The result would be the same. Specifying the environment variables value on the command line without hardcoding allow us to specify different settings to our app with having to modify the code. That's one of the reason why django choose to use environment variables to store pointer to the settings. One typical usecase when you want to have different settings for development and production. Let's continue with our app:-

```console
$ python main.py runserver
ImproperlyConfigured: The SECRET_KEY setting must not be empty.
```

Django already come with list of [default settings][1] but apparently for this one, you have to specify it yourself. Let's ignore first what the purpose of this `SECRET_KEY`. So fix our settings module to have that:-

```console
$ cat settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
```

Run `runserver` again:-

```console
$ python main.py runserver
Validating models...

0 errors found
April 11, 2013 - 16:34:29
Django version 1.5.1, using settings 'settings'
Development server is running at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

Now django happily start the server. Let's try to access it:-

```console
$ curl http://localhost:8000/
Traceback (most recent call last):
  File "/usr/lib/python2.6/wsgiref/handlers.py", line 93, in run
    self.result = application(self.environ, self.start_response)
  File "/home/kamal/python/dthw/django/core/handlers/wsgi.py", line 255, in __call__
    response = self.get_response(request)
  File "/home/kamal/python/dthw/django/core/handlers/base.py", line 85, in get_response
    urlconf = settings.ROOT_URLCONF
  File "/home/kamal/python/dthw/django/conf/__init__.py", line 54, in __getattr__
    return getattr(self._wrapped, name)
AttributeError: 'Settings' object has no attribute 'ROOT_URLCONF'
[11/Apr/2013 16:37:55] "GET / HTTP/1.1" 500 59
```

The reason django gave you an error because you haven't tell yet django what to serve from your application. You can do this by providing a mapping between a set of url pattern to python function that will be called when the pattern match. Create a new python module, name it `urls.py` (once again, the name can be anything).

```console
$ cat urls.py
from django.http import HttpResponse
from django.conf.urls import patterns, url

def hello_world(request):
    return HttpResponse('Hello world')

urlpatterns = patterns('',
    url(r'^$', hello_world),
)
```

The module must have a name called `urlpatterns` that having a reference to the return value of function `django.conf.urls.patterns`. You call the function by passing 2 or more parameters, the first parameter can just be an empty string (explanation should be in another post), the rest of the parameters should be a tuple of 2 items - (pattern, function). It's recommended however to wrap the tuple through django provided function `url()` as it will provide you with more features that you will need as your application grow. The function can be a direct reference to function object (like above) or just a string of valid import path to the function. In the later case, django will try to import the function and then call it.

Once above is done, you can hook it into `settings.py` which now should look like:-

```console
$ cat settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
ROOT_URLCONF = 'urls'
```

`ROOT_URLCONF` should contain valid import path to our module that define the url mapping. Try to `runserver` and access our app again:-

```console
$ python manage.py runserver
```

On another console:-
    
```console
$ curl http://localhost:8000/
```

Unfortunately django still come up with 500 error. This is because django refuse to run our function through the development server with DEBUG settings set to False. This is to avoid you from running this crippled web server for production application. You should use Apache with `mod_wsgi` or any other production ready wsgi server out there. So let's fix the settings:-

```console
$ cat settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
ROOT_URLCONF = 'urls'
DEBUG = True
```

Now running the `runserver` and try accessing http://localhost:8000/ through browser or using curl will give the "Hello world" string. The takeout from this is that all the django need is just a function that it can call given a particular url. From that function you can do whatever you want as long as you return a valid value that is an instance of `django.http.HttpResponse` or it's subclass. Another important thing to know is that most of the settings require you to provide a valid python import path that django can use to import the required module. The module itself can be anywhere and django does not restrict you to any particular structure. As long as you can do `import somestuff`, that would be fine. How to make sure you module can be imported will be a point of another post though.

## Namespace
So far what we have been doing is defining python module in the same directory as the script that executing our application (`main.py`). The is the easiest to get started because nothing we have to do in order for python to be able to import our module. Most of the time python can import module or package defined in the same directory of the executing script. In our case we defined `settings.py` and in `main.py` it's importable as `settings`. Similar goes to `urls.py`. These (settings, urls) however are too generic name that can potentially conflict with other python modules once our app grow and we need to use more python libraries than just django. Python has [namespace] to solve this so why not we start using it before getting too deep with our app.

Create a new directory called `myapp` (or anything you wish) in the same directory containing `main.py`, `settings.py` and `urls.py`.

```console
$ mkdir myapp
$ ls
django  main.py  myapp  settings.py  urls.py
```

Then move `settings.py` and `urls.py` into the new directory.

```console
$ ls
django  main.py  myapp
$ ls myapp
settings.py  urls.py
```

`main.py` should remain outside as it is the entry point to our app and it will be much easier if it is not in the containing app. This way we can phrase it as `main.py` will call `myapp`, otherwise if we put `main.py` in `myapp`, then `myapp` has to call itself. While technically possible it will be much harder to explain. Django has done this in the beginning and has since corrected it in last few latest versions. In order for a directory to be recognised as valid python package (namespace), you have to provide a file named `__init__.py`. Most of the time it can be empty.

```console
$ touch myapp/__init__.py
```

Now we have to fix our settings a bit to reflect the new location of our modules. It should look like this:-

```console
$ cat myapp/settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
ROOT_URLCONF = 'myapp.urls'
DEBUG = True
```

`main.py` also need fixing:-

```console
$ cat main.py
import os

from django.core.management import execute_from_command_line

os.environ['DJANGO_SETTINGS_MODULE'] = 'myapp.settings'

execute_from_command_line()
```

## Views
So we know that django only need to call our function for any matched url and we defined that function in the same module we defined the url mapping - `urls.py`. This is fine for small app but splitting it into separate module is a good practice. So `urls.py` can just contain url mapping instead of mixing it with our application logic. Let's create new module to store our app function. We call it `views.py` but you can choose any name you like.

```console
$ cat myapp/views.py
from django.http import HttpResponse

def hello_world(request):
    return HttpResponse('Hello world')
```

Inside `urls.py` we import the views module and hook it into our url pattern:-

```console
from django.conf.urls import patterns, url

from myapp.views import hello_world

urlpatterns = patterns('',
    url(r'^$', hello_world),
)
```

## Models
Now come the hardest part to explain because of some 'hardcoding' django did to implement the functionality. Unlike views, url config or settings, the name for the module that contain models definition was hardcoded in django - it want you to name it as `models.py`. Django also use `models.py` to imply some other parts of the framework. Let's define our models:-

```console
$ cat myapp/models.py
from django.db import models

class Customer(models.Models):
    name = models.CharField(max_length=255)
```

After defining models, you have to tell django the package that contain this `models.py` module. Our settings should look like:-

```console
$ cat myapp/settings.py
$ cat myapp/settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
ROOT_URLCONF = 'myapp.urls'
DEBUG = True
INSTALLED_APPS = ('myapp',)
```

In short, what you define in `INSTALLED_APPS` basically just an import path to python package that contain `models.py` file. You can put all your models definition for your application in a single `models.py` but you maybe want to split it into multiple apps for better design. A common use case is when the `apps` can actually being reused in other project as well. It also not necessarily must be in the same directory as your current application. What important is it can be import by the python interpreter running your application. This will always true to third party libraries that you install such as from PyPI since that libraries will be installed in some other place on your system, not in your current project directory.

Since we started to use db, we must define our database credentials settings:-

```console
    $ cat myapp/settings.py
SECRET_KEY = "1+)O49,>}5!$+ 43*PN+2+=(2S'W*0^1_|76n{_"
ROOT_URLCONF = 'myapp.urls'
DEBUG = True
INSTALLED_APPS = ('myapp',)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'myapp.db',
    }
}
```

Once we configured `settings.INSTALLED_APPS` to have our app defined, we can run `syncdb` to let django create necessary database tables to store our models data:-

```console
$ python main.py syncdb
Creating tables ...
Creating table myapp_customer
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)
```

[1]:https://docs.djangoproject.com/en/1.5/ref/settings/
