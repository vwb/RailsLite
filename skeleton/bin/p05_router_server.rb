require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'


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
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params['cat_id'])
    end
    flash[:errors] = "THIS IS AN ANGRY ERROR. WILL I APPEAR"

    render_content(statuses.to_json, "application/json")
  end

  def go
    flash[:errors] = "An error will appear"
    render :flash_test
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
  get Regexp.new("^/cats$"), CatsController, :go
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :go
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
