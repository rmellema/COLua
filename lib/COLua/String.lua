--- A box object for strings

local COLua = require "COLua"

COLua.String = COLua.Class{ "String";
  -- Constructor
  init = function(self, str)
    if not str then return nil end
    assert(type(str) == "string", "Excpected string recieved "..type(str))
    self.str = str
    return self
  end,
  -- Metamethods
  __tostring = function(self)
    return self.str
  end,
  __len = function(self)
    return self:len()
  end,
  __concat = function(obj1, obj2)
    if COLua.type(obj1) == "String" then
      return COLua.String(obj1.str..obj2)
    else
      return COLua.String(obj1..obj2.str)
    end
  end,
  -- Methods from the string library
  byte = function(self, i, j)
    return string.byte(self.str, i, j)
  end,
  _char = function(self, ...)
    return COLua.String(string.char(...))
  end,
  _dump = function(self, func)
    return COLua.String(string.dump(func))
  end,
  find = function(self, pattern, init, plain)
    return string.find(self.str, pattern, init, plain)
  end,
  _format = function(self, formatstring, ...)
    return COLua.String(string.format(formatstring, ...))
  end,
  gmatch = function(self, pattern)
    return string.gmatch(self.str, pattern)
  end,
  gsub = function(self, pattern, repl, n)
    return COLua.String(string.gsub(self.str, pattern, repl, n))
  end,
  len = function(self)
    return string.len(self.str)
  end,
  lower = function(self)
    return COLua.String(string.lower(self.str))
  end,
  match = function(self, pattern, init)
    return COLua.String(string.match(self.str, pattern, init))
  end,
  rep = function(self, n, sep)
    return COLua.String(string.rep(self.str, n, sep))
  end,
  reverse = function(self)
    return COLua.String(string.reverse(self.str))
  end,
  sub = function(self, i, j)
    return COLua.String(string.sub(self.str, i, j))
  end,
  upper = function(self)
    return COLua.String(string.upper(self.str))
  end}

return COLua.String
