var request = require('request'),
    wchatValidateToken = require(process.cwd() + '/app/controllers/validateWXToken.js');

module.exports = function (app) {
  app.route('/')
      .get(function (req, res) {
        var url = "https://www.baidu.com";
        console.log('/:' + url);
        // res.send("Hello");
        // Jerry 2017-12-9 11:04AM - no proxy works under normal network environment
          var options = {
            url: url,
            /*
            host:'proxy.sha.sap.corp',
            port:'8080', */
            method: "GET"
          };
          request(options,function(error,response,data){
            if(data){
              res.send(data);
            }else {
              res.send("Jerry error: " + error);
              console.log(error);
            }
          });
        });

  app.route('/wechat').get(function(req,res){
    wchatValidateToken(req,res);
  });

  app.route('/wechat').post(function(req,res){

    var _da;
    req.on("data",function(data){
        _da = data.toString("utf-8");
    });
    req.on("end",function(){
        var ToUserName = getXMLNodeValue('ToUserName',_da);
        var FromUserName = getXMLNodeValue('FromUserName',_da);
        var CreateTime = getXMLNodeValue('CreateTime',_da);
        var MsgType = getXMLNodeValue('MsgType',_da);
        var Content = getXMLNodeValue('Content',_da);
        var MsgId = getXMLNodeValue('MsgId',_da);
        var xml = '<xml><ToUserName>'+FromUserName+'</ToUserName><FromUserName>'+ToUserName+'</FromUserName><CreateTime>'+CreateTime+'</CreateTime><MsgType>'+MsgType+'</MsgType><Content>'+Content+'</Content></xml>';
        res.send(xml);
    });
  });
};
