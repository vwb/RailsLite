require 'json'

class Session

  def initialize(req)
    cook = req.cookies['_rails_lite_app']
    if cook
      @cookie = JSON.parse(cook)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    cookie = @cookie.to_json
    res.set_cookie('_rails_lite_app', {path: '/', value: cookie})
  end
end
