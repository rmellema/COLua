local COLua = require "COLua"
local Protocol = COLua.Protocol
local Class = COLua.Class
local type = COLua.type

print "Start Test!"
local ProtoFoo = Protocol{"ProtoFoo";
  foo = "function",
  bar = "function"
}
print(type(ProtoFoo))
print(ProtoFoo:name())

local Foo = Class{"Foo";
  implements = ProtoFoo;
  foo = function(self)
    print "Foo"
  end,
  bar = function(self)
    print "Bar"
  end
}
print(type(Foo))
print(Foo:isKindOf("ProtoFoo"))

--[[ This will error
local Bar = Class{"Bar";
  implements = ProtoFoo;
}
--]]

local ProtoBar = Protocol{"ProtoBar", extends = ProtoFoo;
  foobar = "function"
}

local FooBar = Class{"FooBar", extends = Foo, implements = ProtoBar;
  foobar = function(self)
    print "foobar"
  end
}
print(Foo:isKindOf("ProtoFoo"))

--[[ This will error as well
local BarFoo = Class{"BarFoo", implements = ProtoBar;
  foobar = function(self)
    print "foobar"
  end
}
--]]
