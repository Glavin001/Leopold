// http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/
"use strict";
 
var fs = require("fs"),
    util = require('util'),
    restler = require('restler'),
    path = require('path'),
    exec = require('child_process').exec,
    child;

// Optional. You will see this name in eg. 'ps' or 'top' command
process.title = 'node-chat';
 
// Port where we'll run the websocket server
var webSocketsServerPort = 1337;
 
// websocket and http servers
var webSocketServer = require('websocket').server;
var http = require('http');
 
/**
 * Global variables
 */
// latest 100 messages
var history = [ ];
// list of currently connected clients (users)
var clients = [ ];

// Get root directory, ./Leopold/
var rootDir = path.resolve(__dirname, '../');
 
/**
 * Helper function for escaping input strings
 */
function htmlEntities(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
/** 
 Helper function for recording audio
*/
function recordAudio(filePath, callback) { 
    var command = "rec \""+filePath+"\" rate 16k silence -l 1 0.1 1% 1 2.0 1%";
    console.log("Recording...", command);
    child = exec(command, // command line argument directly in string
        { cwd: rootDir },
      function (error, stdout, stderr) {      // one easy function to capture data/errors
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
          console.log('exec error: ' + error);
        }
        return callback && callback();
    });
}
/**
 Helper function for Speech to Text
*/
function speechToText(audioFile, callback) {
    console.log("speechToText ", audioFile);

    fs.stat(audioFile, function(err, stats) {

        console.log(stats);
        
        var url = "http://www.google.com/speech-api/v1/recognize?client=chromium&lang=en",
            headers = { 'Content-type': 'audio/flac; rate=16000', "Accept":"audio/flac" };

        restler.post(url, {
            multipart: true,
            headers: headers,
            method: "post",
            data: { 
                "file": restler.file(audioFile, null, stats.size, null, "audio/flac")
            }
        }).on("complete", function(data) {
            console.log(data);
            return callback && callback();
        });
    
    });

    /*
    var command = "rec temp/rec.mp3 rate 16k silence -l 1 0.1 1% 1 2.0 1%";
    console.log("Speech to Text...", command);
    child = exec(command, // command line argument directly in string
        { cwd: rootDir },
      function (error, stdout, stderr) {      // one easy function to capture data/errors
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
          console.log('exec error: ' + error);
        }
        return callback && callback();
    });
    */
}
/**
Helper function for converting audio mp3 to flax
*/
function convertAudio(sourceFile, destFile, callback) {
    var command = "ffmpeg -i \""+sourceFile+"\" -ar 16000 -c:a flac \""+destFile+"\" -y ";
    console.log("Converting...", command);
    child = exec(command, // command line argument directly in string
        { cwd: rootDir },
      function (error, stdout, stderr) {      // one easy function to capture data/errors
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
          console.log('exec error: ' + error);
        }
        return callback && callback();
    });
}
/*
console.log("Start");
recordAudio("temp/rec.mp3", function() {
    convertAudio("temp/rec.mp3", "temp/rec.flac", function() {
        speechToText("temp/rec.flac", function() {
            console.log("Done!");
        });
    });
});
*/
speechToText("temp/rec.flac", function() {
        console.log("Done!");
});
    

// Array with some colors
var colors = [ 'red', 'green', 'blue', 'magenta', 'purple', 'plum', 'orange' ];
// ... in random order
colors.sort(function(a,b) { return Math.random() > 0.5; } );
 
/**
 * HTTP server
 */
var server = http.createServer(function(request, response) {
    // Not important for us. We're writing WebSocket server, not HTTP server
});
server.listen(webSocketsServerPort, function() {
    console.log((new Date()) + " Server is listening on port " + webSocketsServerPort);
});
 
/**
 * WebSocket server
 */
var wsServer = new webSocketServer({
    // WebSocket server is tied to a HTTP server. WebSocket request is just
    // an enhanced HTTP request. For more info http://tools.ietf.org/html/rfc6455#page-6
    httpServer: server
});
 
// This callback function is called every time someone
// tries to connect to the WebSocket server
wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin ' + request.origin + '.');
 
    // accept connection - you should check 'request.origin' to make sure that
    // client is connecting from your website
    // (http://en.wikipedia.org/wiki/Same_origin_policy)
    var connection = request.accept(null, request.origin); 
    // we need to know client index to remove them on 'close' event
    var index = clients.push(connection) - 1;
    var userName = false;
    var userColor = false;
 
    console.log((new Date()) + ' Connection accepted.');
 
    // send back chat history
    if (history.length > 0) {
        connection.sendUTF(JSON.stringify( { type: 'history', data: history} ));
    }
 
    // user sent some message
    connection.on('message', function(message) {
        if (message.type === 'utf8') { // accept only text
            if (userName === false) { // first message sent by user is their name
                // remember user name
                userName = htmlEntities(message.utf8Data);
                // get random color and send it back to the user
                userColor = colors.shift();
                connection.sendUTF(JSON.stringify({ type:'color', data: userColor }));
                console.log((new Date()) + ' User is known as: ' + userName
                            + ' with ' + userColor + ' color.');
 
            } else { // log and broadcast the message
                console.log((new Date()) + ' Received Message from '
                            + userName + ': ' + message.utf8Data);
                
                // we want to keep history of all sent messages
                var obj = {
                    time: (new Date()).getTime(),
                    text: htmlEntities(message.utf8Data),
                    author: userName,
                    color: userColor
                };
                history.push(obj);
                history = history.slice(-100);
 
                // broadcast message to all connected clients
                var json = JSON.stringify({ type:'message', data: obj });
                for (var i=0; i < clients.length; i++) {
                    clients[i].sendUTF(json);
                }
            }
        }
    });
 
    // user disconnected
    connection.on('close', function(connection) {
        if (userName !== false && userColor !== false) {
            console.log((new Date()) + " Peer "
                + connection.remoteAddress + " disconnected.");
            // remove user from the list of connected clients
            clients.splice(index, 1);
            // push back user's color to be reused by another user
            colors.push(userColor);
        }
    });
 
});


/*
fs.watch("../temp/result", function( event, targetFile ) {
    console.log("File ", event);
    // on file change we can read the new xml
    fs.readFile( '../temp/result','utf8', function ( err, data ) {
        //
        if ( err ) throw err;
        console.dir(data);
        console.log('Done');
        // broadcast message to all connected clients
        // we want to keep history of all sent messages
        var obj = {
            time: (new Date()).getTime(),
            text: data,
            author: "Server",
            color: "red"
        };
        history.push(obj);
        history = history.slice(-100);

        var json = JSON.stringify({ type:'message', data: obj });
        for (var i=0; i < clients.length; i++) {
            clients[i].sendUTF(json);
        }
    });
});
*/
