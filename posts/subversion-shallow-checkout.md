<!-- 
.. link: 
.. description: 
.. tags: subversion, svn, version control
.. date: 2013/09/25 03:39:26
.. title: Subversion shallow checkout
.. slug: subversion-shallow-checkout
-->

Usecase - we want to work on branch 155-new-dashboard and trunk only. Checking 
out the root repository will give us the whole repo with all the branches and 
tags. For a big repository, this will take sometime. To do shallow checkout, 
subversion provide the `--depth` [options][1] to the checkout command.

    svn co --depth immediates https://server.com/path/to/repo
    ls repo
    branches tags trunk
    # at this point all directories are empty
    svn up branches/155-new-dashboard
    cd trunk
    svn up --set-depth infinity

The catch is the last step. Simply doing `svn up` in trunk won't checkout 
anything. Fortunately, subversion allow setting up `--depth` in each 
sub-directory.

[1]:http://svnbook.red-bean.com/en/1.6/svn.advanced.sparsedirs.html
