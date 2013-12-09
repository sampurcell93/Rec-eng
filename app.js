var express   = require("express"),
		    _ = require("underscore"),
        app   = express(),
        mongo = 'receng-sample',
        db    = require("mongojs").connect(mongo,["posts", "users"]),
        port



var cc = function() { for (arg in arguments) console.log(arguments[arg]) }

app.listen((port = process.env.PORT || 5050), function() {
    console.log("Listening on " + port)
})

var Parser = function() {
	return {
		getUserData: function(req, res, next) {
			cc("getting user data")
			next()
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
}

var parser = new Parser()

app.get("/recommendations", parser.getUserData, parser.getFriendData, parser.getPostData, function(req,res) {
	res.end("hello there")
})