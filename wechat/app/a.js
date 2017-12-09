// Jerry 2017-12-9 11:39AM we can currently treat module as a keyword in nodejs environment

console.log('module.id: ', module.id);
console.log('module.exports: ', module.exports);
console.log('module.parent: ', module.parent);
console.log('module.filename: ', module.filename);
console.log('module.loaded: ', module.loaded);
console.log('module.children: ', module.children);
console.log('module.paths: ', module.paths);

/*
require 并不是全局性命令，而是每个模块提供的一个内部方法，也就是说，
只有在模块内部才能使用 require 命令（唯一的例外是 REPL 环境）。
另外，require 其实内部调用 Module._load 方法。

模块的加载实质上就是，注入exports、require、module三个全局变量，
然后执行模块的源码，然后将模块的 exports 变量的值输出。


output:
module.id:  .
module.exports:  {}
module.parent:  null
module.filename:  C:\Code\git\wechat\app\a.js
module.loaded:  false
module.children:  []
module.paths:  [ 'C:\\Code\\git\\wechat\\app\\node_modules',
  'C:\\Code\\git\\wechat\\node_modules',
  'C:\\Code\\git\\node_modules',
  'C:\\Code\\node_modules',
  'C:\\node_modules' ]

*/