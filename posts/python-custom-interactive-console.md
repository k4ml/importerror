<!-- 
.. link: 
.. description: 
.. tags: python
.. date: 2014/01/13 21:34:23
.. title: Python: Custom Interactive Console
.. slug: python-custom-interactive-console
-->

While working on new features that consist of web frontend and a backend API, I found
a constant need to manipulate the backend API through python interactive console.
Ideally I should implement a command line interface that I can use while waiting for the web frontend to finish but since the API (a class) already has structured methods to access all the API functionalities, a cli interface will just duplicating most of the class API methods.

What tedios when accessing the API through python interactive console is having to re-import all the objects that you need every time you start the interactive console. So an idea pop up - why not create my own custom interactive console with all the objects that I need pre-imported. In python, creating your own interactive console is [trivial][1]. The code module has all that you need.

```python
import code

# SomeClass will be available in the interactive console
from yourmodule import SomeClass

vars = globals()
vars.update(locals())
shell = code.InteractiveConsole(vars)
shell.interact()
```

While simple and just few lines of code, above is not really useful. It doesn't have auto complete and no history, you can't use up/down arrow key to repeat the previous command. A better version:-

```python
import code
import readline
import rlcompleter

# SomeClass will be available in the interactive console
from yourmodule import SomeClass

vars = globals()
vars.update(locals())
readline.set_completer(rlcompleter.Completer(vars).complete)
readline.parse_and_bind("tab: complete")
shell = code.InteractiveConsole(vars)
shell.interact()
```
Above is much nicer. Now you have auto complete (type `Some<Tab>` and you got `SomeClass`). Cool. But I immediately noticed that the history was not preserved, mean that when I closed the console and start again, it's in blank slate. I can't repeat command in previous session. This actually how the default python console work but I'd already have `~/.pythonrc.py` that I defined as `PYTHONSTARTUP` to [setup the tab completion and command history][2]. It seem that my pythonrc.py not being processed by this custom console.

Noticing that the python console from django `manage.py shell` working correctly with my pythonrc.py, I'd take a look at the [implementation code][3]. Look like django has to process PYTHONSTARTUP manually. I'm not really keen on copy-pasting the code from django but there's no way to pass your current enviroment into the console that django created.

In the end, I have to copy the django code into my console function:-

```python
import code
import readline
import rlcompleter

# SomeClass will be available in the interactive console
from yourmodule import SomeClass

vars = globals()
vars.update(locals())
readline.set_completer(rlcompleter.Completer(vars).complete)
readline.parse_and_bind("tab: complete")

# copied from django.core.management.commands.shell
for pythonrc in (os.environ.get("PYTHONSTARTUP"),
                 os.path.expanduser('~/.pythonrc.py')):
    if pythonrc and os.path.isfile(pythonrc):
        try:
            with open(pythonrc) as handle:
                exec(compile(handle.read(), pythonrc, 'exec'))
        except NameError:
            pass

code.interact(local=vars)
```

I found that working directly in the console like this motivate me to write better docstring for each functions and methods as I'd constantly using the help() function to figure out what each function/class/methods are doing. This seem to be much better than having to write dedicated cli interface for your API.

[1]:http://stackoverflow.com/questions/19754458/open-interactive-python-console-from-a-script
[2]:http://sontek.net/blog/detail/tips-and-tricks-for-the-python-interpreter
[3]:https://github.com/django/django/blob/master/django/core/management/commands/shell.py#L67
