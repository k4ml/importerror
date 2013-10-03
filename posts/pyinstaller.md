<!-- 
.. link: 
.. description: 
.. tags: python, deployment, notes
.. date: 2013/10/01 23:26:00
.. title: PyInstaller
.. slug: pyinstaller
-->

Quick look into [pyinstaller].

Installation and usage straight forward - <https://github.com/k4ml/test-pyinstaller>

<!--TEASER_END -->

## Single file
Generate single executable script in `./dist`:-

```console
pyinstallers --onefile script.py
```

## Extra Paths
If your libraries exists in some non standard path such as the system `site-packages` you can specify it using the `-p` option:-

```console
pyinstallers --onefile -p /path/to/mylib script.py
```

## Hidden Import
If your app (or libries you depend on) doing dynamic import, such as using `__import__` function, pyinstaller would not be able to detect that in it's static analysis and the module would be missing in the final executable. To help pyinstaller discover these modules, it provide hook mechanism but I failed to get it work. Passing the module name through command line options did work however:-

```console
pyinstallers --onefile -p /path/to/mylib --hidden-import=awscli.converters script.py
```

For a few hidden import, above is fine but as the number grow, passing it as command line option quickly getting out of hand. The hook mechanism provide utility function that can discover all sub-modules.

## Data Files
This is the show stopper when you need to bundle third party libraries not under your control. If the library need to access data file, it has to be aware that it running under pyinstaller and make [some adjustment to the file path][1].

[pyinstaller]: http://www.pyinstaller.org/
[1]:http://stackoverflow.com/questions/7674790/bundling-data-files-with-pyinstaller-onefile
