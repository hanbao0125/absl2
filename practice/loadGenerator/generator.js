/*function funcOne(input) { 
  var request = require('request');
  request.post(someUrl, {json: true, body: input}, function(err, res, body) {
      if (!err && res.statusCode === 200) {
          funcTwo(body, function(err, output) {
              console.log(err, output);
          });
      }
  });
}

function funcTwo(input, callback) {
    // process input
    callback(null, input);
}*/

console.log("hello world");

var request = require('request');
var count = 0;
for( let i = 0; i < 500; i++){
  request('http://www.baidu.com', function (error, response, body) {
  // console.log('error:', error); // Print the error if one occurred
  count++;
    console.log("finished count: " + count );
    console.log('statusCode:' + response.statusCode );// response &&  // Print the response status code if a response was received
  // console.log('body:', body); // Print the HTML for the Google homepage.
  });
}