var port = 18080;
var express = require('express'),
    routesEngine = require('./app/routes/index'), // index.js actually
    // X, X.js, X.json and X.node see blog http://www.ruanyifeng.com/blog/2015/05/require.html
    session = require("./app/session/session.js"),
    cookieParser = require('cookie-parser'),
    babelCore = require('babel-core'),
    bodyParser = require('body-parser');

  var app = express();
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({
    extended: true
  }));

  // express.static: This is a built-in middleware function in Express. 
  // It serves static files and is based on serve-static.
    app.use('/public', express.static(process.cwd() + '/public'));
    app.use('/client', express.static(process.cwd() + '/client'));
    // mount sub application
    app.use('/controllers', express.static(process.cwd() + '/app/controllers'));

  // 该方法用于在所有请求方法的路径中装入中间件函数。

    app.all('*', function(req, res, next) {
      res.header("Access-Control-Allow-Origin", "*");
      res.header("Access-Control-Allow-Headers", "X-Requested-With");
      res.header("Access-Control-Allow-Methods","PUT,POST,GET,DELETE,OPTIONS");
      res.header("X-Powered-By",' 3.2.1');
      res.header("Content-Type", "application/json;charset=utf-8");
      next(); // pass control to the next handler
    });
    routesEngine(app);


    app.listen(port, function () {
      // c:\\code\\git\\wechat\\app
        console.log('Listening on port 18080, 2: ' + process.cwd());
    });