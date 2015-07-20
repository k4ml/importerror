<!-- 
.. link: 
.. description: This is to document a setup that I plan on a digital ocean droplet. It should allow us to host applications of different platforms to co-exists side by side.  
.. tags: php, python, hosting, WIP, devops, sysadmin
.. date: 2013/10/04 20:18:13
.. title: Hosting multiple apps at digital ocean droplet
.. slug: hosting-multiple-apps-at-digital-ocean-droplet
.. description: Make the best use of your Digital Ocean droplet by hosting multiple apps, be it PHP, Python, Ruby etc side by side.
.. previewimage: http://i.imgur.com/koVrXaN.jpg
-->

[TOC]

This is to document a setup that I plan on a digital ocean droplet. It should 
allow us to host applications of different platforms to co-exists side by side.  
This initially inspired by [dokku] setup but dokku still has some rough edges 
making it not ready yet for production setup. This setup simply eliminate 
[docker] and run application natively on the host instead inside a 
[container][lxc].

Based on diagram below, we'll use nginx as our frontend server. It'll not do 
much other than forwarding requests to the backend apps running on different 
port.  Each app will run inside specific user account so in theory it should 
allow us to host apps for multiple users. Some planning on port assignment is 
needed however in case you want to go in this route. For example user1 will use 
port range 10000 and user2 using port 11000 space.

If you want to skip the write up and straightly get your hand dirty, just
clone the [github repo] and fix all the path to suit your environment.

<!--TEASER_END-->

<a href="http://imgur.com/koVrXaN"><img src="http://i.imgur.com/koVrXaN.jpg" 
title="Hosted by imgur.com" /></a>

We'll start with installing all the required packages first. This assume you 
already logged to the server as root:-

```console
apt-get install nginx libapache2-mod-php5 php5-gd php5-sqlite python-dev
apt-get install python-virtualenv supervisor
update-rc.d apache2 disable
```
We disable apache from being started at startup since we're not going to use 
the default setup. Each apps will run their own minimal instance of apache.  
You'll see some errors after the installation, apache2 failed to start since 
nginx already used the port 80.

## Nginx
Open `/etc/nginx/nginx.conf, remove existing config and add the following 
config:-

```nginx
user www-data;
worker_processes 4;
pid /var/run/nginx.pid;

events {
        worker_connections 768;
        # multi_accept on;
}

