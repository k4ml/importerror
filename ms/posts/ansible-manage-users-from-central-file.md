<!-- 
.. title: Ansible: Manage users from central file
.. slug: ansible-manage-users-from-central-file
.. date: 2015/04/01 23:30:52
.. tags: ansible
.. link: 
.. description: 
.. type: text
-->

I want to achieve this kind of playbook:-

```yaml
- name: Development server
  hosts: devserver
  sudo: true
  vars_files:
    - data/users/users.yml
  vars:
    - users:
        - "{{ all_users.ali }}"
        - "{{ all_users.kamal }}"
  roles:
    - development
    - mysql-client
    - users
    - common
```

Users should be defined in a central file but in playbook for each hosts, I should be
able to mix and match users like above. The file `data/users/users.yml` above look like:-

```yaml
all_users:
    ali:
        username: ali
        name: Ali Ahmad
        groups: ['admin']
        ssh_key:
          - "ssh-dss AAAA ..."

    kamal:
        username: kamal
        name: Kamal Mustafa
        groups: ['admin']
        ssh_key:
          - "ssh-rsa AAAA ..."

users_deleted:
    - user1
    - user2

```
Initially I used [ansible-users](https://github.com/mivok/ansible-users/blob/master/tasks/main.yml) roles but
it has users defined in `group_vars` file. It allow me to separate users by group but that also mean if some
users exists in multiple groups, I have to repeat defining the user data.

My first attempt then look like this:-

```yaml
- name: Development server
  hosts: devserver
  sudo: true
  vars_files:
    - data/users/users.yml
  roles:
    - development
    - mysql-client
  
  tasks:
    - include: tasks/add_user.yml accounts_to_add={{ all_users }}
    - include: tasks/common.yml users={{ all_users }}
    - include: tasks/delete_user.yml accounts_to_delete={{ deleted_users }}
```
With `data/users/users.yml` defined as:-

```yaml
all_users:
    - ali
    - kamal
    - aman
```
And the tasks `add_user.yml` was very clunkyly defined:-

```yaml
---
  
- name: Create user
  user: home=/home/{{ item }} name={{ item }} shell=/bin/bash state=present
  with_items: accounts_to_add
  
- name: Add SSH key
  authorized_key: user={{ item }} key="{{ lookup('file', playbook_dir + '/data/users/' + item + '/key.pub') }}"
  with_items: accounts_to_add
  tags: ['user-config']
  
- name: Lock user {{ item }}
  command: usermod --lock {{ item }}
  with_items: accounts_to_add
  tags: ['user-config']
```
Had to deal with the `lookup()` issue where it keep giving errors:-

    fatal: [devserver] => A variable inserted a new parameter into the module args. Be sure to quote variables if they contain equal signs (for example: "{{var}}").

The answer actually already there, you have to quote the `lookup(...)` but I spent hours looking for solution,
the price has to pay when you didn't read error message properly, sigh ...

I'm not really satisfied with this solution since it mean for every playbook, you'll keep repeating the tasks
section. [ansible-users] roles is better here since you just include the roles and the users variables being
inferred automatically. So I keep searching for solution to split `group_vars` file until I realized can reference
variables in the playbook.
