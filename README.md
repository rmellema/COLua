COLua
=====

COLua (Classes and Objects for Lua) is a Lua 5.2 module that adds supports for Object Oriented Programming. To install it, all you need to do is install `COLua.lua` in your `package.path`. Then you can load it using `local class = require "COLua"`. Examples for using COLua can be found in `examples`. 

One of the goals of COLua is to also work in environments where C code is not available. Therefore, COLua shall be implemented in pure Lua 5.2. It is currently also compatible with Lua 5.1, but this might not always be the case.

The official source of documentation for COLua is our [wiki](https://github.com/Wobbo/COLua/wiki). This should alwasy be the most up to date source of information. But if you can't find what you are looking for, you can alwasy send me an email or open an issue on the [issue tracker](https://github.com/Wobbo/COLua/issues).

Features
========
COLua (Classes and Objects for Lua) is a Lua 5.2 module that adds supports for Object Oriented Programming. It currently features:
* Inheritance
* Distinction between classes and objects
  * Distinction between class (static) methods and object (instance) methods
* Easy way to add new methods
* Method overriding
* Implemented in pure Lua

It also exports one class, [`Object`](Object), that is the superclass for all other objects. 
