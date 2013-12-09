var express = require("express"),
        app = express(),
        port

var cc = function() { for (arg in arguments) console.log(arguments[arg]) }

app.listen((port = process.env.PORT || 5050), function() {
    console.log("Listening on " + port)
})