http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;
        gzip_disable "msie6";

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
        include /home/user1/webapps/*/nginx/nginx.conf;
}
```
It's the last line that really matter so if you want to keep the existing 
config, just add the last line. Test the config by running `nginx -t`. If no 
errors shown, we're done with nginx.

## User
We'll keep all our apps in a specific user account. Begin by creating the user 
account:-

```console
adduser --disabled-login --gecos '' user1
```
We disabled user login since we're not going to log in to this account 
directly. The option `--gecos ''` will skip the interactive prompt asking for 
full name, phone number etc.

Switch to the newly created user to start setting up the initial app layout.

```console
su user1
mkdir -p /home/user1/webapps/drupal
mkdir -p /home/user1/webapps/drupal/apache2
mkdir -p /home/user1/webapps/drupal/nginx
mkdir -p /home/user1/webapps/drupal/app/public
```
We'll put all our apps inside a folder called `webapps` inside the user's home 
directory. Our first app will be a PHP app and I took [drupal] as an example.  
Before we can setup drupal, we have to configure our PHP environment first.

## PHP
Create a directory to hold the apache2 environment for our PHP app.

```console
cd /home/user1/webapps/drupal
# create minimal apache2 config
cat - > apache2.conf
ServerRoot /home/user1/webapps/drupal/apache2
Listen 10000
PidFile apache2.pid
LockFile apache2.lock
TypesConfig /etc/mime.types

LoadModule authz_host_module /usr/lib/apache2/modules/mod_authz_host.so
LoadModule dir_module /usr/lib/apache2/modules/mod_dir.so
LoadModule mime_module /usr/lib/apache2/modules/mod_mime.so
LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so
LoadModule php5_module /usr/lib/apache2/modules/libphp5.so

LogLevel info
ErrorLog "|cat"
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog "|cat" common

DocumentRoot "/home/user1/webapps/drupal/app/public"
<Directory "/home/user1/webapps/drupal/app/public">
  AllowOverride all
  Order allow,deny
  Allow from all
</Directory>

AddType application/x-httpd-php .php
DirectoryIndex index.html index.php
^D
```
Notice that we run this apache2 instance at port 10000. Now let's test running 
the instance:-

```console
apache2 -d /home/user1/webapps/drupal/apache2 -f apache2.conf -e info -DFOREGROUND
```
You should see the apache process running. Type `CTRL-C` to stop it. Even 
though we manage to run our apache instance now, it's still not accessible from 
outside yet. Let's configure nginx to proxy request from outside to this 
instance. Add our specific nginx config for our app in 
`/home/user1/webapps/drupal/nginx/nginx.conf`:-

```nginx
upstream user1-drupal { server 127.0.0.1:10000; }
server {
  listen      80;
  server_name drupal.mysite.com;
  location    / {
    proxy_pass  http://user1-drupal;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Port $server_port;
  }
}
```
Test our nginx config to make sure nothing go wrong and then restart it:-

```console
nginx -t
service nginx restart
apache2 -d /home/user1/webapps/drupal/apache2 -f apache2.conf -e info -DFOREGROUND
```
If nothing goes wrong, we can access our website now at 
http://drupal.mysite.com/. We should get Not Found error from browser. Add 
`index.php` to our public folder to verify we can properly execute PHP script.

To avoid having to type the lengthy command in order to start apache2, let's wrap
it into a simple script. Save it in `/home/user1/webapps/drupal/apache2/start.sh`:-

```bash
#!/bin/bash

exec apache2 -d /home/user1/webapps/drupal/apache2 -f apache2.conf -e info -DFOREGROUND
```
While our apache instance now running, it's not yet permanent, mean when we close our
console or our ssh connection drop, it will stop. We'll use process manager called
[Supervisor] to turn our apache2 process into a daemon.

### Drupal

## Supervisor
Create new supervisor config file in `/home/user1/etc/supervisord.conf`:-

```ini
logfile=/home/user1/var/logs/supervisor/supervisord.log
logfile_maxbytes=20MB
logfile_backups=10
loglevel=debug
pidfile=/home/user1/var/run/supervisord.pid
nodaemon=false
minfds=1024
minprocs=200

[unix_http_server]
file=/home/user1/var/run/supervisor.sock

[supervisorctl]
serverurl=unix:///home/user1/var/run/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[include]
files = /home/user1/webapps/*/supervisor/supervisor.conf
```
Next add supervisor config specific to our app in `/home/user1/webapps/drupal/supervisor/supervisor.conf`:-

```ini
[program:drupal]
command=pidproxy /home/user1/webapps/drupal/apache2/apache2.pid /home/user1/webapps/drupal/apache2/start.sh
autostart=true
autorestart=true
exitcodes=0
stdout_logfile=/home/user1/var/logs/supervisor/drupal.log
redirect_stderr=true
```
Above config allow us to manage the apache2 process using `supervisorctl` command:-

```console
supervisorctl -c ~/etc/supervisord.conf start drupal
supervisorctl -c ~/etc/supervisord.conf status
drupal                           RUNNING    pid 840, uptime 18:43:55
supervisorctl -c ~/etc/supervisord.conf stop drupal
drupal: stopped
```

There's one issue with running apache2 process under supervisor. Apache2 create a
child processes and supervisor cannot control all these child processes. That mean when
we stop the process using supervisor, the child processes will keep running and
servicing our website as usual. The workaround is to launch the process using `pidproxy`
as shown in the above config.

To easily manage the supervisor, download [this script][supervisord.sh] and put it in
`/home/user1/bin/supervisord.sh`. Then you should be able to control supervisord
daemon as:-

```console
$HOME/bin/supervisord.sh start
$HOME/bin/supervisord.sh status
$HOME/bin/supervisord.sh stop
```
This supervisord daemon is still not started when the server reboot. For now I'll just
call the script to start daemon from cron every 10 minutes:-

```console
crontab -l
# m h  dom mon dow   command
*/10 * * * * /home/user1/bin/supervisord.sh start
```

## Python
Python app should run inside a [virtualenv] to isolate it from system python. This
allow us to install packages required only for our app and changes to system wide
python packages shouldn't affect our app. For this example, we'll use [Mezzanine],
a Content Management System that quite popular in Python.

Add nginx config for our python app first. The file in `/home/user1/webapps/mezzanine/nginx/nginx.conf` should look like:-

```nginx
upstream user1-mezzanine { server 127.0.0.1:10001; }
server {
  listen      80;
  server_name mezzanine.mysite.com;
  location    / {
    proxy_pass  http://user1-mezzanine;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Port $server_port;
  }
}
```

```console
mkdir -p /home/user1/webapps/mezzanine/app
cd /home/user1/webapps/mezzanine
virtualenv venv
./venv/bin/pip install mezzanine
cd app
../venv/bin/mezzanine-project myproject
cd myproject
../../venv/bin/python manage.py createdb
../../venv/bin/python manage.py runserver 10001
```
Our python app running at port 10001 and nginx now would correctly proxied request
to http://mezzanine.mysite.com/ to the django development server running for
our app.

### Gunicorn
Django development server is not meant to run in production so in order to serve our
python app, we'll use [gunicorn], one of the many [WSGI] server available in Python.
Begin by installing gunicorn:-

```console
cd /home/user1/webapps/mezzanine/app
../venv/bin/pip install gunicorn
../venv/bin/gunicorn -b 127.0.0.1:10001 myproject.wsgi:application
```
Our app now being served through gunicorn but still have one problem. Gunicorn will
only run python files but not static files such as css, js or images. While we can
configure nginx to also serve the static files, I'd prefer not to do that since
the nginx process is a system wide process - it shouldn't do more than just proxying
the request to backend server. For now we'll took simple approach and serve the static
files as part of our python app. We need a little package call `dj-static` that provide
thin middleware to serve all the static files.

```console
../venv/bin/pip install dj-static
```
We have to modify our `wsgi.py` file a bit. Make sure it look like below:-

```python
import os

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
settings_module = "%s.settings" % PROJECT_ROOT.split(os.sep)[-1]
os.environ.setdefault("DJANGO_SETTINGS_MODULE", settings_module)

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

