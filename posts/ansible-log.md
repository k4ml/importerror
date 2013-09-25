<!-- 
.. link: 
.. description: 
.. tags: draft
.. date: 2013/09/25 02:34:04
.. title: Ansible log
.. slug: ansible-log
-->

Ansible is an example of clash between sysadmin and developer mentality.  
Sysadmin tend to think about system as a whole while developer always think 
about their specific apps. While developer want to isolate, sysadmin want to 
'propagate', if I can use such term.

I want to try ansible and see if it can be a better alternative to Fabric. The 
first thing to do of course to install it. Since I'd already have my deployment 
tools environment based on buildout, I want to install ansible using my 
buildout config, rather than making it system-wide, or even 'user-wide' (mean 
install it to my `$HOME` dir). I don't want to pollute my $HOME, let alone the 
system. It's impossible to install ansible with buildout since it want to write 
to `/usr/share/ansible` and buildout will raise `SandboxViolationError` 
exception.
