COLua
=====

COLua (Classes and Objects for Lua) is a Lua 5.2 module that adds supports for Object Oriented Programming. To install it, all you need to do is install `COLua.lua` in you `package.path`. Then you can load it using `local class = require "COLua"`. Examples for using COLua can be found in `examples`. 

Usage
-----
COLua exports a function, called `class` and a root object for other objects, called `Object`. `class` returns a new class object that inherits from `Object` upon which you can install new methods. New objects are created by calling new on a class.
 
###Classes and objects
COLua makes a distinction between static (class) methods and instance (object) methods. Both are defined on the class, but using a differnent name. Instance methods are created in the normal way, and are only callable on the objects. So, although you create them on the class, you don't call them from the class. Static methods are defined by prepending your method name by a `_` (underscore). COLua will remove the underscore on the actual function, so you must leave him out when you call the function. 

###Creating classes with methods
Normally, you want to create classes that already have methods on them, instead of adding them afterwards. This can be done by giving an interface to `class`. An interface is a table with method namesas keys and methods or values as values. 

The interface also has to special fields, `name` to signal the type of the class and `extends` to give the superclass of the object. If `extends` is nil, `Object` is used as superclass.

To create a static method, you simply preface the name with a `_`, just like when creating methods on the class itself.

###Classes, objects and metamethods
You can also set the metamethod of an object, but not of a class. COLua will detect when you try to set a metamethod, and will move this to the metatable for the object, even when it starts with a `_`. Setting metamethods on a class is impossible. 

`__tostring` will also automatically be installed on the objects as `tostring`, for confiniance.
