/**
 * Created by ndoorly on 19/07/17.
 */

const configureExpress = require("./configure/express");

//Import useful libraries, use npm to install express, i2c-bus etc.
var http = require('http');
var url = require('url');
var path = require('path');
var fs = require("fs");
var gpioService = require('./gpioConfig/gpioService.js');
const WebSocket = require('ws');
const queue = require('./configure/queue');

const app = configureExpress();
gpioService.setSpeed(1);

function getIp(ws) {
    var ipString = ws._socket.remoteAddress;
    var singleIp = ipString.split(':');
    return singleIp[3];
}

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
wss.on('connection', function connection(ws, req) {
    const location = url.parse(req.url, true);
    var ip = getIp(ws);

    queue.addToQueue(ip);

    ws.on('message', function incoming(message) {
        console.log('received: %s', message);
        //get ip address of this user
        console.log("Message from IP = " + ip);
        switch (message) {
            case "askServerForAccessToAPI":
                if(queue.getFrontOfQueue() == ip) {
                    //user can access the Big hex, set active for queue timeout
                    queue.setActive();
                    ws.send("accessAPISuccess");
                }
                else {
                    //return position along with deny to ensure client is up to date
                    var pos = queue.getQueuePositionOfIP(ip);
                    pos = pos+1;
                    ws.send("denied " + JSON.stringify(pos));
                }
                break;
            case "leaveQueue":

                //send message to all ip addresses further behind in queue to move up one
                wss.clients.forEach(function each(client) {
                  if (client !== ws && client.readyState === WebSocket.OPEN &&
                       queue.getQueuePositionOfIP(getIp(client)) > queue.getQueuePositionOfIP(ip)) {
                           client.send("moveUpQueue");
                    }
                });

                queue.removeFromQueue(ip);
                ws.send("leaveQueueSuccess");
                break;
            default:
                break;
        }
    });

    ws.on('close', function close() {
        console.log('disconnected');

        //send message to all ip addresses further behind in queue to move up one
        wss.clients.forEach(function each(client) {
          if (client !== ws && client.readyState === WebSocket.OPEN &&
               queue.getQueuePositionOfIP(getIp(client)) > queue.getQueuePositionOfIP(ip)) {
                   client.send("moveUpQueue");
            }
        });

        queue.removeFromQueue(ip);
    });
});

server.listen(80, function () {
    console.log('Example app listening on port 80')
});
