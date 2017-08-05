// https://stackoverflow.com/questions/12740659/downloading-images-with-node-js

var path = require('path'), express = require('express');
var fs = require('fs'), request = require('request');
var app = express();

var download = function(uri, filename, callback){
  request.head(uri, function(err, res, body){
    console.log('content-type:', res.headers['content-type']);
    console.log('content-length:', res.headers['content-length']);
    console.log("body: " + res);

    request(uri).pipe(fs.createWriteStream(filename)).on('close', callback);
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

    //mimic a slow network connection
    /*setTimeout(function(){

        res.send(JSON.stringify({
            firstName: req.body.firstName || null,
            lastName: req.body.lastName || null
        }));

    }, 1000)

    //debugging output for the terminal
    console.log('you posted: First Name: ' + req.body.firstName + ', 
    	Last Name: ' + req.body.lastName);*/
	// console.log(req);
    download('https://raw.githubusercontent.com/i042416/KnowlegeRepository/master/ABAP/BO/reuse_backend_code.md', 'google.png', 
        function(){
            console.log('done');
        }
   );
	res.send("Hello C4C, post is got");
});

app.listen(process.env.PORT || 3001, function(){
     console.log("Example app listens on port 3001.");
});