express = require("express")
_ = require("underscore")
app = express()
mongo = "receng-sample"

# objid = require("ObjectId"),
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
      user_id: 28
    , (err, result) ->
      unless err
        req.user = result[0]
        next()
      else
        cc "FUCKING FUCK THIS PROJECT"


  getPostData: (req, res, next) ->
    db.posts.find({}, (err, results) ->
      req.posts = results
      next()
    ).sort start_date: -1

  matchKeywords: (user, posts, callback) ->
    weights = user
    _rankPosts = (post) ->
      post.score = 0
      a1 = post.activity1.toLowerCase()
      a2 = post.activity2.toLowerCase()
      w1 = weights[a1]
      w2 = weights[a2]
      post.score += w1 + w2
      
    _.each posts, _rankPosts

    posts.sort callback || ((a,b) -> b.score - a.score)
    posts
)

# Returns twenty posts at a time, indexed by start
app.get "/recommendations", parser.getUserData, parser.getPostData, (req, res) ->
  user = req.user
  start = parseInt(req.query.start) or (start = 0)
  sorted = parser.matchKeywords(user, req.posts)
  res.json sorted.slice(start, start + 20)

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



# Posts REST API 
app.get "/posts", parser.getPostData, (req, res) ->
  res.json req.posts


app.get "/dev", (req, res) ->
  # db.users.update({}, {$set: {pre}}, {upsert: true})