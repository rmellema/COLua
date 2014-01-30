COLua
=====

COLua (Classes and Objects for Lua) is a Lua 5.2 module that adds supports for Object Oriented Programming. To install it, all you need to do is install `COLua.lua` in your `package.path`. Then you can load it using `local class = require "COLua"`. Examples for using COLua can be found in `examples`. 

Usage
-----
COLua exports a function, called `class` and a root object for other objects, called `Object`. `class` returns a new class object that inherits from `Object` upon which you can install new methods. New objects are created by calling new on a class.
 
###Classes and objects
COLua makes a distinction between static (class) methods and instance (object) methods. Both are defined on the class, but using a differnent name. Instance methods are created in the normal way, and are only callable on the objects. So, although you create them on the class, you don't call them from the class. Static methods are defined by prepending your method name by a `_` (underscore). COLua will remove the underscore on the actual function, so you must leave it out when you call the function. 

###Constructors
COLua uses two main constructors, and a third one for convenience reasons. The first constructor is `alloc`. This constructor is placed on the class and creates the new object and sets the metatable. You normally don't need to override this constructor, but when you do, make sure to start with a call to `self.super.alloc` passing `self` as the first argument so that the superclass can make the first steps in creating the object. 

The second constructor is `init` and it is used to initialise the object. Normally, you want to override this constructor. If you want to call the implementation of init from the superclass, use `self.super.init` passing self as the first argument. The current implementation is `Object` does nothing, so you shouldn't have to call it in subclasses. 

The third constructor is `new` and it is callable from the class. If first calls `alloc` on the class and then calls `init` on the allocated object, passing any arguments it might have recieved.

###Overriding
Overriding is as simple as registering the method that you want to override. The original method on the superclass can be found at `self.super.originalMethod`. In order to call it, you must use the normal way to call a function, so no colons in the function call.

###Creating classes with methods
Normally, you want to create classes that already have methods on them, instead of adding them afterwards. This can be done by giving an interface to `class`. An interface is a table with method names as keys and methods or values as values. 

The interface also has to special fields, the first element in the interface to signal the type of the class and `extends` to give the superclass of the object. If `extends` is nil, `Object` is used as superclass.

To create a static method, you simply preface the name with a `_`, just like when creating methods on the class itself.

###Classes, objects and metamethods
You can also set the metamethod of an object, but not of a class. COLua will detect when you try to set a metamethod, and will move this to the metatable for the object, even when it starts with a `_`. Setting metamethods on a class is impossible. 

`__tostring` will also automatically be installed on the objects as `tostring`, for convenience.


