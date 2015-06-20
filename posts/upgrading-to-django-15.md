<!-- 
.. link: 
.. description: 
.. tags: python, django
.. date: 2013/09/25 08:21:52
.. title: Upgrading to Django 1.5
.. slug: upgrading-to-django-15
-->

In the process of upgrading our apps to Django 1.5 from 1.4. Discovered the 
following so far:-

* [URLField drop verify_exists 
parameter](https://docs.djangoproject.com/en/dev/releases/1.4/#django-db-models-fields-urlfield-verify-exists).
* New url tag syntax - we seem to use the old syntax a lot, fortunately [one line
sed can fix it][url-sed].
* Django form output changed a bit - we have test that check for output like `<input id="id_em" type="text" name="em"`. This has changed to `<input id="id_em" name="em" size="25" type="text"`. Can't find reference to this though.
* `settings.ALLOWED_HOST` now required if `DEBUG = False`. Without this settings, you'll
get [500 error without further output in the error log][1].

Of course the list of changes lot more but these were the one that affected us.

[1]:http://stackoverflow.com/questions/15128135/django-setting-debug-false-causes-500-error
[url-sed]:http://stackoverflow.com/a/15373978/139870
