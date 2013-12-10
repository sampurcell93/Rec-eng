var express = require("express"),
	      _ = require("underscore"),
        app = express(),
      mongo = 'receng-sample',
      // objid = require("ObjectId"),
      	 // The users table will also contain all of the posts, associated with each user. 
      	 // Ideally we'd be using a relational model but we'll just hack it in for this project.
   Facebook = require('facebook-node-sdk'),
         db = require("mongojs").connect(mongo,["users", "posts"]),
       port, current_user = 0



app.configure(function (){
  app.use(express.logger('dev'));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.cookieParser());
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.static(__dirname + '/public'));
  app.use(express.session({ secret: 'foo bar' }));
  app.use(Facebook.middleware({ appId: '474944245955765', secret: '7b41fc65ccfea7b128dd0bc1fca2c8cc' }));
});      

var cc = function() { for (arg in arguments) console.log(arguments[arg]) }

app.listen((port = process.env.PORT || 5050), function() {
    console.log("Listening on " + port)
})

var parser = new (function() {

	return {
		getUserData: function(req, res, next) {
			db.users.find({name: 'spurcell'}, function(err, result) {
				if (!err) {
					req.user = result
					next()
				}
				else cc("FUCKING FUCK THIS PROJECT")
			})
		},
		getFriendData: function(req, res, next) {
			cc("getting friends")
			next()
		},
		getPostData: function(req, res, next) {
			cc("getting posts")
			next()
		}
	}
})

app.get("/recommendations", parser.getUserData, parser.getFriendData, parser.getPostData, function(req,res) {
	res.end("hello there")
})

app.get("/", Facebook.loginRequired(), function(req, res) {
	req.facebook.api('/me', function(err, user) {
    	res.writeHead(200, {'Content-Type': 'text/plain'});
    	res.end('Hello, ' + user.name + '!');
  	});
	// res.render("createuser", {user: {
	// 	activities: ["swimming", "biking"]
	// }});
})

/* User REST API */
app.post("/users", function(req,res) {
	cc(req.body)
	res.redirect("/")
})

app.get("/users/:name", function(req,res) {
	db.users.find({name: req.params.name}, function(err, results) {
		res.json(results)
	})
})

app.get("/users", function(req,res) {
	db.users.find({}, function(err, results) {
		res.json(results)
	})
})