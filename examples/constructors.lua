local class = require("COLua").Class

local Foo = class{"Foo";
  init = function(self, n) 
    self.n = n or self:class().n
    return self 
  end,
  _n = 42,
  _m = 32}

print "Start Test!"
local obj = Foo:new(2)
print(obj.n)
local obj2 = Foo:new()
print(obj2.n)

local Bar = class{"Bar",
  extends = Foo;
  init = function(self, n, m)
    self = self.super.init(self, n)
    self.m = m or self:class().m
    return self
  end,
  _m = 64}
local obj3 = Bar:new(3, 5)
local obj4 = Bar:new()
print(obj3.n..' '..obj3.m)
print(obj4.n..' '..obj4.m)
