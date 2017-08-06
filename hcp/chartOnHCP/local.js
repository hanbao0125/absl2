// https://stackoverflow.com/questions/12740659/downloading-images-with-node-js
/* Jerry 2017-08-06 9:26AM
proxy: once I have logged on VPN, download does not work any more
*/

var path = require('path'), express = require('express');
var https = require("https");
var fs = require('fs'), request = require('request');
var app = express();

var download = function(uri, callback){
  request.get(uri, function(err, res, body){
    console.log('content-type:', res.headers['content-type']);
    console.log('content-length:', res.headers['content-length']);
    console.log("url: " + uri);
    res.on('data', function (chunk) {
        console.log('BODY: ' + chunk);
    });
  });
};

app.use('/jerry', express.static(path.join(__dirname, 'webapp')));

app.get('/', function(req, res){
   res.send("Hello World");
});

app.get('/c4c', function(req, res){
   res.send("Hello C4C");
   console.log(req);
});



app.post('/c4c', function(req, res){
    res.setHeader('Content-Type', 'application/json');

    /*download('https://raw.githubusercontent.com/i042416/KnowlegeRepository/master/ABAP/BO/reuse_backend_code.md',  
        function(){
            console.log('callback fired');
        }
   );*/
request('https://raw.githubusercontent.com/i042416/KnowlegeRepository/master/ABAP/BO/reuse_backend_code.md', function (error, response, body) {
  console.log('error:', error); // Print the error if one occurred
  console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
  console.log('body:', body); // Print the HTML for the Google homepage.
});
    /*
var options = {
  //host: "proxy.wdf.sap.corp",
  //port: 8080,
  path: 'www.baidu.com/index.html'
};

var req2 = https.get(options, function(res) {
  console.log('STATUS: ' + res.statusCode);
  console.log('HEADERS: ' + JSON.stringify(res.headers));

  // Buffer the body entirely for processing as a whole.
  var bodyChunks = [];
  res.on('data', function(chunk) {
    // You can process streamed parts here...
    bodyChunks.push(chunk);
  }).on('end', function() {
    var body = Buffer.concat(bodyChunks);
    console.log('BODY: ' + body);
    // ...and/or process the entire body here.
  })
});

req2.on('error', function(e) {
  console.log('ERROR: ' + e.message);
});
*/
// var http = require("http");

/*var options = {
  host: "proxy.wdf.sap.corp",
  port: 8080,
  path: "https://raw.githubusercontent.com/i042416/KnowlegeRepository/master/ABAP/BO/reuse_backend_code.md",
  headers: {
    Host: "www.google.com"
  }
};
http.get(options, function(res) {
  console.log("response: " + res);
  res.on('data', function (chunk) {
        console.log('BODY: ' + chunk);
    });
});
*/
	res.send("Hello C4C, post is got");
});

app.listen(process.env.PORT || 3001, function(){
     console.log("Example app listens on port 3001.");
});