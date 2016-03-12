require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require 'byebug'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params={})
    @req = req
    @res = res
    @already_built_response = false
    @params = req.params.merge(route_params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    if already_built_response?
      raise "Double render!"
    end
    res['Location'] = url
    res.status = 302
    @already_built_response = true

    session.store_session(res)
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    if already_built_response?
      raise "Double render!"
    end
    @already_built_response = true
    res.write(content)
    res['Content-Type'] = content_type
    session.store_session(res)
  end

  def render(template_name)
    file = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")
    erb_template = ERB.new(file)
    erb_result = erb_template.result(binding)
    render_content(erb_result, 'text/html')
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def invoke_action(name)
    self.send(name.to_sym)
    self.render(name.to_sym) unless already_built_response?
  end
end

