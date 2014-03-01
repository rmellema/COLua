--[[The basic Exception.
  Author: Vexatos]]
local COLua = require "COLua"

local Exception = COLua{"Exeption";
  init = function(self, msg)
    self.msg = msg
  end,

  __tostring = function(self)
    return self:type()..": "..self.msg
  end,

  getMessage = function(self)
    return self.msg
  end,

  throw = function(self, level)
      error(self.msg,level)
  end
}

return Exception
