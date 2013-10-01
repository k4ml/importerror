<!-- 
.. link: 
.. description: 
.. tags: draft
.. date: 2013/10/01 07:57:32
.. title: Django REST framework
.. slug: django-rest-framework
-->

Has multiple parser for incoming data. By default can accept the traditional `x-www-form-urlencoded` and json formatted data.
We should use request.DATA since this contain data coming from PUT, POST and PATCH method. 
request.POST will only contain POSTed data.
The following request should be equivalent:-

    curl -H 'Content-Type: application/x-www-form-urlencoded' -d 'name=kamal&addres=jb' -X PUT http://localhost:8000/api/talents/12345678/

request.DATA:-

    <QueryDict: {u'name': [u'kamal'], u'addres': [u'jb']}>

    curl -H 'Content-Type: application/json' -d '{"name": "kamal", "address": "jb"}' -X PUT http://localhost:8000/api/talents/12345678/

request.DATA:-

    {u'name': u'kamal', u'address': u'jb'}

List of supported parsers is stored in `request.parsers`

```ipython
request.parsers
[<rest_framework.parsers.JSONParser object at 0x3020210>, <rest_framework.parsers.FormParser object at 0x3020110>, <rest_framework.parsers.MultiPartParser object at 0x3020250>]
```
