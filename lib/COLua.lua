--- An OOP module for lua
local metamethods= {__tostring = true, __len = true, __gc = true, __unm = true, __add = true, __sub = true, __mul = true, __div = true, __pow = true, __concat = true, __eq = true, __lt = true, __le = true}

local function registerValue(clss, key, value)
  assert(type(clss) == "table", "Trying to register a value on a non table")
  assert(type(key) == "string" or type(key) == "number", "The key must be a string or number!")
  if metamethods[key] then
    clss.__objmt[key] = value
  elseif key:sub(1,1) == '_' then
    rawset(clss, key:sub(2, -1), value)
  else
    rawset(clss.__methods, key, value)
  end
end

local function registerMethod(obj, key, value)
  rawset(obj, key, value)
end

local Object = {}
Object.__methods = {}
Object.__type = "Object"
Object.__methods.__type = "Object"
Object.__methods.__class = Object

function Object:new(...)
  return self:alloc():init(...)
end

function Object:alloc()
  return setmetatable({super = self.super.__methods}, self.__objmt)
end

function Object:type()
  return self.__name
end

function Object.__methods:init()
  return self
end

function Object.__methods:class()
  return self.__class
end

function Object.__methods:type()
  return self.__type
end

function Object:isKindOf(name)
  if self:type() == name then return true end
  if self.super then
    return self.super:isKindOf(name)
  else
    return false
  end
end

function Object.__methods:isKindOf(name)
  return self:class():isKindOf(name)
end

Object.registerValue = registerValue
Object.__methods.registerValue = registerMethod
Object.__objmt = {__index = Object.__methods, __newindex = registerMethod, __metatable = ""}
setmetatable(Object, {__newindex = registerValue, __call = Object.new, __metatable = ""})
setmetatable(Object.__methods, {__newindex = registerMethod, __metatable = ""})

local function class(tab, proto)
  proto = proto or tab
  assert(type(proto) == "table", "The interface must be a table!")
  local parent = proto.extends or Object
  proto.extends = nil
  local name = (proto[1] or proto.name or "Unnamed")
  proto[1] = nil
  proto.name = nil
  local clss = {}
  clss.__name = name
  clss.__methods = setmetatable({}, {__index = parent.__methods, __newindex = registerMethod, __metetable = ""})
  clss.__methods.__type = name
  clss.__methods.__class = clss
  clss.super = parent
  local mt = {__index = parent, __newindex = registerValue, __call = clss.new, __metatable = ""}
  clss.__objmt = {__index = clss.__methods, __newindex = registerMethod, __metatable= ""}
  for k, v in pairs(metamethods) do
    if not proto[k] then
      proto[k] = parent.__objmt[k]
    end
  end
  for key, value in pairs(proto) do
    if metamethods[key] then
      clss.__objmt[key] = value
      if key == "__tostring" then
        clss.__methods.tostring = value
      end
    else
      registerValue(clss, key, value)
    end
  end
  setmetatable(clss, mt)
  mt.__call = clss.new
  return clss
end
  
return setmetatable({Object = Object, class = class}, {__call = class})
