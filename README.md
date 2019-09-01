# 让javascript调用更顺畅的bridge 
目前大家使用的webview bridge往往存在一些问题，都是通过command的形式，H5在使用的时候还要进行二次包装，并且使用方式不够友好，感觉有点儿像是在宝马车队里面突然出现一辆拖拉机一样，不协调，效率低，易出错
> 当前还在持续开发中，文档完善中
## 支持特性
- 事件
- 属性
- 同步调用
- 异步调用

## 0x00 使用例子
这里实现的bridge让调用和原生的javascript一样顺滑，先看一个例子：
``` javascript
async function onclick() {
    webapi.x = 10
    let x = webapi.x
    let y = webapi.times(2,3)
    let z = await webapi.waitAndAdd(y)//演示异步调用
    webapi.addEventListener('play', function(){
        console.log(this.x)
    })//增加event
    webapi.trigger()//调用此函数后会触发一系列的play的event，一直到x等于16为止
}

```

## 0x01 JS stub定义
例子里面的webapi是注入的一个原生对象，在javascript里面通过一个stub注入后可以轻松调用，而stub的定义也非常简单，如下：
``` javascript 
let webapi = imp_stub(
  class extends JEventTarget {
    times(obj1, obj2) {}
    async waitAndAdd(seconds) {}
    get x() {}
    set x(newVal) {}
    trigger(){}
  },
  "webapi"
);
```
### 支持事件
通过上面的代码就完成了stub的注入，用起来十分清晰，其中通过`extends JEventTarget`来声明该对象支持事件分发

### 支持属性
通过定义get/set方法来声明支持的属性，也可以单独使用get或set

### 支持同步调用
通过定义标准成员函数的方式和空函数体来声明该函数，必须声明参数的个数和名字，具体和native的对应方式需要和这个名字对应，后序在native实现部分给予说明

### 支持异步调用
通过定义`async`的成员函数来声明，其它的和同步调用的是一样的，调用的时候必须用`await`或者用`promise`的方式

## 0x02 Native的对应实现（swift）

首先先定义一个对应的类，从BaseCommand派生如：
``` swift
class WebapiCommand : BaseCommand
```

### 事件的产生
任意时刻，调用sendEvent("#event_name#")

### 属性的支持
只要定义同名的属性，即可支持对应的`get`方法
属性的`set`方法需要定义一个set方法来辅助
``` swift
func setX(_ arg: SetVal<Int?>) -> JsDone {
    x = arg.newVal
    return JsDone()
}
```
然后在对应的调用表中增加一行，比如：
``` swift 
    setterCalls = ["x": JsCmdUtil.toArg <+> setX]
```

### 同步方法的调用
#### 参数的定义
参照`times(obj1,obj2)`这个方法，定义对应的参数对象
``` swift
struct Arg: Codable {
    let obj1 : Int
    let obj2 : Int
}
```
注意一个是`Codable`的实现，其实`Decodable`应该就行了，另外定义的两个对象要和js里stub的参数名要一样，类型传入要和这里定义的一样，否则调用的时候都会抛出异常

#### 方法的定义
方法的参数就是刚才定义的参数对象，返回值是我们要返回的类型
``` swift
private static func times(_ args: Arg) -> Int {
    return args.obj1 * args.obj2
}
```

然后把函数增加到同步调用的列表中
``` swift
syncCalls = ["times": JsCmdUtil.toArg <+> times <+> JsCmdUtil.toJsValueReturn]
```

这里用了函数的compose，表示把输入先Decode成Arg，然后调用times，最后把返回值进行包装
如果不需要返回值，可以直接返回JsDone，参考例子中的`trigger`

### 异步方法的调用
和同步方法不同的是，这里的返回值是一个Future类型，看下面的代码，可以和同步代码进行一下比较
``` swift
struct Arg1: Codable {
    let seconds : Int
}
private func waitAndAdd2(_ args: Arg1) -> JSFuture<Int> {
    let f = JSFuture<Int>()
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(args.seconds)) {
        f.succ(args.seconds + 1)
    }
    return f
}
```
同样把实现加入到异步函数列表中
``` swift 
futureCalls = ["waitAndAdd": JsCmdUtil.toArg <+> waitAndAdd2]
```
可以看到这里的返回值不需要包装，会通过future的succ进行触发