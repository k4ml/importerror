<!-- 
.. link: 
.. description: 
.. tags: ansible, WIP, devops, sysadmin
.. date: 2013/10/08 04:02:25
.. title: Ansible: My Playbook
.. slug: ansible-my-playbook
-->

This is my first playbook that I manage to get it working. It's an achievement for me
as it showed that I started to get the concept around ansible:-

<!--TEASER_END -->

```yaml
- hosts: $hosts
  tasks:
    - name: Add main user
      user: name=kamal
            home=/home/kamal
            groups=sudo
            shell=/bin/bash

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
        - python-apt
        - telnet
        - vim

    - name: Set vim as default
      command: update-alternatives --set editor /usr/bin/vim.basic

    - name: Set up sudo
      action: template src=etc/sudoers.d/custom dest=/etc/sudoers.d/custom
                owner=root group=root mode=0440

    - name: Set up ssh
      action: template src=etc/ssh/sshd_config dest=/etc/ssh/sshd_config
                owner=root group=root mode=0644
      notify:
        - Restart sshd

    - name: Install nginx
      apt: name=nginx

    - name: Start nginx
      command: service nginx start

    #- include: playbooks/nginx.yml
    
  handlers:
    - name: Restart sshd
      action: service name=ssh state=reloaded
```

The next step is to make it more generic by parameterized certain such as username
and file name:-

```yaml
- hosts: $hosts
  gather_facts: no
  tasks:
    - name: Add main user
      user: name=$remote_username
            home=/home/{{ remote_username }}
            groups=sudo
            shell=/bin/bash

    - name: Set up authorized key for {{ remote_username }}
      authorized_key: user=$remote_username
                      state=present
                      key="{{ item }}"
      with_file:
        - '{{ ssh_public_key }}'

    - name: Upgrade apt packages
      apt: upgrade=yes
           update_cache=yes

    - name: Install common packages
      apt: pkg={{ item }}
      with_items:
        - build-essential
        - python-apt
        - telnet
        - vim

    - name: Set vim as default
      command: update-alternatives --set editor /usr/bin/vim.basic

    - name: Set up sudo
      action: template src=etc/sudoers.d/custom dest=/etc/sudoers.d/custom
                owner=root group=root mode=0440

    - name: Set up ssh
      action: template src=etc/ssh/sshd_config dest=/etc/ssh/sshd_config
                owner=root group=root mode=0644
      notify:
        - Restart sshd

    - name: Install nginx
      apt: name=nginx

    - name: Start nginx
      command: service nginx start

  handlers:
    - name: Restart sshd
      action: service name=ssh state=reloaded
```
Finally, I managed to modularized by splitting the tasks into separate files:-

```yaml
- hosts: $hosts
  gather_facts: no
  tasks:
    - include: playbooks/base.yml
    - include: playbooks/admin_user.yml
    - include: playbooks/nginx.yml
    
  handlers:
    - include: playbooks/handlers.yml
```

With the included files look like:-

```yaml
# base.yml
- name: Upgrade apt packages
  apt: upgrade=yes
       update_cache=yes

- name: Install common packages
  apt: pkg={{ item }}
  with_items:
    - build-essential
    - python-apt
    - telnet
    - vim

- name: Set vim as default
  command: update-alternatives --set editor /usr/bin/vim.basic

- name: Set up sudo
  action: template src=etc/sudoers.d/custom dest=/etc/sudoers.d/custom
            owner=root group=root mode=0440

- name: Set up ssh
  action: template src=etc/ssh/sshd_config dest=/etc/ssh/sshd_config
            owner=root group=root mode=0644
  notify:
    - Restart sshd
```

```yaml
# admin_user.yml
- name: Add main user
  user: name=$remote_username
        home=/home/{{ remote_username }}
        groups=sudo
        shell=/bin/bash

- name: Set up authorized key for {{ remote_username }}
  authorized_key: user=$remote_username
                  state=present
                  key="{{ item }}"
  with_file:
    - '{{ ssh_public_key }}'
```

```yaml
# nginx.yml
- name: Ensure nginx is installed
  apt: pkg=nginx-full state=present
  tags: nginx

- name: Ensure nginx is started
  service: name=nginx state=started
  tags: nginx
```
