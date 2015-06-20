<!-- 
.. link: 
.. description: 
.. tags: draft
.. date: 2014/01/30 18:46:13
.. title: Working with svn repo from git - git-svn
.. slug: working-with-svn-repo-from-git-git-svn
-->

Cloning:-
    
    git svn clone -s -r 600 https://your-domain.com/svn/project

Using `-r` to do shallow copy only at that point of svn revision. This help from pulling
your whole svn repo when it's quite big. Sometime I got revmap error of some kind, probably because it can't find the parent of the particular revision which is before rev 600. In this case I just specify slightly lower svn rev number and see if it go through.

    cd project
    git branch -a
    * master
      remotes/trunk

We can see that not all our svn branches get clone so next is to actually get all the branches that have been created since rev 600 since that probably contain the branch that you want to work on.

    cd project
    git svn fetch
    git branch -a
    * master
      remotes/135-feature1
      remotes/tags/release-1.21
      remotes/trunk

Now we have all the svn branches we want to work on. Let's start checking out the branch
and doing work in our local git branch:-

    git checkout -b 135-feature1-svn remotes/135-feature1

Above command create a local git branch from the remotes svn branch. We put suffix -svn to the branch name to avoid git complain `warning: refname '135-feature1' is ambiguous.` We can now make changes in the branch and commit it just like normal git repo. Once done we may want to commit back all the changes we've made to the main svn repo.

    # make changes, hack, hack
    git add .
    git commit -m 'new feature'
    # make changes again, hack, hack
    git add .
    git commit -m 'fix new feature'
    git svn rebase
    git svn dcommit

Committing back to svn is done using the `git svn dcommit` command. Always make a habit to `git svn rebase` first before committing to make sure we always in sync with the main svn repo. There's one thing I don't really like in above situation - dcommit basically send 2 commits back to the svn repo which are 'new-feature' and 'fix new feature'. This mean dcommit always recommit or replay back your git commit to the svn repo. I'd prefer to have single commit to svn.

Can't find native way to do above so what I did is I'd never work in the '135-feature1' branch directly. Instead I create another branch from that branch where I did the real work.

    git checkout -b 135-sub1 135-feature1
    # hack, hack
    git add .
    git commit -m 'fix sub1'
    # hack, hack
    git add .
    git commit -m 'fix sub2'
    git checkout 135-feature1
    git svn rebase
    git merge --squash 135-sub1
    git commit -m 'this commit will be send back to svn'
    git svn rebase
    git dcommit -n # make sure it will commit to the correct svn branch
    git dcommit
    git branch -d 135-sub1
