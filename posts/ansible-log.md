<!-- 
.. link: 
.. description: 
.. tags: ansible, sysadmin, devops, python
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

<div class="sidebar">
<p class="first sidebar-title">What is virtualenv & pip ?</p>
<p class="last">
    Virtualenv allow you to create isolated python environment and pip is
    command line tools to download Python packages from websites such as
    PyPI.
</p>
</div>

Fortunately it's still installable through pip and also work inside virtualenv.  
Running buildout under virtualenv still raise `SandboxViolationError` though.  Enough rant, let's get started:-

    virtualenv test-ansible
    cd test-ansible
    ./bin/pip install ansible

I spent quite sometime reading ansible docs to finally grasp the concept of 
inventory. It's a place (a text file) where you define all the servers you want 
to manage. By default ansible will look in `/etc/ansible/hosts` file. You can 
change this through configuration file [$HOME/.ansible.cfg][ansible-cfg] and 
set the value [hostfile       = /etc/ansible/hosts][ansible-cfg2].

```yaml
- hosts: pipz
- name: Add main user
  user: name=kamal
        home=/home/kamal

- name: Set up authorized key for kamal
  authorized_key: user=kamal
                  state=present
                  key="{{ item }}"
  with_file:
    - /home/kamal/.ssh/id_rsa-do.pub
```

Error: Host declaration is required

[Missing tasks][10]

```yaml
- hosts: pipz
  tasks:
    - name: Add main user
      user: name=kamal
            home=/home/kamal

    - name: Set up authorized key for kamal
      authorized_key: user=kamal
                      state=present
                      key="{{ item }}"
      with_file:
        - /home/kamal/.ssh/id_rsa-do.pub
```

    ./bin/ansible-playbook main.yml -i ansible_hosts.ini -u root

http://lextoumbourou.com/blog/posts/getting-started-with-ansible/#part-3

[ansible-cfg]:http://www.ansibleworks.com/docs/faq.html#id7
[ansible-cfg2]:https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg
[10]:https://groups.google.com/forum/#!topic/ansible-project/QFDzbr3vGD0
