require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require 'byebug'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params)
    @req = req
    @res = res
    @already_built_response = false
    @params = req.params.merge(route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  #why does the built response check need to exist here as well?
  def redirect_to(url)
    if already_built_response?
      raise "Double render!"
    end
    res['Location'] = url
    res.status = 302
    @already_built_response = true

    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "Double render!"
    end
    @already_built_response = true
    res.write(content)
    res['Content-Type'] = content_type
    session.store_session(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #get file based on self.class.name/template_name
    file = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")
    erb_template = ERB.new(file)
    erb_result = erb_template.result(binding)
    render_content(erb_result, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    # byebug
    self.send(name.to_sym)
    self.render(name.to_sym) unless already_built_response?
  end
end

