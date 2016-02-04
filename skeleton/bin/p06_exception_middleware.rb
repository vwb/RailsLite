require 'rack'
require 'erb'
require 'byebug'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class ExceptionMiddleware

  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => exc
      res = Rack::Response.new
      file = create_file(exc, env)
      res.write(file)
      res['Content Type'] = 'text/html'
      res.finish
    end
  end

  def create_file(exc, env)

    debugger

    source_code_error_info = exc.backtrace[0].split(":")

    path = source_code_error_info.first
    line = source_code_error_info[1].to_i

    source_file = []
    File.foreach(path).with_index do |line, line_num|
      source_file << [line]
    end


    start = (line - 5 < 0) ? 0 : (line - 5)
    final = (line + 5 >= source_file.length) ? (source_file.length-1) : (line + 5)

    selected_lines = source_file[start..final]

    val = <<-HTML
      <h1> Stack Trace: </h1>

      <% exc.backtrace.each do |line|%>
        <p> <%= line %> </p>
      <% end %>

      <h1> Error Message: </h1>
      <h3> #{exc.message} </h3>

      <% unless source_file.empty? %>
        <h2> Source Code: </h2>
        <ol start=<%=line-5%>>
        <% selected_lines.each do |line| %>
          <li><%= line %></li>
        <% end %>
        </ol>
      <% end %>
    HTML

    erb_template = ERB.new(val)
    erb_result = erb_template.result(binding)
  end
end


#Code for testing the fail

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class StatusesController < ControllerBase
  def index
    # render_content(statuses.to_json, "application/json")
    render :flash_test
  end

  def go
    flash[:errors] = "An error will appear"
  end
end

class CatsController < ControllerBase
  def index
    # render_content($cats.to_json, "application/json")
  end

  def go
    render :flash_test
  end
end

router = Router.new

router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end

cool_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do 
  use ExceptionMiddleware
  run cool_app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)