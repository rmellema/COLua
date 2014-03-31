--- An OOP module for lua
local reserved = {__type = true, __methods = true, __proto = true,
    __objmt = true, __index = true, __newindex =true, __metatable = true,
    __name = true, __parents = true, __class = true} 

local function registerValue(clss, key, value)
  assert(type(clss) == "table", "Trying to register a value on a non table")
  assert(type(key) == "string", "The key must be a string!")
  if key:sub(1,2) == '__' and not reserved[key] then
    clss.__objmt[key] = value
    --clss.__objmt.__metatable[key] = value
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

local function registerMethod(obj, key, value)
  rawset(obj, key, value)
end

local oldType = type
local function type(obj)
  if oldType(obj) ~= "table" then
    return oldType(obj)
  else
    local objMt = getmetatable(obj)
    if objMT and oldtype(objMt) == 'table' and objMt.__type then
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
Object.__objmt = {__index = Object.__methods, __newindex = registerMethod,
    __type = "Object", __class = Object}

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
    assert(type(k) == "string", "The key must be a string!")
    if not reserved[k] then
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
  end
  if implement then
    self.__proto[proto.__name] = true
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
  if self.__name == name or self.__proto[name] then return true end
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
    __type = "Class", __class = Class;
    __call = function(self, ...) return self:new(...) end}
Class.super = Object

function Class:alloc(name, parent)
  local methods = setmetatable({super = parent.__methods}, 
      {__index = parent.__methods, __newindex = registerMethod})
  local new
  new = setmetatable({__name = name, super = parent,
    __methods = methods; __objmt = {
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

local function prototype(tab, proto)
  proto = proto or tab
  local name = proto[1] or "Unnamed"
  proto[1] = nil
  proto.__type = "Prototype"
  proto.__name = name
  if proto.extends then
    proto.__parents = proto.extends
    if type(proto.extends) == "Prototype" then
      proto.extends = {proto.extends}
    end
    if type(proto.extends) == "table" then
      proto.__parents = proto.extends
      setmetatable(proto, {__index = function(tab, key)
        for k, v in pairs(tab.__parents) do
          if v[key] then
            return v[key]
          end
        end
      end,
      __pairs = function(tab)
        local num = 0
        return function(prot, idx)
          local key, value = next((tab.__parents[num] or prot), idx)
          if not key then
            num = num + 1
            if tab.__parents[num] then
              key, value = next(tab.__parents[num])
            else
              return nil
            end
          end
          return key, value
        end, tab, nil
      end})
    else
      error "Trying to extend non prototypes or tables"
    end
    proto.extends = nil
  end
  for k, v in pairs(proto) do
    if type(v) ~= "string" and not reserved[k] then
      error("Invalid prototype, values must be strings, "..k.." is not a string")
    end
  end
  return proto
end

local function oldclass(tab, inter)
  inter = inter or tab
  assert(type(inter) == "table", "The interface must be a table!")
  local parent = inter.extends or Object
  inter.extends = nil
  local name = (inter[1] or "Unnamed")
  inter[1] = nil
  local prototypes = inter.implements or {}
  local clss = {}
  clss.__type = name
  clss.__methods = setmetatable({}, {__index = parent.__methods, __newindex = registerMethod, __metatable = ""})
  clss.__proto = {}
  clss.super = parent
  local mt = {__index = parent, __newindex = registerValue, __call =function(self, ...) return self:new(...) end,  __metatable = ""}
  clss.__objmt = {__index = function(self, key)
    if clss.__objmt.index then
      local ret = clss.__objmt.index(self, key)
      if ret then
        return ret
      end
    end
    return clss.__methods[key]
  end,
  __newindex = function(self, key, value)
    if clss.__objmt.newindex then
      return clss.__objmt.newindex(self, key, value)
    else
      return registerMethod(self, key, value)
    end
  end,
  __metatable= {},__type = name, __class = clss}
  for k, v in pairs(parent.__objmt) do
    if not reserved[k] then
      clss.__objmt[k] = v
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
  
return setmetatable({Object = Object,class = Class, Class = Class, oldclass = oldclass, prototype = prototype, type = type}, {__call = oldclass})
