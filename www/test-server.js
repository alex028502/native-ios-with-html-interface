//this is a test api that allows us to test and demo our interface in a browser
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var path = require('path');
var util = require('util');
var fs = require('fs');

var database = [{note:"first note"}]; //new data each time the test server is restarted

app.use(bodyParser.json());

var api_router = express.Router();

api_router.post('/notes', function(req, res) {

  var note = req.body.note;
  if (!note) {
    return res.status(400).send('no text');
  }
  database.push({note:note});
  return res.json({ message: 'success' });
});

api_router.get('/notes', function(req, res) {
  return res.json(database);
});

api_router.get('/notes/:id', function(req, res) {
  res.status(501).send("request single item not implemented");
});

api_router.put('/notes/:id', function(req, res) {
  res.status(501).send("update not implemented");
});

api_router.delete('/notes/:id', function(req, res) {
  res.status(501).send("delete not implemented");
});

function static_file(relative_path) {
  return function (req, res) {
    res.sendFile(__dirname + "/" + relative_path);
  }
}

//get list of source files from files.txt and server them all from the root to
//simulate how they are added to the bundle.  We don't necessarily use all of
//these files here, but since they are available in the bundle, it can't hurt
//to add them.  It might even help us catch some issues.

var addedFiles = String(fs.readFileSync(__dirname + "/files.txt")).split("\n");

for (var idx in addedFiles) {
  //would like to use for/of but better to keep it compatible with old node versions
  var relative_path = addedFiles[idx].trim();

  if (!relative_path) {
    console.log("skipping blank line");
    continue;
  }
  console.log("serving file " + relative_path);
  app.use('/' + path.basename(relative_path), static_file(relative_path));
}

app.get('/history-modal.html', function (req, res) {
  res.send("full history is not visible on web demo - a native table is used");
});

app.delete('/delete-all', function (req, res) {
  database = [];
  res.send("deleted-all");
});

app.get('/api-test', function (req, res) {
  res.sendFile(__dirname + "/test/api-test-intro.html");
});

app.get('/clear-database-and-show-index', function (req, res) {
  //clear the database before serving file
  //for protractor tests
  database = [];
  //this shouldn't really be a get - but it makes things a lot easier
  res.sendFile(__dirname + "/index.html");
});

app.post('/api-test', function (req, res) {
  //here we set the same initial conditions that we will set before running this
  //file in the embedded browser.  The difference is that on the mobile browser
  //we will inject a different database while here, since we don't care about
  //the test database, we will just delete the one we have
  database = [{note: "test note 1"}, {note: "test note 2"}];
  res.sendFile(__dirname + "/test/api-test.html");
});

app.get('/', function (req, res) {
  res.sendFile(__dirname + "/web-demo-homepage.html");
});

app.use('/api', api_router);

app.listen(8080);
console.log('to see web demo go to http://localhost:8080');
