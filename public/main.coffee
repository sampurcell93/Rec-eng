window.cc = -> for arg in arguments then console.log arg
$ ->
	Post = Backbone.Model.extend
		parse: (model) ->
			model.start_date = new Date model.start_date
			model.end_date = new Date model.end_date
			model.description = JSON.parse(model.description).text_out
			model

	Posts = Backbone.Collection.extend
		start: 0
		url: -> '/recommendations/' + @start
		model: Post

	PostListItem = Backbone.View.extend
		template: $("#post-item").html()
		tagName: 'li'
		render: ->
			@$el.html _.template @template, @model.toJSON()
			@
		ratePost: (like) ->
			attrs = @model.toJSON()
			a1 = attrs.activity1
			a2 = attrs.activity2
			loc = attrs.location
			cc @model.toJSON()
			# return true
			$.ajax({
				url: '/users/' + window.userid + "/" + like
				data: 
					activities: [a1, a2]
					location: loc
				type: 'PUT'
				success: (result) ->
					cc result
			})
		events:
			"click .js-like-post": (e) ->
				@ratePost true 
				$(e.currentTarget).addClass("js-unlike-post").removeClass("js-like-post").text("Unlike")
			"click .js-unlike-post": (e) ->
				@ratePost false
				$(e.currentTarget).addClass("js-like-post").removeClass("js-unlike-post").text("Like")


	PostList = Backbone.View.extend
		el: 'ul.post-list'
		initialize: ->
			_.bindAll @, "addPost", "render"
			@listenTo @collection, "add", @addPost
			@render()
		addPost: (post) ->
			@$el.append (new PostListItem model: post).render().el
			@
		render: ->
			_.each @collection.models, @addPost
			@


	window.allposts = new Posts
	list = null	
	allposts.fetch 
		success: (response) ->
			list = new PostList collection: response
		parse: true

$(window).scroll ->
	if $(window).scrollTop() + $(window).height() == $(document).height()
		allposts.start += 20
		allposts.fetch({remove: false})
