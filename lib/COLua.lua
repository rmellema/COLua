--- An OOP module for lua
local reserved = {__type = true, __methods = true, __proto = true,
    __objmt = true, __index = true, __newindex =true, __metatable = true,
    __name = true, __parents = true, __class = true} 

local function registerValue(clss, key, value)
  assert(type(clss) == "table", "Trying to register a value on a non table")
  assert(type(key) == "string", "The key must be a string!")
  if key:sub(1,2) == '__' and not reserved[key] then
    clss.__objmt[key] = value
  elseif key == "__index" or key == "__newindex" then
    clss.__objmt[key:sub(3, -1)] = value
  elseif key:sub(1,1) == '_' then
    if reserved[key] then 
      error("Trying to set field: "..key.." of a class") 
    end
    rawset(clss, key:sub(2, -1), value)
  else
    rawset(clss.__methods, key, value)
  end
end

local oldType = type
local function type(obj)
  if oldType(obj) ~= "table" then
    return oldType(obj)
  else
    local objMt = getmetatable(obj)
    if objMt and oldType(objMt) == 'table' and objMt.__type then
      return objMt.__type
    else
      return oldType(obj)
    end
  end
end


local Object = {}
Object.__methods = {}
Object.__name = "Object"
Object.__proto = {}
Object.__objmt = {__index = Object.__methods, __type = "Object",
  __class = Object}

function Object:new(...)
  return self:alloc():init(...)
end

function Object:alloc()
  if rawget(self,'super') then
    return setmetatable({super = self.super.__methods}, self.__objmt)
  else
    return setmetatable({}, self.__objmt)
  end
end

function Object:type()
  return "Class"
end

function Object:name()
  return self.__name
end

function Object:implements(proto)
  if self.__proto[proto.__name] then return true end
  local implement, mismatch = true, nil
  for k, v in pairs(proto) do
    local comp = nil
    if k:sub(1,2)== '__' then
      comp = self.__objmt[k]
    elseif string.sub(k, 1,1) == '_' then
      comp = self[string.sub(k, 2, -1)]
    else
      comp = self.__methods[k]
    end
    if type(comp) ~= proto[k] then
      implement = false
      mismatch = k
      break
    end
  end
  if implement then
    self.__proto[proto.__name] = proto
  end
  return implement, mismatch
end

function Object.__methods:init()
  return self
end

function Object.__methods:class()
  return getmetatable(self).__class
end

function Object.__methods:type()
  return getmetatable(self).__type
end

function Object:isKindOf(name)
  if self.__name == name then return true end
  for _, proto in pairs(self.__proto) do
    if proto:isKindOf(name) then
      return true
    end
  end
  if self.super then
    return self.super:isKindOf(name)
  else
    return false
  end
end

function Object.__methods:isKindOf(name)
  return self:class():isKindOf(name)
end

setmetatable(Object.__methods, {__newindex = registerMethod, 
    __metatable = ""})

local Class = {}
Class.__methods = setmetatable({}, {__index = Object})
Class.__name = "Class"
Class.__proto = {}
Class.__objmt = {__index = function(self, k)
      if self.super[k] then
        return self.super[k]
      else
        return Class.__methods[k]
      end
    end;
    __type = "Class", __class = Class, __newindex = registerValue;
    __call = function(self, ...) return self:new(...) end}
Class.super = Object

function Class:alloc(name, parent)
  local methods = setmetatable({super = parent.__methods}, 
      {__index = parent.__methods, __newindex = registerMethod})
  local new
  new = setmetatable({__name = name, super = parent,
    __methods = methods, __proto = {}; __objmt = {
      __index = function(self, key)
        if new.__objmt.index then
          local ret = new.__objmt.index(self, key)
          if ret then
            return ret
          end
        end
        return new.__methods[key]
      end;
      __type = name
    }}, self.__objmt)
  new.__objmt.__class = new
  for k, v in pairs(parent.__objmt) do
    if not reserved[k] and not new.__objmt[k] then
      new.__objmt[k] = v
    end
  end
  return new
end

function Class:new(inter)
  local name = inter[1] or inter['name']
  local parent = inter[2] or inter['extends'] or Object
  local prots = inter[3] or inter['implements']
  inter [1], inter['name'], inter[2], inter['extends'], 
      inter[3], inter['implements'] = nil, nil, nil, nil, nil, nil
  return self:alloc(name, parent):init(inter, prots)
end

function Class.__methods:init(functions, protocols)
  for k, v in pairs(functions) do
    registerValue(self, k, v)
  end
  if protocols then
    if type(protocols) == "Protocol" then
      protocols = {protocols}
    end
    for i = 1, #protocols do
      local imp, mismatch = self:implements(protocols[i])
      if not imp then
        error("Class "..self:name().." claims to implement "..
            protocols[i].__name..", but doesn't implement "..mismatch)
      end
    end
  end
  return self
end

function Class.__methods:name()
  return self.__name
end

setmetatable(Object, { __newindex = registerValue,
    __type = "Class", __class = Class;
    __call = Object.new})
setmetatable(Class, Class.__objmt)

local Protocol = Class{"Protocol";
  --Metamethods
  __newindex = function(self, key, value)
    assert(type(key) == "string", "Keys must be strings!")
    assert(type(value) == "string", "Values must be strings!")
    rawset(self, key, value)
  end,
  __pairs = function(self)
    local num = 0
    return function(self, index)
      local k, v = index, nil
      repeat
        k, v = next(self.__parents[num] or self, k)
        if not k and num <= #(self.__parents)then
          num = num + 1
          k, v = next(self.__parents[num] or self)
        end
      until (not reserved[k] and k ~= "super")
      return k, v
    end, self, nil
  end,
  __index = function(self, key)
    for _, parent in pairs(self.__parents) do
      if parent[key] then
        return parent[key]
      end
    end
  end,
  --Constructor
  _alloc = function(self)
    local obj = self.super.alloc(self)
    obj.__parents = {}
    return obj
  end,
  init = function(self, protocol)
    local name = protocol[1] or protocol.name
    local parents = protocol[2] or protocol.extends
    protocol[1], protocol.name, protocol[2], protocol.extends 
        = nil, nil, nil, nil
    self.__name = name
    if type(parents) == "table" then
      self.__parents = parents
    elseif type(parents) == "Protocol" or type(parents) == "nil" then
      self.__parents = {parents}
    else
      error "extends must either be a table or a Protocol"
    end
    for k, v in pairs(protocol) do
      self[k] = v
    end
    return self
  end,
  --Methods
  isKindOf = function(self, name)
    if self:name() == name then
      return true
    end
    for _, parent in pairs(self.__parents) do
      if parent:isKindOf(name) then
        return true
      end
    end
    return false
  end
}

function Protocol:name()
  return self.__name
end
      
return setmetatable({Object = Object,class = Class, Class = Class,
    Protocol = Protocol, type = type}, 
  {__call = function(_, inter) return Class:new(inter) end})
