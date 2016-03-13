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



#### Render Templates

#### Flash

#### Sessions

#### Server Exceptions

#### Serve Static Assets

