#Travlr App

##A Recommendation Engine
Located at http://morning-springs-9356.herokuapp.com
###
-Views:

*NewsFeed:
A feed containing trip posts sorted by how likely the recommender thinks you will enjoy the trip
Users may like or dislike a post, which sends feedback to the recommender system
Supports infinite scrolling
Contains word-cloud

*Preferences:
A user may add activities that they enjoy and give them a score for how much they enjoy them
This allows the user to seed information to the database
This information is sent to the server

-Models:

*User:
Users have a list of keywords (activities, locations) associated with them and each of those has a favorability rating

*Posts:
Posts have activities, users and locations, each of these is a keyword 

We also have a word-cloud. Analyzing this word cloud gives us more information about the user and allows us to return better recommendations.


