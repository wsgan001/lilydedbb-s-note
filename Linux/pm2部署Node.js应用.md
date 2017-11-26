# PM2 部署 Node.js 应用

```PM2``` is an advanced, production process manager for ```Node.js```

### Install PM2

The latest ```PM2``` stable version is installable via ```NPM```
```
$ npm install pm2 -g
```

### Usage

The simplest way to start, daemonize and monitor your application is this:
```
$ pm2 start app.js
```

### Common command

```
# Fork mode
$ pm2 start app.js --name my-api # Name process

# Listing

$ pm2 list               # Display all processes status
$ pm2 jlist              # Print process list in raw JSON
$ pm2 prettylist         # Print process list in beautified JSON

$ pm2 describe <id|name>         # Display all informations about a specific process

$ pm2 monit              # Monitor all processes
```

for example:
```
$ pm2 list
┌──────────┬────┬──────┬───────┬────────┬─────────┬────────┬─────┬───────────┬──────────┐
│ App name │ id │ mode │ pid   │ status │ restart │ uptime │ cpu │ mem       │ watching │
├──────────┼────┼──────┼───────┼────────┼─────────┼────────┼─────┼───────────┼──────────┤
│ app      │ 0  │ fork │ 27676 │ online │ 1       │ 15D    │ 0%  │ 53.7 MB   │ disabled │
│ app      │ 1  │ fork │ 2200  │ online │ 39      │ 15D    │ 0%  │ 34.6 MB   │ disabled │
│ app      │ 3  │ fork │ 23424 │ online │ 1       │ 9D     │ 0%  │ 38.3 MB   │ disabled │
└──────────┴────┴──────┴───────┴────────┴─────────┴────────┴─────┴───────────┴──────────┘
 Use `pm2 show <id|name>` to get more details about an app
```

### Setup startup script

Restarting PM2 with the processes you manage on server boot/reboot is critical. To solve this just run this command to generate an active startup script:
```
$ pm2 startup
```

### Configure Nginx

```
upstream patsys {
    server 127.0.0.1:23333;
}

......

server {
    ......
    location /pat_sys/ {
        proxy_pass http://patsys;
    }
    ......
}
```