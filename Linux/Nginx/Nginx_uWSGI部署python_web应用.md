# Nginx+uWSGI配置python web应用

#### (Take ```Ubuntu Server``` as an example)
#### (Take ```Flask``` as an example)
Our flask project has just only one simple file like this:
```python
from flask import Flask
application = Flask(__name__)

@application.route("/")
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == "__main__":
    application.run(host='0.0.0.0', port=8000)
```

### Install Nginx

```
$ sudo apt-get update
$ sudo apt-get install nginx
```

### Start, Stop and Restart Nginx

```
$ sudo systemctl start nginx
$ sudo systemctl start nginx
$ sudo systemctl start nginx
```
or
```
$ sudo service nginx start
$ sudo service nginx stop
$ sudo service nginx restart
```

### Install uWSGI

It's the easiest way to install ```uWSGI``` with python package manager ```pip```：

```
$ sudo apt-get install python-dev # Without installing this, the following installation may fail
$ sudo pip install uwsgi
```

### Test wether uWSGI work

create the test file
```python
# test.py
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return ["Hello World"] # python2
    #return [b"Hello World"] # python3
```

run uWSGI
```
$ uwsgi --http :8000 --wsgi-file test.py
```
> parameters:
> * http :8000: use http protocol, port 8000
> * wsgi-file test.py: load the certain file

Open the url ```http://example.com:8000```, the browser should display ```hello world```

If the response is correct, the following three links are unobstructed
> the web client <-> uWSGI <-> Python

### Create the WSGI Entry Point

Next, we'll create a file that will serve as the entry point for our application. This will tell our uWSGI server how to interact with the application.

We will call the file ```wsgi.py```:

The file is incredibly simple, we can simply import the Flask instance from our application and then run it:
```python
# wsgi.py
from flaskr import application

if __name__ == "__main__":
    application.run()
```

### Configure uWSGI
Our application is now written and our entry point established. We can now move on to uWSGI.

#### Testing uWSGI Serving

The first thing we will do is test to make sure that ```uWSGI``` can serve our application.

We can do this by simply passing it the name of our entry point. We'll also specify the socket so that it will be started on a publicly available interface and the protocol so that it will use ```HTTP``` instead of the uwsgi binary protocol:
```
uwsgi --socket 0.0.0.0:8000 --protocol=http -w wsgi
```
If you visit your server's domain name or IP address with ```:8000``` appended to the end in your web browser, you should see a page that display "hello world".

#### Creating a uWSGI Configuration File

We have tested that ```uWSGI``` is able to serve our application, but we want something more robust for long-term usage. We can create a ```uWSGI``` configuration file with the options we want.

Let's place that in our project directory and call it ```flaskr.ini```:

Inside, we will start off with the ```[uwsgi]``` header so that ```uWSGI``` knows to apply the settings. We'll specify the module by referring to our ```wsgi.py``` file, minus the extension:
```
[uwsgi]
module = wsgi
```
Next, we'll tell ```uWSGI``` to start up in master mode and spawn five worker processes to serve actual requests:
```
[uwsgi]
module = wsgi

master = true
processes = 5
```

When we were testing, we exposed ```uWSGI``` on a network port. However, we're going to be using Nginx to handle actual client connections, which will then pass requests to uWSGI. Since these components are operating on the same computer, a Unix socket is preferred because it is more secure and faster. We'll call the socket ```flaskr.sock``` and place it in this directory.

We'll also have to change the permissions on the socket. We'll be giving the ```Nginx``` group ownership of the ```uWSGI``` process later on, so we need to make sure the group owner of the socket can read information from it and write to it. We will also clean up the socket when the process stops by adding the ```"vacuum"``` option:
```
[uwsgi]
module = wsgi

master = true
processes = 5

socket = flaskr.sock
chmod-socket = 660
vacuum = true
```