from dj_static import Cling
application = Cling(application)
```
Our python app running under gunicorn should be ready now. The final part is to manage
it under supervisor. Add new entry to our supervisor.conf file:-

```ini
[program:mezzanine]
command=/home/user1/webapps/mezzanine/venv/start.sh
directory=/home/user1/webapps/mezzanine/app
autostart=true
autorestart=true
exitcodes=0
stdout_logfile=/home/user1/var/logs/supervisor/mezzanine.log
redirect_stderr=true
```

## Ruby

## Issues

nginx: [emerg] could not build the server_names_hash, you should increase server_names_hash_bucket_size: 32
server_names_hash_bucket_size 64;

http://zroger.com/blog/apache-in-the-foreground/
http://supervisord.org/subprocess.html#pidproxy-program
https://github.com/kennethreitz/dj-static

[lxc]:https://blogs.oracle.com/OTNGarage/entry/linux_containers_part_1_overview
[supervisord.sh]:https://gist.github.com/k4ml/6846809/raw/085bbff60d4736cf89b63ce4716796e79b932739/supervisord.sh
[github repo]:https://github.com/k4ml/do-hosting
[dokku]:https://github.com/progrium/dokku
[drupal]:http://drupal.org/
[supervisor]:http://supervisord.org/
[virtualenv]:http://pypi.python.org/pypi/virtualenv
[Mezzanine]:http://mezzanine.jupo.org/
[gunicorn]:http://gunicorn.org/
[WSGI]:http://wsgi.readthedocs.org/en/latest/
