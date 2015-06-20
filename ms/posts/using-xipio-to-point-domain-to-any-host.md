<!-- 
.. link: 
.. description: Using xip.io to point domain to any ip address.
.. tags: dns, nginx
.. date: 2013/10/01 03:54:25
.. title: Using xip.io to point domain to any host
.. slug: using-xipio-to-point-domain-to-any-host
-->

When I first heard about it from [Armin Ronacher's twitter status][1] last 
year, I don't really get what problem it solve and how it can be useful.  
Working with a number of virtual instances from vagrant launched virtual machines 
or lxc container to instance of aws ec2 or digital ocean's droplet, all with 
varying IP address, I started to value something like xip. My /etc/hosts now 
has 90+ entries, some of it not used anymore. Everytime I have new instance to 
test with my app, I have to add new entry in /etc/hosts to point to that IP, 
and then forgot about it.

<!-- TEASER_END -->

[xip.io](http://xip.io) simply resolve any subdomain of it to the ip address included as part of 
the subdomain. For example let say you have an app running at server with IP 
address 10.0.0.1. The app has been configured to serve a domain called 
dev.myapp.com (using virtual host of the webserver). So that you can access the 
app using http://dev.myapp.com, you have to add in /etc/hosts the ip address of 
the server. Since dev.myapp.com is for development and it can be on any 
machine, adding it to your real dns server does not make sense so /etc/hosts a 
good fit for it. But that mean your /etc/hosts will quickly grow with list of 
entries that you might only use once.

So instead adding the IP to /etc/hosts, let xip.io resolve it. We can define the 
domain for xip.io as subdomain.[ip-address].xip.io and it will resolve to that 
[ip-address]. For example:-

    dev.myapp.com.10.0.0.1.xip.io      --------> 10.0.0.1
    dev.myapp.com.192.168.0.1.xip.io   --------> 192.168.0.1
    dev.myapp.com.124.108.16.53.xip.io --------> 124.108.16.53
    test.myapp.com.127.0.0.1.xip.io    --------> 127.0.0.1

To actually serve the above sites, we have to change our web server config a 
bit so it can consider the above willcard. For example, for nginx, the config 
should look like:- 

```console
server {
        root /usr/share/nginx/dev;
        index index.html index.htm;

        server_name ~^dev\.myapp\.com\.(.*)\.xip\.io$;
        ...
        ...
}
```
This kind of service, coupled with others such as localtunnel or pagekite would be really helpful and as Armin said in the tweet, should in every developers toolbox.

[1]:https://twitter.com/mitsuhiko/status/265515194099318785
