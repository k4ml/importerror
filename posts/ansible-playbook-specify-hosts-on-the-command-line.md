<!-- 
.. link: 
.. description: 
.. tags: ansible, devops, sysadmin
.. date: 2013/10/07 07:28:10
.. title: Ansible-Playbook: Specify hosts on the command line
.. slug: ansible-playbook-specify-hosts-on-the-command-line
-->

While we can specify what hosts to run the command through `ansible` command-line
program, it's does not apply to `ansible-playbook` program. We always need to
specify the `hosts:` attribute in our [YAML] playbook. It mean if we were to run
someone's else playbook, we always have to edit the playbook to customize the hardcoded
`hosts:` attribute.

Googling for this, I found the [workaround] (which a great resource in itself to gain
insight what ansible capable for). We can use variables. So instead of the following
playbook:-

```yaml
- hosts: myhostname
  tasks:
    - name: Add user
      user: name=kamal
            groups=admin
            shell=/bin/bash
```
We can write it as:-

```yaml
- hosts: {{hosts}}
  tasks:
    - name: Add user
      user: name=kamal
            groups=admin
            shell=/bin/bash
```
And then run our playbook as:-

```console
ansible-playbook -u root --extra-vars="hosts=myhostname"
```

[YAML]:http://yaml.org/
[workaround]:https://gist.github.com/marktheunissen/2979474
