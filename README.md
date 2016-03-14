# RailsLite

A functional MVC framework based upon the functionality of Ruby on Rails. 

## Usage

* Download the repository
* In the terminal run `bundle exec bundle install`
* Then enter `ruby server.rb`
* Navigate to localhost:3000

Upon viewing the homepage you will see "Greetings from the controller" this behavior has been defined in the server.rb file.
	
* If you have familiarity with Rails feel free to instantiate your own controller class here and 
simply inherit it from ControllerBase. 

The framework also supports viewing of static assets that may be placed in the /public folder. 

If you navigate to `localhost:3000/public/bla.jpg` you can see a sample image included with the repo.

## Features

#### Router

The framework includes an implementation of a router that implements similar functionality to the rails router itself.

In server.rb we can see how a router may be instantiated:

	router = Router.new
	router.draw do
		get Regexp.new("^/$"), MyController, :go
	end

While this is a relatively simple call, there is alot going on behind the scenes. With the call to to `Router.new` we instantiate a series of methods for each http action using define_method to keep our code dry: 

	[:get, :post, :put, :delete].each do |http_method|
		define_method(http_method) do |pattern, controller_class, action_name|
	 	 add_route(pattern, http_method, controller_class, action_name)
		end
	end

This allows us to have appropriately matching routes when we may receive a new request.

Now in the instantiation of the app within `server.rb`, we call `router.run(req, res)`. This is where the actual matching will occur.

First it will check the if the route has been seen before by the router, and if so will grab the controller tied to the route and invoke the appropriate action: 

	controller = controller_class.new(req, res, route_hash)
	controller.invoke_action(action_name)

For further implementation details please refer to `router.rb`

#### Render Templates

To successfully render templates it is necessary to write our own `ControllerBase#render` function.

This needs to implement the following basic behaviors:

* Read the correct html.erb template based on classname and file name
* Render it using erb
* Write the content into the reponse (if it hasn't been done already)

The first is completed in this manner:

	file = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")

Then we render using ERB:

	erb_template = ERB.new(file)
	erb_result = erb_template.result(binding)

And finally write the content into the response:

	if already_built_response?
		raise "Double render!"
	end
	@already_built_response = true
	res.write(content)

For further implementation details on template rendering please refer to `controller_base.rb`

#### Flash

The flash core behavior should be a cookie that is available upon the next redirect and then expire. With the caveat that flash.now should be available immediately as well. 

In order to implement this we can use the browsers natural behavior to clear state to our advantage. 

Upon instantiation use two variables, one the flash to store and the other what is parsed from the incoming `_flash` cookie (if it exists):

	@flash_to_store = {}
	JSON.parse(cookie).each {|key, val| @retrieved_flash[key.to_sym] = val}

Then two helper methods are needed for assigning and getting from the flash:

	def [](key)
	  @retrieved_flash[key]
	end

and

	def []=(key, val)
	  @flash_to_store[key] = val
	end

When using the getter we want to grab the value that was passed in via the cookie so we retrieve it from `@retrieved_flash`. But for assignment we want to set `@flash_to_store`.

To implement `Flash#now` all that we need to do is return `@flash_to_store`:

	def now
	  @flash_to_store
	end

This is because state will not be cleared on a new render, but will be cleared when a redirect occurs thanks to the browser.

So upon redirect we simply need to call store_flash that will set a new cookie in the response that will be accessible the next time flash is instantiated:

	def store_flash(res)
	  cook = @flash_to_store.to_json
	  res.set_cookie('_flash', {path: '/', value: cook})
	end

For further implementation details please refer to `flash.rb` and `controller_base.rb`

#### Server Exceptions

Server exceptions is a hand rolled middleware that will grab any server error that may occur and display far more informative information.

What this will do is perform the standard call to the app, but in a rescue block so that if an exception is propogated up it can grab it and display more valuable information.

	def call(env)
	  app.call(env)
	rescue Exception => e
	    res = Rack::Response.new
	    file = create_file(e)
	    res.write(file)
	    res['Content Type'] = 'text/html'
	    res.finish
	end

Within the call to create_file multiple steps occur to provide the user with a stacktrace, the error message, and a snipped from the offending file where the error occurred.

We can grab the stacktrace using:

	<% exc.backtrace.each do |line|%>
	  <p> <%= line %> </p>
	<% end %>

The error message via `exc.message`

And finaly the source code via reading the path from the exception and reading the file it provides:

	source_code_error_info = exc.backtrace[0].split(":")
	path = source_code_error_info.first
	source_file = File.readlines(path)

For further implementation details please refer to `server.rb` and `show_exceptions.rb`

#### Serve Static Assets




