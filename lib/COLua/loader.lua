local COLua = require "COLua"

local function load(file)
  -- Create the environment
  local env = {}
  local name = "Unnamed"
  local parent = nil
  local isClass = false
  local isProto = false

  function env.class(ident)
    if isClass then
      error("Trying to define multiple classes in one file!")
    elseif isProto then
      error("Trying to define a prototype and a class in one file!")
    end
    isClass = true
    name = ident or "Unnamed"
    rawset(env, name, {})
  end

  function env.prototype(ident)
    if isClass then
      error("Trying to define a class and a prototype in one file!")
    elseif isProto then
      error("Trying to define multiple prototypes in one file!")
    end
    isProto = true
    name = ident or "Unnamed"
    rawset(env, name, {})
  end

  function env.extends(ext)
    print("New parent: "..tostring(ext))
    parent = ext
  end

  setmetatable(env, {__index = _G, __newindex = function(tab, key, value)
    if tab[name] then
      tab[name][key] = value
    else
      error("No class or prototype is defined yet!")
    end
  end})

  -- load the file
  local chunk, reason = loadfile(file, 't', env)
  if chunk then
    chunk()
    env[name][1] = name
    env[name].extends = parent
    print("name: "..name)
    print("parent: "..tostring(parent))
    if isClass then
      return COLua.class(env[name])
    elseif isProto then
      return COLua.prototype(env[name])
    else
      return nil, "No class or prototype found"
    end
  else
    return nil, reason
  end
end

return load
