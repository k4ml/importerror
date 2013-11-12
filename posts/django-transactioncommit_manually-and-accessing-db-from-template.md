<!-- 
.. link: 
.. description: 
.. tags: python, django, db, transaction
.. date: 2013/11/12 03:37:17
.. title: Django: @transaction.commit_manually and accessing db from template
.. slug: django-transactioncommit_manually-and-accessing-db-from-template
-->

Bumped into this issue twice and because the first time it happened was almost a year ago, in different project, I'd already lost my mental note about it when it happened again for second time. Our views functions are wrapped inside `@transaction.commit_manually`, which look like below:-

```python
@transaction.commit_manually
def send_message(request):
    context = {}
    # do some stuff
    transaction.commit()
    return render(request, 'path/to/template.html', context)
```

This work flawlessly until recently, I need to add some logic in the template that need to check certain user's permission, before displaying the part. In the template, it just some function call that access db like:-

```
{% if user.can_see_this %}
<a href="#">Some link</a>
{% endif %}
```

Django now raise `TransactionManagementError` complaining I have pending commit/rollback. It doesn't make sense because I can verify that the line that executed `transaction.commit()` was reached in the views above. Only after reading through [this ticket][1] on django issue tracker, I'd immediately remember the real issue.

Turn out this caused by new behavior of django transaction in 1.3 and above. Before 1.3, transaction only marked as dirty if we did any write database operation but since 1.3 and above, any database operation will mark the transaction as dirty. So the following code
will work before 1.3:-

```python
@transaction.commit_manually
def sendmessage(request):
    transaction.rollback()
    user = User.objects.get(pk=1)
    return HttpResponse('OK')
```

All database operation now will mark the transaction as dirty and since we access the db in template - which happened during render after we called commit(), it obvious now why django complain we unclosed transaction.

It should be written like below:-

```python
@transaction.commit_manually
def send_message(request):
    context = {}
    # do some stuff
    response = render(request, 'path/to/template.html', context)
    transaction.commit()
    return response
```
[1]:https://code.djangoproject.com/ticket/18080
