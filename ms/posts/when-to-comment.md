<!-- 
.. link: 
.. description: 
.. tags: coding
.. date: 2014/01/17 02:07:32
.. title: When to comment ?
.. slug: when-to-comment
-->

One of the question we faced up when writing code is when to put comment for our code. It''s already pretty well known that we should comment on the 'why' part, not the 'how'. While looking through our code for some code review, I found these few lines of code:-

```python
# make requests to the API and process response
resp = requests.post(url, data=json.dumps(payload), auth=auth, headers=headers)
if resp.status_code == 200:
    ...
...
```
Above I think is an example of unnecessary comment since it obvious from the code that we're making some request to a `url` and processing it's response. Good comment is something along this line:-

```python
# doing POST here since the API does not yet support PUT
resp = requests.post(url, data=json.dumps(payload), auth=auth, headers=headers)
if resp.status_code == 200:
    ...
...
```
In above illustrative situation, the request logically should be a PUT request but due to some REASON it has to be a POST. The REASON that is worthy for comment since it explain the WHY part. It help the next developer coming up to maintain this code when he probably has in mental state that the request in this section of code should be a PUT not POST. The comment help him to not start raising suspicious that this section of code now has a bug.

So this just one example of when to comment our code. I'll try to add more as I encountered more examples.
