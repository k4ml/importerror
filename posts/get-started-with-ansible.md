<!-- 
.. link: 
.. description: 
.. tags: draft, ansible, python, digital ocean
.. date: 2013/09/27 00:56:32
.. title: Get started with Ansible
.. slug: get-started-with-ansible
-->

[Ansible] is a configuration management tools, in the same space as [Puppet], 
[Chef], [Cfengine], [SaltStack] and [few others][1]. For so long being a 
developer and also wearing a sysadmin hat, I have try to avoid using any of 
these configuration management software, thinking they just added unnecessary 
complexity to your workflow. But after spending countles hours building 
automation script backed by Makefiles, bash, python with fabric, I started to 
value a dedicated tools for these tasks.

The easiest way to get latest version of Ansible is by using python tools 
[PIP]. Begin by installing it using `apt-get` (Ubuntu 12.04):-

```console
sudo apt-get install python-pip
sudo pip install ansible
```

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

[1]: http://alternativeto.net/software/puppet/
[Ansible]: http://www.ansibleworks.com
[Puppet]: http://puppetlabs.com/
[Chef]: http://www.opscode.com/chef/
[SaltStack]: http://saltstack.com/
[Cfengine]: http://cfengine.com/
