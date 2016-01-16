// Initial script based on 
//	http://blog.modulus.io/build-your-first-http-server-in-nodejs

// Lets require/import the HTTP module
var http = require('http');

// Lets define a port we want to listen to
// 8123 is a pretty non-standard port, and unlikely to clash with anything else
const PORT=8123; 

// Dispatcher to handle requests
var dispatcher = require('httpdispatcher');

// Use the dispatcher to handle requests
function handleRequest(request, response){
	try {
		//log the request on console
		console.log(request.url);
		//Disptach
		dispatcher.dispatch(request, response);
	} catch(err) {
		console.log(err);
	}
}

// Static resources (non so far)
dispatcher.setStatic('resources');

// A sample GET request
dispatcher.onGet("/", function(req, res) {
	// Print the header
	res.writeHead(200, {'Content-Type': 'text/plain'});
	
	// Get a Puzzle object
	var puzzle = require('./puzzle.js').Puzzle;
	puzzle.header(res, 'Page One');
	res.end();
});

// A sample POST request
// dispatcher.onPost("/post1", function(req, res) {
// 	res.writeHead(200, {'Content-Type': 'text/plain'});
// 	res.end('Got Post Data');
// });

// Create and start the server
var server = http.createServer(handleRequest);
server.listen(PORT, function(){
	//Callback triggered when server is successfully listening. Hurray!
	console.log("Server listening on: http://localhost:%s", PORT);
});
