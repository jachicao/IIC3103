var http = require('http');
var createHandler = require('github-webhook-handler');
var handler = createHandler({ path: '/webhook', secret: process.env.WEBHOOK_SECRET });

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404;
    res.end('no such location');
  })
}).listen(6783);

handler.on('*', function (event) {
  console.log(event);
});

handler.on('push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
  require('child_process').exec('sh deploy.sh', function(error, stdout, stderr) {
    if (error) {
      console.log(error);
    }  
    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
  }).on('exit', function(code, signal) {
  	console.log('exit');
  });
});