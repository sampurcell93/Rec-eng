express = require("express")
_ = require("underscore")
app = express()
mongo = "receng-sample"
http = require 'http'
objid = require("ObjectId")

# The users table will also contain all of the posts, associated with each user. 
# Ideally we'd be using a relational model but we'll just hack it in for this project.
Facebook = require("facebook-node-sdk")
db = require("mongojs").connect(mongo, ["users", "posts"])
port = undefined
current_user = 0
app.configure ->
  app.use express.logger("dev")
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + "/public")
  app.use express.session(secret: "foo bar")
  app.use Facebook.middleware(
    appId: "474944245955765"
    secret: "7b41fc65ccfea7b128dd0bc1fca2c8cc"
  )

cc = ->
  for arg in arguments
    console.log arg

app.listen (port = process.env.PORT or 5050), ->
  console.log "Listening on " + port

parser = new (->

  getUserData: (req, res, next) ->
    db.users.find
      user_id: 29
    , (err, result) ->
      unless err
        req.user = result[0]
        next()
      else
        cc "FUCKING FUCK THIS PROJECT"


  getPostData: (req, res, next) ->
    db.posts.find({}).sort {start_date: 1}, (err, results) ->
      req.posts = results
      next() 

  matchKeywords: (user, posts, callback) ->
    activities = user.activities
    locations  = user.locations

    _rankPosts = (post, iterator) ->
      post.score = 0
      a1 = post.activity1.toLowerCase()
      a2 = post.activity2.toLowerCase()
      w1 = activities[a1] || parseInt "0"
      w2 = activities[a2] || parseInt "0"
      post.score += w1 + w2
      if user.locations.hasOwnProperty(post.location)
        post.score += user.locations[post.location]
      post.score -= parseInt iterator/30
      true

    _.each posts, _rankPosts

    posts.sort callback || ((a,b) -> b.score - a.score)
    posts
)

# Returns twenty posts at a time, indexed by start
app.get "/recommendations/:start", parser.getUserData, parser.getPostData, (req, res) ->
  user = req.user
  start = parseInt(req.params.start) or (start = 0)
  sorted = parser.matchKeywords(user, req.posts)
  res.json sorted.slice(start, start + 20)

app.get "/news", parser.getUserData, (req, res) ->
  res.render("newsfeed", {
      userid: req.query.id
      user: JSON.stringify req.user
    })

app.get("/preferences",parser.getUserData, (req,res) ->
  res.render "preferences", {
      userid: req.query.id
      user: JSON.stringify req.user
    }
)

app.get "/", (req, res) ->
  res.render "createuser",
    user:
      activities: ["swimming", "biking"]

# User REST API 
app.post "/users", (req, res) ->
  cc req.body
  res.redirect "/"

app.get "/users/:name", (req, res) ->
  db.users.find
    name: req.params.name
  , (err, results) ->
    res.json results

app.get "/users", (req, res) ->
  db.users.find {}, (err, results) ->
    res.json results

app.put "/users/:id/:inc", (req, res) ->
  id = parseInt req.params.id
  acby = parseInt req.query.acby
  locby = parseInt req.query.locby
  cc locby
  inc = if req.params.inc == "true" then 1 else -1

  db.users.findOne({user_id: id}, (err, res) -> 
    activities = res.activities
    _.each req.body.activities, (activity) ->
      activity = activity.toLowerCase()
      myinc = if acby != false then acby else inc
      if activities[activity] then activities[activity] += myinc else activities[activity] = myinc
    _.each req.body.locations, (loc) ->
      loc = loc
      myinc = if locby != false then locby else inc
      if res.locations[loc] then res.locations[loc] += myinc else res.locations[loc] = myinc

    db.users.update({user_id: id}, {$set: {activities: activities, locations: res.locations}}, (err, updated) ->
      console.log updated
    )
  )

  res.json success: true


# Posts REST API 
app.get "/posts", parser.getPostData, (req, res) ->
  res.json req.posts