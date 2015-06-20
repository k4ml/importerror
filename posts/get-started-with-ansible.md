<!-- 
.. link: 
.. description: 
.. tags: ansible, python, digital ocean, nginx
.. date: 2013/09/27 00:56:32
.. title: Get started with Ansible
.. slug: get-started-with-ansible
-->

[TOC]

[Ansible] is a configuration management tools, in the same space as [Puppet], 
[Chef], [Cfengine], [SaltStack] and [few others][1]. For so long being a 
developer and also wearing a sysadmin hat, I have try to avoid using any of 
these configuration management software, thinking they just added unnecessary 
complexity to your workflow. But after spending countles hours building 
automation script backed by Makefiles, bash, python with fabric, I started to 
value a dedicated tools for these tasks.

<!-- TEASER_END -->

The easiest way to get latest version of Ansible is by using python tools 
[PIP]. Begin by installing it using `apt-get` (Ubuntu 12.04):-

<div class="sidebar"><p class="first sidebar-title">Note</p>
This intentionally left other options to install ansible. I'll try in another
post detailing various we way can get ansible installed.
</div>
```console
sudo apt-get install python-pip
sudo pip install ansible
```

## Inventory
The first concept to understand in Ansible is the [Inventory], a plain text 
file where we keep list of hosts (servers) we want to manage. By default 
ansible will look at `/etc/ansible/hosts`. The content of the file should look 
like this:-

```console
cat /etc/ansible/hosts
[server1]
192.168.0.1:10022

[server2]
192.168.0.2:10022
```

The format can be more complex but above is enough for us to get started.  
Basically we define the server name and below it's hostname, either IP address 
or DNS name such as server1.com. By default ansible will connect using standard 
ssh port 22 but if your ssh running on different port, use the format 
`hostname:port`. The server name actually act as group so you can have more 
than 1 host in each action. Following also possible:-

```console
[web-servers]
web1.server.com
web2.server.com

[db-servers]
192.168.0.1
```
Now we can run our first ansible command:-

```console
ansible server1 -a '/bin/ls'
192.168.0.1 | success | rc=0 >>
dir1
dir2
```

The above simply run command `ls` on the remote server and print it output.  
This by no means useful enough or better than just plain ssh with command but 
think about running the command on few servers at the same time. The above 
command also bring us to next concept in ansible - [Module].

## Credentials
The above command will work only if you already setup password-less 
authentication to your server using ssh public key. Otherwise you have to tell 
ansible to use username/password authentication instead. For this you need 
`sshpass` to be installed:-

```console
sudo apt-get install sshpass
```

Then re-run previous ansible command by passing the extra options:-

```console
ansible server1 -a '/bin/ls' -u yourname -k
SSH password:
```

The option `-k` will prompt you to enter the password. If you already set up
SSH key but not using the default private, you can specify it through the command
line:-

```console
ansible server1 -a '/bin/ls' -u yourname --private-key /path/to/id_rsa-custom
```

## Module
Module basically what defined the ansible functionality. There are modules to 
run command (like above), add/remove user, install packages, copy files, 
provision new virtual machine instance such as AWS EC2 or Digital Ocean 
droplets and much more.

Through the command line, we can specify what module to run using `-m` option 
and the arguments that the module require through `-a` option, like we're doing 
above. If we don't specify `-m`, the default would be `command`. So both 
commands below are equivalent:-

```console
ansible server1 -a '/bin/ls'
ansible server1 -m command -a '/bin/ls'
```

## Playbook
[Playbook] is what really make ansible a configuration management software. It 
allow us to declaratively define what command to execute in order to configure 
our system. It use [YAML] for the file format. Let's try a very simple example,
define a playbook that create new user, setup ssh key and then install nginx 
webserver:-

```yaml
- hosts: server1
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

    - name: Upgrade apt packages
      apt: upgrade=yes
           update_cache=yes

    - name: Install common packages
      apt: pkg={{ item }}
      with_items:
        - build-essential
        - telnet

    - name: Install nginx
      apt: name=nginx

    - name: Start nginx
      command: service nginx start
```

Save the above playbook as `main.yml` and then we can execute it through 
command:-

```console
ansible-playbook main.yml -u root -i ansible_hosts.ini -k
```
That's all for now. I'll try to post more topics on ansible as I progress 
through my way learning it up.

## Notes

```console
<10.0.3.125> ESTABLISH CONNECTION FOR USER: ubuntu
fatal: [10.0.3.125] => to use the 'ssh' connection type with passwords, you 
must install the sshpass program
```

On minimal ubuntu installation, some required packages maybe not installed:-

```console
TASK: [Upgrade apt packages] ************************************************** 
failed: [10.0.3.125] => {"failed": true}
msg: Could not import python modules: apt, apt_pkg. Please install python-apt 
package.
```

We need at least `python-apt` and `aptitude` to be pre-installed on the remote
system.

[1]: http://alternativeto.net/software/puppet/
[Ansible]: http://www.ansibleworks.com
[Puppet]: http://puppetlabs.com/
[Chef]: http://www.opscode.com/chef/
[SaltStack]: http://saltstack.com/
[Cfengine]: http://cfengine.com/
[Module]: http://www.ansibleworks.com/docs/modules.html
[Inventory]: http://www.ansibleworks.com/docs/patterns.html
[PIP]: https://pypi.python.org/pypi/pip
[Playbook]: http://www.ansibleworks.com/docs/playbooks.html
[YAML]: http://en.wikipedia.org/wiki/YAML
