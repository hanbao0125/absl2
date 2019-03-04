const server = require('http').createServer();
const io = require('socket.io')(server);
const events = require('events');
const eventEmitter = new events.EventEmitter();

clients = [];

function startServer(serverIP, serverPort) {

  console.log("server port: " + serverPort + " ip: " + serverIP);
  server.listen(serverPort, serverIP,function(){
    console.log("Web Socket server listening...");
  });
  return eventEmitter;
};

io.on('connection', function(socket){
  socket.name = socket.id;
  console.log('new connection established: ' + socket.name);
  clients.push(socket) ;
  console.log('clients '+ clients.length);
  eventEmitter.emit('open',socket);

  socket.on('message', (data) => {
    socket.name = socket.id;
    try {
      console.log('trying to parse'+ data)
      console.log('parse'+ JSON.stringify(data,2,2))

      eventEmitter.emit('dataWS',data);

    } catch (e) {
      console.log('something bad happened :(' + e);
    }
  });

  socket.on('disconnect', function(){
    console.log("disconnect")
    eventEmitter.emit('close',socket);
  });


  // 
});

  // Send a message to all clients
  function broadcast(data){//message, sender) {
    console.log('client size: ' + clients.length)
    clients.forEach(function (client) {
      console.log('send data to: '+ client.name + " data: " + data);
      // client.write(data);
      client.emit('news', { "data": data });
    });
  }

 module.exports = {
  startServer, broadcast
 };
