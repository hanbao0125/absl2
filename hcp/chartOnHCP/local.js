// https://stackoverflow.com/questions/12740659/downloading-images-with-node-js
/* Jerry 2017-08-06 9:26AM
proxy: once I have logged on VPN, download does not work any more
solution: proxy_on
*/

var path = require('path'), express = require('express');
var https = require("https");
var bodyParser = require('body-parser');
var multer = require('multer'); // v1.0.5
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


app.use(bodyParser.json()); // for parsing application/json
app.post('/c4c', function(req, res){
  var body = "";
  req.on('data', function (chunk) {
    body += chunk;
    // console.log("onData: " + chunk);
  });
  req.on('end', function () {
    console.log('body end: ' + body);
    var reqObj = JSON.parse(body);
    console.log("Account id: " + reqObj["AccountID"]);
    console.log("Account id2: " + reqObj.AccountID);
    for( var i in reqObj){
      console.log("attribute: " + i + " value: " + reqObj[i]);
    }
  });

    // res.setHeader('Content-Type', 'application/json');
var sURL = "https://qxl-cust233.dev.sapbydesign.com/sap/byd/odata/v1/opportunity/OpportunityCollection('00163E06551B1EE79E9E69D7F8FBCDCF')";
var sURL2 = "https://raw.githubusercontent.com/i042416/KnowlegeRepository/master/ABAP/BO/reuse_backend_code.md";

var username = 'WANGJER'
var password = 'Saptest1'
var options = {
  url: sURL,
  auth: {
    user: username,
    password: password
  },
  headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
}
request(options, function (error, response, body) {
  console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
  // console.log('body:', body); // Print the HTML for the Google homepage.
  var opportunity = JSON.parse(body);
  var line1 = "Opportunity name: " + opportunity.d.results.Name;
  console.log(line1);
  var line2 = "Responsible: " + opportunity.d.results.MainEmployeeResponsiblePartyName;
  console.log(line2);
  var line3 = "Opportunity id: " + opportunity.d.results.ObjectID;
  console.log(line3);
  var responseText = line1 + "\n" + line2 + "\n" + line3;
  res.send(responseText);
});
	
});

app.listen(process.env.PORT || 3001, function(){
     console.log("Example app listens on port 3001.");
});