--[[The basic Exception.
  Author: Vexatos]]
local COLua = require "COLua"

local Exception = COLua{"Exception";
  init = function(self, msg)
    self.msg = msg
    return self
  end,

  __tostring = function(self)
    return self:type()..": "..self.msg
  end,

  getMessage = function(self)
    return self.msg
  end,

  throw = function(self, level, traceback)
    if traceback ~= false then
      error(tostring(self),level or 2)
    else
      error(self, level or 2)
    end
  end
}

return Exception
