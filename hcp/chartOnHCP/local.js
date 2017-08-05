var path = require('path'), express = require('express');
var app = express();

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
	res.send("Hello C4C, post is got");
});

app.listen(process.env.PORT || 3001, function(){
     console.log("Example app listens on port 3001.");
});