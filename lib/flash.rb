require 'byebug'

class Flash

  def initialize(req)
    cookie = req.cookies['_flash']
    @flash_to_store = {}
    @retrieved_flash = {}
    JSON.parse(cookie).each {|key, val| @retrieved_flash[key.to_sym] = val}
  end

  def [](key)
    @retrieved_flash[key]
  end

  def now
    @flash_to_store
  end

  def []=(key, val)
    @flash_to_store[key] = val
  end

  def store_flash(res)
    cook = @flash_to_store.to_json
    res.set_cookie('_flash', {path: '/', value: cook})
  end

end