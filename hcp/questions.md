# 2017-08-07

contact: Wong Jin I803436

Hello Jin,

Greeting from China! I have one question regarding error message "" in SAP cloud platform where I would like to consume an OData service from SAP cloud for customer ( C4C system).

I have a nodejs application where I hard code an end point to an OData service in C4C system. The request is sent to C4C and then I display the result in nodejs console.

The end point for C4C OData service: 

https://qxl-cust233.dev.sapbydesign.com/sap/byd/odata/v1/opportunity/OpportunityCollection('00163E06551B1EE79E9E69D7F8FBCDCF')


When I test this application locally, it works perfect.

```Javascript
var sURL = "https://qxl-cust233.dev.sapbydesign.com/sap/byd/odata/v1/opportunity/OpportunityCollection('00163E06551B1EE79E9E69D7F8FBCDCF')";

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
  };
  request(options, function (error, response, body) {
    // console.log('body:', body); 
    var opportunity = JSON.parse(body);
    var line1 = "Opportunity name: " + opportunity.d.results.Name;
    console.log(line1);
    var line2 = "Responsible: " + opportunity.d.results.MainEmployeeResponsiblePartyName;
    console.log(line2);
    var line3 = "Opportunity id: " + opportunity.d.results.ObjectID;
    console.log(line3);
    var responseText = line1 + "\n" + line2 + "\n" + line3;
    res.send(responseText);
    res.send("another line"); // this line will cause error - repeated send response is not allowed
  }); 
```

After I upload it to Cloudfoundry@SCP, it fails to work: I set breakpoint in C4C system and found that the request sent from SCP **NEVER** reaches C4C system. After some times, SCP received error message "502 Bad Gateway - Registered endpoint failed to handle the request". 