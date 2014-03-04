local String = require "COLua.String"

print("Parent: "..tostring(String))

class "Foo" extends(String)

function Foo:bar(value)
  print(value)
end

function Foo:_staticbar(value)
  print("Static "..value)
end
