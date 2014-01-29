--- An OOP module for lua
local metamethods= {__tostring = true, __len = true, __gc = true, __unm = true, __add = true, __sub = true, __mul = true, __div = true, __pow = true, __concat = true, __eq = true, __lt = true, __le = true}

local function registerValue(clss, key, value)
  checkArg(2, key, "string")
  if metamethods[key] then
    clss.objmt[key] = value
  elseif key:sub(1,1) == '_' and then
    rawset(clss, key:sub(2, -1), value)
  else
    rawset(clss.methods, key, value)
  end
end

local function registerMethod(obj, key, value)
  rawset(obj, key, value)
end

local Object = {}
Object.methods = {}
Object.__name = "Object"
Object.methods.__type = "Object"
Object.methods.__class = Object

function Object:new(...)
  return self:alloc():init(...)
end

function Object:alloc()
  return setmetatable({}, self.objmt)
end

function Object:type()
  return self.__name
end

function Object.methods:init()
  return self
end

function Object.methods:class()
  return self.__class
end

function Object.methods:type()
  return self.__type
end

function Object:isKindOf(name)
  if self.__name == name then return true end
  if self.super then
    return self.super:isKindOf(name)
  else
    return false
  end
end

function Object.methods:isTypeOf(name)
  if self:type() == name then return true end
  local class = self:class()
  if class.super then
    return class.super:isKindOf(name)
  else
    return false
  end
end

Object.registerValue = registerValue
Object.methods.registerValue = registerMethod
Object.objmt = {__index = Object.methods, __newindex = registerMethod, __metatable = ""}
setmetatable(Object, {__newindex = registerValue, __call = Object.new, __metatable = ""})
setmetatable(Object.methods, {__newindex = registerMethod, __metatable = ""})

local function class(tab, proto)
  proto = proto or tab
  checkArg(1, proto, "table")
  local parent = proto.extends or Object
  proto.extends = nil
  local name = (proto.name or "Unnamed")
  local clss = {}
  clss.__name = name
  clss.methods = setmetatable({}, {__index = parent.methods, __newindex = registerMethod, __metetable = ""})
  clss.methods.__type = name
  clss.methods.__class = clss
  clss.super = parent
  local mt = {__index = parent, __newindex = registerValue, __call = clss.new, __metatable = ""}
  clss.objmt = {__index = clss.methods, __newindex = registerMethod, __metatable= ""}
  for k, v in pairs(metamethods) do
    if not proto[k] then
      proto[k] = parent.objmt[k]
    end
  end
  for key, value in pairs(proto) do
    if metamethods[key] then
      clss.objmt[key] = value
      if key == "__tostring" then
        clss.methods.tostring = value
      end
    else
      registerValue(clss, key, value)
    end
  end
  return setmetatable(clss, mt)
end
  
return setmetatable({Object = Object, class = class}, {__call = class})