The last thing we need to do is set the ```die-on-term``` option. This is needed because the Upstart init system and ```uWSGI``` have different ideas on what different process signals should mean. Setting this aligns the two system components, implementing the expected behavior:
```
[uwsgi]
module = wsgi

master = true
processes = 5

socket = flaskr.sock
chmod-socket = 660
vacuum = true

die-on-term = true
```
You may have noticed that we did not specify a protocol like we did from the command line. That is because by default, ```uWSGI``` speaks using the uwsgi protocol, a fast binary protocol designed to communicate with other servers. ```Nginx``` can speak this protocol natively, so it's better to use this than to force communication by ```HTTP```.

### Create an Upstart Script

First, install ```upstart```.
```
$ apt install upstart
```

The next piece we need to take care of is the Upstart script. Creating an Upstart script will allow Ubuntu's init system to automatically start ```uWSGI``` and serve our Flask application whenever the server boots.

Create a script file ending with ```.conf``` within the ```/etc/init``` directory to begin:
```
$ sudo vim /etc/init/flaskr.conf
```

Inside, we'll start with a simple description of the script's purpose. Immediately afterwards, we'll define the conditions where this script will be started and stopped by the system. The normal system runtime numbers are 2, 3, 4, and 5, so we'll tell it to start our script when the system reaches one of those runlevels. We'll tell it to stop on any other runlevel (such as when the server is rebooting, shutting down, or in single-user mode):
```
description "uWSGI server instance configured to serve myproject"

start on runlevel [2345]
stop on runlevel [!2345]
```

Next, we need to define the user and group that ```uWSGI``` should be run as. Our project files are all owned by our own user account, so we will set ourselves as the user to run. The ```Nginx``` server runs under the ```www-data``` group. We need Nginx to be able to read from and write to the socket file, so we'll give this group ownership over the process:
```
description "uWSGI server instance configured to serve flaskr"

start on runlevel [2345]
stop on runlevel [!2345]

setuid user
setgid www-data
```

Next, we need to set up the process so that it can correctly find our files and process them. We've installed all of our Python components into a virtual environment, so we need to set an environmental variable with this as our path. We also need to change to our project directory. Afterwards, we can simply call the ```uWSGI``` executable and pass it the configuration file we wrote:

```
description "uWSGI server instance configured to serve myproject"

start on runlevel [2345]
stop on runlevel [!2345]

setuid user
setgid www-data

<!--env PATH=/home/user/myproject/myprojectenv/bin-->
chdir /home/ubuntu/flaskr
exec uwsgi --ini flaskr.ini
```

### Configuring Nginx to Proxy Requests

Our ```uWSGI``` application server should now be up and running, waiting for requests on the socket file in the project directory. We need to configure ```Nginx``` to pass web requests to that socket using the uwsgi protocol.

Begin by creating a new server block configuration file in ```Nginx```'s ```sites-available``` directory. We'll simply call this myproject to keep in line with the rest of the guide:
```
$ sudo nano /etc/nginx/sites-available/flaskr
```

Open up a server block and tell ```Nginx``` to listen on the default port ```80```. We also need to tell it to use this block for requests for our server's domain name or IP address:
```
server {
    listen 80;
    server_name server_domain_or_IP;
}
```

The only other thing that we need to add is a location block that matches every request. Within this block, we'll include the ```uwsgi_params``` file that specifies some general ```uWSGI``` parameters that need to be set. We'll then pass the requests to the socket we defined using the ```uwsgi_pass``` directive:
```
server {
    listen 80;
    server_name server_domain_or_IP;

    location / {
        include uwsgi_params;
        uwsgi_pass unix:/home/ubuntu/flaskr/flaskr.sock;
    }
}
```

That's actually all we need to serve our application. Save and close the file when you're finished.

To enable the ```Nginx``` server block configuration we've just created, link the file to the sites-enabled directory:
```
$ sudo ln -s /etc/nginx/sites-available/flaskr /etc/nginx/sites-enabled
```

With the file in that directory, we can test for syntax errors by typing:
```
$ sudo nginx -t
```
If this returns without indicating any issues, we can restart the Nginx process to read the our new config:
```
$ sudo service nginx restart
```