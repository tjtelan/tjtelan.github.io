+++
title = "Pip and bottle.py on NearlyFreeSpeech"
date = 2013-12-06
[taxonomies]
tags = ["freebsd", "python", "bottle.py", "nearlyfreespeech", "web-development"]
categories = ["howto"]
+++
The biggest reason I like using nearlyfreespeech is the ability to prepay my hosting costs. The biggest downside (compared to other hosts) is a lack of straight-forward flexibility for my choice of web development environment. I appreciate the security-focused approach in how they offer features, but I can't say that it is always comfortable as a casual user.

* NFS has lots of language support, but non-PHP web development is only supported through CGI)

I've been looking to try out bottle.py (partly because of their routing and partly because Django is not well supported on NFS as of this writing). I did my best to look for some examples online, but came up with only bits and pieces of the solution.

Here is how the environment was set up on [NearlyFreeSpeech.net][nearlyfreespeech]:

### Install pip

I prefer using `pip` over `easy_install`, so here's how to install that:

```sh
## Create your local site-packages directory.
# In NFS's environment, this will end up being /home/private/.local
$ mkdir -p ~/.local/lib/python2.7/site-packages
## Automatically add this location to your execution path at login. Just for convenience.
$ echo 'PATH=~/.local/bin:$PATH' >> ~/.profile
## Reload your .profile
$ source ~/.profile
## Use easy_install to install pip
$ easy_install --prefix=~/.local pip
## Now we can use pip to install bottle.py
$ pip install --user bottle
```

This installed bottle.py in /home/private/.local/bin. Just for example
purposes, I copied this into my site-root so I wouldn't have to play with
python's sys.path. *Use your own judgement*.

```sh
$ cp ~/.local/bin/bottle.py /home/public
```

At this point, I was able to find a relevant [stackoverflow question][stackoverflow] specifically dealing with bottle.py and cgi.

The code is mostly unchanged (I added the shebang at the top), but I'll copy it here for copypasta purposes. Put bottle script and .htaccess in place in your site-root.

#### /home/public/index.py

```python
#!/usr/local/bin/python
 import bottle
 from bottle import route

@route('/')
 def index():
 return 'Index'

@route('/hello')
 def hello():
 return 'Hello'

if __name__ == '__main__':
 from wsgiref.handlers import CGIHandler
 CGIHandler().run(bottle.default_app())
```

#### /home/public/.htaccess

```cfg
DirectoryIndex index.py
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ /index.py/$1 [L]
```

Test this out by going to http://\<domain\>/ and http://\<domain\>/hello to confirm that bottle routes work. This works for me, but it is a little bit slow.

I'm excited to finally have my own non-php stuff to do on NFS. Hopefully you'll have fun with this as well.
Good luck.

[nearlyfreespeech]: http://www.nearlyfreespeech.net/
[stackoverflow]: http://stackoverflow.com/questions/2664350/problems-with-routing-urls-using-cgi-and-bottle-py
