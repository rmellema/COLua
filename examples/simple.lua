local class = require "COLua"

print("Start testing!")
local Foo = class{name = "Foo",
  n = 5,
  _n = 10,
  _answer = 42,
  __tostring = function(self) return self:type()..': '.. self.n end}

local obj = Foo:new()
local obj2 = Foo:new()

print(obj:type())
print(obj.n ..' '..obj2.n..' '..Foo.n)
obj.n = 9
print(obj.n..' '..obj2.n..' '..Foo.n)
Foo.m = 5
obj2.m = 7
print(obj.m ..' '..obj2.m..' '.. tostring(Foo.m))
print(obj)
print("-------")
local Bar = class{name = "Bar", extends = Foo, _answer = "None", n = 1}
print(Foo.answer)
print(Bar.answer)

local obj3 = Bar:new()
print(obj)
print(obj3)

