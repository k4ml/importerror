<!-- 
.. title: Django: Where does the application start ?
.. slug: django-where-does-the-application-start
.. date: 2014/11/01 16:00:14
.. tags: django, wsgi, learn
.. link: 
.. description: 
.. type: text
-->

The key to understand any kind of application is to know where does it start. Until
then you'll keep banging your head, shooting in the dark and lastly, at the mercy
of Google when trying to debug or solve any issues you have.

Majority of web developers don't really know, or even care where actually their application
start. This particularly true for those developing in PHP which abstract most of the web parts
and it appear to developer they just writing a regular command line or desktop application.

For Django developer, you can probably ignore this throughout your dev carrier but knowing it
will help you a lot in.

Django application can start (at least) from 2 possible entry point. The first entry point is
through the development server and the second entry point is when you deploy it to production
web server, either `mod_wsgi`, `gunicorn`, `Paste`, `Rocket`, `Waitress`, `Circus` or dozen more
WSGI server you can find on PyPI. I can still remember the day when there's none pure Python
WSGI server exists (except CherryPy) and how I'd really envy Rails's community for having Mongrel.
That day has long gone.

Let's dive to the first entry point - when you run your django application through the
`manage.py runserver` command. Typical django application (as generated) by the `startproject` command
has a file called `manage.py` at the root of the project directory. This is the file that developer use
to interact with their application, doing things such as running development server, synching database
tables with the models definition, loading/exporting data and so much more.

If you peek into `manage.py`, it's pretty simple actually:-

```python
#!./bin/python
import os
import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "acara.settings")

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
```

They key line here is at line 10 where a function called `execute_from_command_line()` being called.
From here we can traverse to module `django.core.management` to find out what that function is doing.
If you're sure where the actual module is located, just open the python console and import the module
to inspect it's location:-


```console
$ python
Python 2.7.3 (default, Aug  1 2012, 05:16:07) 
[GCC 4.6.3] on linux2
Type "help", "copyright", "credits" or "license" for more information.

>>> import django.core.management
>>> django.core.management
<module 'django.core.management' from '/home../local/lib/...django/core/management/__init__.pyc'>
```
Now we know that module was in `$HOME/local/lib/python2.7/site-packages/django/core/management/__init__.py`.
This one thing I love in python. Everything is explicit. You can easily trace down where things comes from
without even having to understand the whole framework yet. In some other framework or languages where
implicit import is a norm, you'll have hard time tracing down where certain functions or variables comes from
until you know the mechanism of the framework.

Let's look what inside `django.core.management` module. The function `execute_from_command_line()` was defined
at the bottom of the source code. It just a wrapper to other function actually.

```python
def execute_from_command_line(argv=None):
    """
    A simple method that runs a ManagementUtility.
    """
    utility = ManagementUtility(argv)
    utility.execute()
```
`ManagementUtility` class however not really interesting. It just some logic to find out which command module to execute
based on user's command parameter. For `manage.py runserver`, the python module that will be executed is `django/core/management/commands/runserver.py`. So let's take a look into this module:-

```python
def get_handler(self, *args, **options):
        """
        Returns the default WSGI handler for the runner.
        """
        return get_internal_wsgi_application()
```
This is around line 56 in [current master on Github][get_handler]. The import at the top of the module look like this:-

```python
from django.core.servers.basehttp import get_internal_wsgi_application, run
```
So that would be our next target - `django/core/servers/basehttp.py`. The code is like this:-

```python
def get_internal_wsgi_application():
    """
    Loads and returns the WSGI application as configured by the user in
    ``settings.WSGI_APPLICATION``. With the default ``startproject`` layout,
    this will be the ``application`` object in ``projectname/wsgi.py``.
    This function, and the ``WSGI_APPLICATION`` setting itself, are only useful
    for Django's internal server (runserver); external WSGI servers should just
    be configured to point to the correct application object directly.
    If settings.WSGI_APPLICATION is not set (is ``None``), we just return
    whatever ``django.core.wsgi.get_wsgi_application`` returns.
    """
    from django.conf import settings
    app_path = getattr(settings, 'WSGI_APPLICATION')
    if app_path is None:
        return get_wsgi_application()

    try:
        return import_string(app_path)
    except ImportError as e:
        msg = (
            "WSGI application '%(app_path)s' could not be loaded; "
            "Error importing module: '%(exception)s'" % ({
                'app_path': app_path,
                'exception': e,
            })
        )
        six.reraise(ImproperlyConfigured, ImproperlyConfigured(msg),
                    sys.exc_info()[2])
```

So now we have the full trace of how from running the command `manage.py runserver`, which code is being executed. At this point,
it really helpful if we understand the basic of WSGI spec. Django, at the very core is nothing more than a WSGI application. The
basic of WSGI is like this:-

```python
def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return ['hello world']
```

And the whole Django framework basically just an expansion of above function. So let's see where does the above snippet from
Django would bring us:-

```
from django.core.wsgi import get_wsgi_application
```

```python
import django
from django.core.handlers.wsgi import WSGIHandler

def get_wsgi_application():
    """
    The public interface to Django's WSGI support. Should return a WSGI
    callable.
    Allows us to avoid making django.core.handlers.WSGIHandler public API, in
    case the internal WSGI implementation changes or moves in the future.
    """
    django.setup()
    return WSGIHandler()
```

In `django/core/handlers/wsgi.py`:-

```python
class WSGIHandler(base.BaseHandler):
    initLock = Lock()
    request_class = WSGIRequest

    def __call__(self, environ, start_response):
        # Set up middleware if needed. We couldn't do this earlier, because
        # settings weren't available.
        if self._request_middleware is None:
            with self.initLock:
                try:
                    # Check that middleware is still uninitialized.
                    if self._request_middleware is None:
                        self.load_middleware()
                except:
                    # Unload whatever middleware we got
                    self._request_middleware = None
                    raise
```

[get_handler]:https://github.com/django/django/blob/master/django/core/management/commands/runserver.py#L56
