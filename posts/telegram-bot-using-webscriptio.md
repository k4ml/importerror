<!-- 
.. title: Telegram bot using webscript.io
.. slug: telegram-bot-using-webscriptio
.. date: 2015/07/15 12:28:01
.. tags: lua, telegram, webscript
.. link: 
.. description: Building Telegram bot using webscript.io service in Lua programming language.
.. type: text
-->

Telegram recently released their official Bot API. It make writing bot so easy compared to building your own client using the client API.

The only requirement for your bot is that an HTTPS endpoint that you can tell TG where to forward the incoming message from user. Being an HTTPS endpoint, it mean you need to have a valid SSL cert for your domain (if you haven't got one yet).

Another option is to use free hosting that provide you with HTTPS endpoint. There are a number of them. Among others:-

* Heroku - Provide HTTPS endpoint for .herokuapp.com
* Openshift - https://yourname-appname.rhc-cloud.com/
* Google App Engine - https://yourname.appsppot.com/

To test directly from your laptop, use service such as ngrok.com.

But in this post I want to mention another alternative that is using [webscript.io][2] script as endpoint for TG bot. After signing up to the service, just create new Lua script like below:-

<script src="https://gist.github.com/k4ml/502f63ed1f5a63e9b5fe.js"></script>

Then you need to create your bot using [BotFather][1] through your Telegram app. Once you get the auth token, replace `tg_token` variable in the script above with your auth token. Before the script can start accepting messages from Telegram, you need to tell TG using the `setWebhook` API method. So you have to make a request to the webscript endpoint yourself like:-

    curl 'https://demo-xxxx.webscript.io/script?admin_command=setURL&pass=xxxx'

If there's no error, all set now. You can also check the logging that Webscript.io provide to check for any error.

<img src="http://i.imgur.com/EDayXoc.png"></img>

The only downside of Webscript.io is that it's not free. The script created under the free account will only last for 7 days. With the same amount of money, you can get a small VPS from Digital Ocean to run the bot + some other stuff as well. But if you're not interested in maintaining another server then this is a great service. This can also be your great excuse to learn Lua ;)

[1]:https://core.telegram.org/bots#botfather
[2]:https://www.webscript.io/
