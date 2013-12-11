window.cc = -> for arg in arguments then console.log arg
$ ->
	window.wordcloud = {}
	window.totalcount = 0;

	WordCloud = Backbone.View.extend
		el: '.word-cloud'
		initialize: ->
			@render()
		render: ->
			self = @
			_.each @model, (count, word) ->
				ems = ( (count/totalcount) * 300 )
				if ems > 5 then ems = 5
				li = $("<li />").text(word).css({"font-size": ems + "em"})
				self.$el.append li
			@


	Post = Backbone.Model.extend
		parse: (model) ->
			model.start_date = new Date model.start_date
			model.end_date = new Date model.end_date
			model.description = $(JSON.parse(model.description).text_out).text().toLowerCase()
			_.each model.description.split(" "), (word) ->
				if wordcloud.hasOwnProperty(word) then wordcloud[word]++
				else wordcloud[word] = 1
				totalcount++
			model

	Posts = Backbone.Collection.extend
		start: 0
		url: -> '/recommendations/' + @start
		model: Post

	PostListItem = Backbone.View.extend
		template: $("#post-item").html()
		tagName: 'li'
		initialize: ->
			@listenTo @model,
				hide: ->
					@$el.hide()
				show: ->
					@$el.show()
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
					locations: [loc]
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
			WordCloudView = new WordCloud model: wordcloud, count: totalcount
		parse: true

	$(".show-word-cloud").on "click", ->
		$(".word-cloud").toggle("fast")

	$(".js-filter-results").on "keyup", (e) ->
		key = e.keyCode || e.which
		if key == 13
			val = $(@).val()
			filter = _.each allposts.models, (post) ->
				text = post.toJSON()
				text = (text.description + text.location + text.activity1 + text.activity2).toLowerCase()
				if text.indexOf(val) == -1
					post.trigger "hide"
				else post.trigger "show"


$(window).scroll ->
	if $(window).scrollTop() + $(window).height() == $(document).height()
		allposts.start += 20
		allposts.fetch({remove: false})
