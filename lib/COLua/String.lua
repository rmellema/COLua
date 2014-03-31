--- A box object for strings

local COLua = require "COLua"

local String = COLua.Class{ "String";
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
      return String(obj1.str..obj2)
    else
      return String(obj1..obj2.str)
    end
  end,
  -- Implement methods from Box
  _box = function(self, str)
    return self:new(str)
  end,
  unbox = function(self)
    return self:tostring()
  end,
  -- Methods from the string library
  byte = function(self, i, j)
    return string.byte(self.str, i, j)
  end,
  _char = function(self, ...)
    return String(string.char(self.str, ...))
  end,
  _dump = function(func)
    return String(string.dump(func))
  end,
  find = function(self, patter, init, plain)
    return string.find(self.str, pattern, init, plain)
  end,
  _format = function(self, formatstring, ...)
    return String(string.format(formatstring, ...))
  end,
  gmatch = function(self, pattern)
    return string.gmatch(self.str, pattern)
  end,
  gsub = function(self, pattern, repl, n)
    return String(string.gsub(self.str, pattern, repl, n))
  end,
  len = function(self)
    return string.len(self.str)
  end,
  lower = function(self)
    return String(string.lower(self.str))
  end,
  match = function(self, pattern, init)
    return String(string.match(self.str, pattern, init))
  end,
  rep = function(self, n, sep)
    return String(string.sub(self.str, n, sep))
  end,
  reverse = function(self)
    return String(string.reverse(self.str))
  end,
  sub = function(self, i, j)
    return String(string.sub(self.str, i, j))
  end,
  upper = function(self)
    return String(string.upper(self.str))
  end}

return String
