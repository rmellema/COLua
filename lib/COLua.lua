--- An OOP module for lua
local reserved = {__type = true, __methods = true, __proto = true, __objmt = true, __index = true, __newindex =true, __metatable = true} 

local function registerValue(clss, key, value)
  assert(type(clss) == "table", "Trying to register a value on a non table")
  assert(type(key) == "string", "The key must be a string!")
  if key:sub(1,2) == '__' and not reserved[key] then
    clss.__objmt[key] = value
    clss.__objmt.__metatable[key] = value
  elseif key:sub(1,1) == '_' then
    if reserved[key] then error("Trying to set field: "..key.." of a class") end
    rawset(clss, key:sub(2, -1), value)
  else
    rawset(clss.__methods, key, value)
  end
end

local function registerMethod(obj, key, value)
  rawset(obj, key, value)
end

local oldType = type
local function type(obj)
  if oldType(obj) ~= "table" then
    return oldType(obj)
  else
    if obj.type and oldType(obj.type) == "function" then
      return obj:type()
    else
      return oldType(obj)
    end
  end
end


local Object = {}
Object.__methods = {}
Object.__type = "Object"
Object.__methods.__type = "Object"
Object.__methods.__class = Object
Object.__proto = {}

function Object:new(...)
  return self:alloc():init(...)
end

function Object:alloc()
  return setmetatable({super = self.super.__methods}, self.__objmt)
end

function Object:type()
  return self.__type
end

function Object:implements(proto)
  if self.__proto[proto.__name] then return true end
  local implement, mismatch = true, nil
  for k, v in pairs(proto)do
    assert(type(k) == "string", "The key must be a string!")
    if not reserved[k] then
      local comp
      if k:sub(1,2)== '__' then
        comp = self.__objmt[key]
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
  end
  if implement then
    self.__proto[proto.__type] = true
  end
  return implement, mismatch
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
  if self:type() == name or self.__proto[name] then return true end
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
Object.__objmt = {__index = Object.__methods, __newindex = registerMethod, __metatable = {}}
setmetatable(Object, {__newindex = registerValue, __call = Object.new, __metatable = ""})
setmetatable(Object.__methods, {__newindex = registerMethod, __metatable = ""})

local function prototype(tab, proto)
  proto = proto or tab
  local name = proto[1] or "Unnamed"
  proto[1] = nil
  proto.__type = name
  for k, v in pairs(proto) do
    if type(v) ~= "string" then
      error("Invalid prototype, values must be strings")
    end
  end
  return proto
end

local function class(tab, inter)
  inter = inter or tab
  assert(type(inter) == "table", "The interface must be a table!")
  local parent = inter.extends or Object
  inter.extends = nil
  local name = (inter[1] or "Unnamed")
  inter[1] = nil
  local prototypes = inter.implements or {}
  local clss = {}
  clss.__name = name
  clss.__methods = setmetatable({}, {__index = parent.__methods, __newindex = registerMethod, __metetable = ""})
  clss.__methods.__type = name
  clss.__methods.__class = clss
  clss.__proto = {}
  clss.super = parent
  local mt = {__index = parent, __newindex = registerValue, __call = clss.new, __metatable = ""}
  clss.__objmt = {__index = clss.__methods, __newindex = registerMethod, __metatable= {}}
  for k, v in pairs(parent.__objmt) do
    if not reserved[k] then
      clss.__objm[k] = v
    end
  end
  setmetatable(clss, mt)
  for key, value in pairs(inter) do
    clss[key] = value
  end
  mt.__call = clss.new
  for i = 1, #prototypes do
    local imp, mismatch = clss:implements(prototypes[i])
    if not imp then
      error("Class "..name.." claims to implement "..prototypes[i].__name..", but doesn't implement "..mismatch)
    end
  end
  return clss
end
  
return setmetatable({Object = Object, class = class, prototype = prototype, type = type}, {__call = class})
