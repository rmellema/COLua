local COLua = require "COLua"
local type = COLua.type

COLua.Coroutine = COLua{ "Thread";
  init = function(self, func)
    if type(func) == "function" then
      self.co = coroutine.create(func)
    elseif type(func) == "thread" then
      self.co = func
    else
      error("Can't store a "..type(func).." in an object of class Coroutine")
    end
    return self
  end,
  _create = function(self, func)
    return self:new(func)
  end,
  resume = function(self, ...)
    return coroutine.resume(self, ...)
  end,
  _running = function(self)
    return self:new(coroutine.running())
  end,
  status = function(self)
    return coroutine.status(self.co)
  end,
  _yield = function(self, ...)
    return coroutine.yield(...)
  end}

return COLua.Coroutine
