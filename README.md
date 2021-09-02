# simple lua class
## 介绍
1. 适用于**Lua 5.1**版本与**LuaJIT**，使用table与metatable来模拟面向对象；
2. 每个类属性、类方法、实例方法在内存中仅有一个实例，子类继承父类不会拷贝父类的任何属性；
3. 对象属性建议在构造函数中创建，每个实例各自拥有一份；
4. 除去nil外，目前允许用作父类的仅有table和userdata，如果需要特殊父类，可以修改源码或者进行包装；
5. 提供了lua元表中支持的各运算符重载接口以及字符串化重载接口。

## 示例
```
require("class")

local Person = Class()
Person.count = 10               -- 类属性

function Person.classMethod()   -- 类方法
    print("person class method")
end

function Person:ctor(name, age) -- 构造函数
    self.name = name
    self.age  = age             -- 实例属性
end

function Person:objectMethod()  -- 实例方法
    print("person object method")
end

function Person:tostring()      -- 重载字符串化
    return string.format("Person: %s %s", self.name, self.age)
end

local p = Person("P", 20)       -- 创建对象
local count = p.count           -- 访问类属性
p.classMethod()                 -- 调用类方法
p:objectMethod()                -- 调用实例方法
print(p)

local Student = Class(Person)   -- 继承Person类
function Student:ctor(name, age, grade)
    Person.ctor(name, age)      -- 调用父类构造函数
    self.grade = grade
end

function Student:tostring()
    return string.format("Student: %s %s %s", self.name, self.age, self.grade)
end

function Student:objectMethod() -- 重载父类实例方法
    Person.objectMethod(self)   -- 调用父类实例方法
    print("student object method")
end

local s = Student("S", 20, 2)
local count = s.count           -- 访问父类类属性
s.classMethod()                 -- 调用父类类方法
s:objectMethod()                -- 调用实例方法
print(s)
```

## API
### 构造函数
```
function Example:ctor(arg0, arg1)
    self.arg0 = arg0
    self.arg1 = arg1
end
```

### 类只读属性
* `cls.__super`指向父类
* `cls.__rawstr`获取类字符串（例如`class: 000001F60796BA10`）
* `cls:instanceof(cls)`判断是否为参数的子类

### 对象只读属性
* `obj.__cls`指向类
* `obj.__rawstr`获取对象字符串（例如`object: 000001F60796BA10`）
* `obj:instanceof(cls)`判断是否为类的实例

### 重载运算符

```
-- 重载字符串
function Example:tostring()
    return self.__rawstr        -- 默认逻辑
end

-- 重载调用操作
function Example.operatorcall(self, ...)
end

-- 重载加法操作
function Example.operatoradd(op1, op2)
end

-- 重载减法操作
function Example.operatorsub(op1, op2)
end

-- 重载乘法操作
function Example.operatormul(op1, op2)
end

-- 重载除法操作
function Example.operatordiv(op1, op2)
end

-- 重载次方操作
function Example.operatorpow(op1, op2)
end

-- 重载取余操作
function Example.operatormod(op1, op2)
end

-- 重载取负操作
function Example.operatorunm(op1, op2)
end

-- 重载连接操作
function Example.operatorconcat(op1, op2)
end

-- 重载等号比较
function Example.operatoreq(op1, op2)
end

-- 重载小于比较
function Example.operatorlt(op1, op2)
end

-- 重载小于等于比较
function Example.operatorle(op1, op2)
end
```

在lua中，对于双目运算符，op1和op2的类型可能不同，只要有一个重载了运算符，lua便会调用该运算符函数，并且将左侧操作数作为第一个参数，右侧操作数作为第二个参数。

例如：
```
local Example = Class()
function Example.operatoradd(op1, op2)
    print(op1)  -- 12.0
    print(op2)  -- object
    return 0
end

local e1 = Example()
local e2 = 12 + e1      -- e2=0
```
