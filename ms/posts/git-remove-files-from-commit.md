.. title: GIT: Remove files from commit
.. slug: git-remove-files-from-commit
.. date: 2015/06/20 12:00:40
.. tags: git
.. link: 
.. description: Remove files that you accidentally commit from git

There are [lot of ways][1] if you search for this, mostly involve in ammending the commit. But if you only accidentally added the files in a development/temporary branch, there's much simpler way than meddling around with the history.

When you merge branch, git will automatically commit all the changes from that branch. But there's a way to [stop that][2].

```
$ git merge new-layout --no-commit --no-ff
Automatic merge went well; stopped before committing as requested
kamal@thinkblack:~/python/harga
$ git status
# On branch new-layout-fixout
# Changes to be committed:
#
#       modified:   harga/models.py
#       modified:   harga/search_indexes.py
#       modified:   harga/templates/base.html
#       new file:   harga/templates/sidebar.html
#       new file:   scrapers/scrapers.db
```

Let say `scrapers/scrapers.db` is the file that we accidentally committed and we don't want it. Just remove it from the index:-

```
git reset HEAD scrapers/scrapers.db
```

Now the file has been removed, we can commit the rest of the changes.

[1]:http://stackoverflow.com/questions/12481639/remove-files-from-git-commit
[2]:http://stackoverflow.com/questions/8640887/git-merge-without-auto-commit
