# Create a SSL Certificate on nginx


### Step One —— Create a Directory for the Certificate
```
$ sudo mkdir /etc/nginx/ssl
$ cd /etc/nginx/ssl
```


### Step Two —— Create the Server Key and Certificate Signing Request
```
$ sudo openssl genrsa -des3 -out server.key 2048
```
Start by creating the private server key. During this process, you will be asked to enter a specific passphrase. ++**Be sure to note this phrase carefully, if you forget it or lose it, you will not be able to access the certificate.**++

Follow up by creating a certificate signing request:
```
$ sudo openssl req -new -key server.key -out server.csr
```
This command will prompt terminal to display a lists of fields that need to be filled in.

The most important line is "```Common Name```". Enter your official domain name here or, if you don't have one yet, your site's IP address. Leave the challenge password and optional company name blank.


### Step Three —— Remove the Passphrase

We are almost finished creating the certificate. However, it would serve us to remove the passphrase. Although having the passphrase in place does provide heightened security, the issue starts when one tries to reload nginx. In the event that nginx crashes or needs to reboot, you will always have to re-enter your passphrase to get your entire web server back online.

Use this command to remove the password:
```
$ sudo cp server.key server.key.org
$ sudo openssl rsa -in server.key.org -out server.key
```


### Step Four —— Sign your SSL Certificate

Your certificate is all but done, and you just have to sign it. Keep in mind that you can specify how long the certificate should remain valid by changing the 365 to the number of days you prefer. As it stands this certificate will expire after one year.
```
$ sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```
You are now done making your certificate.


### Step Five —— Set Up the Certificate

Now we have all of the required components of the finished certificate.The next thing to do is to set up the virtual hosts to display the new certificate.

Let's create new file with the same default text and layout as the standard virtual host file. You can replace "example" in the command with whatever name you prefer:
```
$ sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/example
```
Then go ahead and open up that new file:
```
$ sudo vim /etc/nginx/sites-available/example
```
Scroll down to the bottom of the file and find the section that begins with this:
```
# HTTPS server

server {
        listen 443;
        server_name example.com;

        root /usr/share/nginx/www;
        index index.html index.htm;

        ssl on;
        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;
}
```


### Step Six —— Activate the Virtual Host

The last step is to activate the host by creating a symbolic link between the sites-available directory and the sites-enabled directory.
```
$ sudo ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/example
```
Then restart nginx:
```
$ sudo service nginx restart
```


Source Link: [https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04](https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04)