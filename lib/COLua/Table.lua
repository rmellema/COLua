local COLua = require "COLua"
local String = require "COLua.String"
local type = COLua.type

local Table = COLua{ "Table";
  init = function(self, ...)
    local args = table.pack(...)
    args.n = nil
    for k, v in pairs(args) do
      self[k] = v
    end
    return self
  end,
  -- metamethods
  __pairs = function(self)
    local methods = rawget(self:class(), "__methods")
    return function(self, idx)
      local key, value = next(self, idx)
      while methods[key] ~= nil or key == 'super' do
        key, value = next(self, key)
      end
      return key, value
    end, self, nil
  end,
  -- Impelemtn merods from Box
  _box = function(self, tab)
    return self:new(table.unpack(tab))
  end,
  unbox = function(self)
    local ret = {}
    for k, v in pairs(self) do
      ret[k] = v
    end
    return ret
  end,
  -- Methods from the table library
  concat = function(self, sep, i, j)
    local tab = {self:unpack(i, j)}
    return String(table.concat(tab, sep))
  end,
  insert = function(self, pos, value)
    table.insert(self, pos, value)
  end,
  _pack = function(...)
    return Table(table.pack(...))
  end,
  remove = function(self, pos)
    return table.remove(self, pos)
  end,
  sort = function(self, comp)
    return table.sort(self, comp)
  end,
  unpack = function(self, i, j)
    i = i or 1
    j = j or #self
    local ret = {}
    for idx = i , j do
      ret[idx-i+1] = self[idx]
    end
    return table.unpack(ret)
  end}

return Table
