class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (pattern =~ req.path) && (req.request_method.downcase == http_method.to_s)
  end

  def run(req, res)

    route_params = pattern.match(req.path)
    route_hash = {}

    route_params.names.each do |name|
      route_hash[name] = route_params[name]
    end

    controller = controller_class.new(req, res, route_hash)
    controller.invoke_action(action_name)

  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  #builds :
  # =>    get(pattern, controller_class, action_name)
  #         add_route(pattern, get, controller_class, action_name)
  #       end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  #iterate through the saved routes we have seen, if matches request return route
  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matched_route = match(req)
    if matched_route.nil?
      res.status = 404
      res.write("No Route Found!")
    else
      matched_route.run(req, res)
    end
  end
  
end
