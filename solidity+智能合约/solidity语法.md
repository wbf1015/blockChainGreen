1、pragram 版本杂注 		^0.4.0隐含不能高于0.5.0

2、import导入其他源文件

​		import “filename” 导入所有全局符号

​		import * as symbolName from "filename" 创建一个新的全局符号

​		import{symbol1 as alias ,symbol2} from "filename"

​		import "filename" as symbolName

3、基本的数据类型

​		bool值、

​		整型（int uint）、

​		fixed/unfixed：有符号和无符号定长浮点数 fixedMxN(M位数字长度，N位小数)

​		address：存储20字节的值（以太坊地址）

​		定长字节数组：关键字有bytes1，bytes2，bytes3，...，bytes32---输入16进制字符串

​		枚举（enum）默认从零开始递增

​		函数

​		合约本身也可以是数据类型

4、引用数据类型

​		数组（Array）：可以指定长度就是定长数组，也可以动态调整大小；对于存储型--永久存储空间（storage）来讲，元素类型任意（数组映射结构体）；对于内存型（memory）的数组来说，元素类型不能是映射（mapping）类型

​		结构（struct）：构造结构体定义新的数据类型

​		映射（mapping）：映射可以看做哈希表，初始化时创建每个可能的key，并将其映射到字节形式全是零的值（类型默认值）

5、地址类型：address

​		0.5.0引入address payable：只有这个才能调用transfer和send	

​		0.5.0开始，合约不再由地址类型派生 记得加入payable的回退函数

​		address.balance(uint256):该地址的ether余额，以Wei为单位

​	**transfer和send：给address发，谁调用给谁发，从合约发给address**

​		address.transfer(uint256 amount)：向指定地址发送数量为amount的ether，发送的gas为2300，不可调节，失败抛出异常

​		address.send(uint256 amount)：失败时返回false

​	**下面的call不推荐使用**（也可以使用call进行转币）

​		address.call(bytes memory) returns (bool,bytes memory):发出底层函数，失败时返回false，发送所有可用的gas(剩下的gas也全都发)

​		address.delegatecall(bytes memory) returns (bool,bytes memory)：代理调用

​		address.staticcall(bytes memory) returns (bool,bytes memory)：静态调用，不能有状态改变

6、字节数组

​		属于值类型，bytes1、bytes2...，bytes32

​		有一个只读的length属性

​		变长字符数组:属于引用类型：bytes（--hex）字符串和String（--UTF-8编码）

```solidity
contract learn{
    fixed128x20 b;
    function test() public pure returns(uint){
        bytes32 a;
        return a.length;
    }
}
```

7、枚举Enum

​		自定义一组常量值：枚举类型对应整型值（可以转换成任意类型的整型）

```solidity
contract learn1{
    enum Weekday{Monday,Tuesday,Sunday}
    function learn1_function1() public pure returns(uint8){
            Weekday w=Weekday.Sunday;
            return uint8(w);
    }
}
```

8、数组

​		固定大小为K的和元素类型为T的数组被写为：T[k]

​		动态大小的数组：T[]，uint【】【5】 表示一个由5个uint动态数组组成的数组（二维数组），其定义和C语言相反

​		访问的时候又和C语言一致了x【2】【1】访问第三个动态数组的第二个uint

​		越界访问数组会导致回退

​		如果要添加新元素则必须使用.push()或者将length扩大

​		.length只能对storage生效

​		memory下必须指定长度，其长度可以是变量，但定下来之后就不能改变了

​		变长的storage数组和bytes（不包括string）有一个push方法。可以将一个新元素附加到数组末端，返回值为当前的长度

```solidity
contract learn2{
    function f(uint len)public pure returns(uint){ 
        uint[]memory a=new uint[](7);
        bytes memory b=new bytes(len);
        assert(a.length==7);
        assert(b.length==len);
        a[6]=8;
        return a[6];
    }
}
```

9、结构

​		结构类型可以在映射和数组中使用，他们本身也可以包含映射和数组

​		结构不能包含自己类型的成员，但是可以作为自己数组成员的类型，也可以作为自己映射成员的值类型



10、Mapping(_KeyType ==> _ValueType)

​		键的类型可以是任何基本类型，加上字符数组和字符串，不允许使用用户定义的或复杂类型，如枚举，映射，结构以及除bytes和string之外的数组类型

​		值类型可以是任何类型

```solidity
pragma solidity >0.4.22;
contract C{
    mapping (address=>uint)balances;
    function update(uint amount) public{
        balances[msg.sender]=amount;
    }
    function getBalance(address _addr) public view returns(uint){
        return balances[_addr];
    }
}

contract D{
    function func() public returns(uint,address){
        C con=new C();
        con.update(10);
        return (con.getBalance(address(this)),address(this));
    }
}
```

```solidity
pragma solidity >0.4.22;

contract C{
    mapping (address=>uint)balances;
    constructor() public {
        balances[address(this)]=300;
    }
    function update(uint amount) public{
        balances[msg.sender]=amount;
    }
    function getBalance(address _addr) public view returns(uint){
        return balances[_addr];
    }
}

contract D{
    function func() public returns(uint){
        C con=new C();
        con.update(10);
        return con.getBalance(address(con));
    }
}
```

11、solidity的数据位置（非常重要）

​		所有的复杂类型（数组、结构、映射）类型都有一个额外属性即数据位置，用来说明数据存储在memory还是storage

​		根据上下文不同，大多数数据有其默认位置，但也可以通过在类型名后指定进行存储位置的修改

​		函数参数（包括返回的参数）的数据位置默认是memory，局部变量的数据位置是storage（引用类型）栈（值类型），状态变量的数据位置强制是storage

​		第三种存储位置：calldata，这是一块只读的，且不会永久存储的位置，用来存储函数参数。外部函数的参数的数据位置在calldaya

强制：外部参数（calldata）状态变量（storage）

默认：函数参数+返回参数（memory） 引用类型（mapping struct 数组）的局部变量（storage） 值类型的局部变量（栈）

​			公开可见的函数（public）参数一定是memory类型，如果要求是storage则必须是private或者internal函数

​		storage是一个非常大的存储空间：如何管理这么大的存储空间：使用hash并且一个非常大的空间，避免了hash碰撞，但同样根本没有办法遍历这个存储空间

12、下面的代码存在漏洞：

```solidity
pragma solidity >0.4.0;
contract C{
    uint public a;
    uint public b;
    uint[] public data;
    function g(uint input)public{
        a=input;
    }
    function f() public{
        uint[] x;//野指针，变长数组的第一个位置存储其长度，由于一开始没有决定指向哪里，所以他的位置指向合约的零地址
        //找长度：就是x指针的位置
        //找元素：找的元素+指针的位置共同算hash
        //storage类型的变成指针 引用类型放在storage中
        //改进：直接让x指向data
        x.push(2);
        data=x;
    }
}

```







自学solidity：奇异谷网址：https://www.qikegu.com/docs/4834

一、数据类型：

![image-20221006191407420](C:\Users\魏伯繁\AppData\Roaming\Typora\typora-user-images\image-20221006191407420.png)

地址类型：20字节的16进制数表示。.balance获取余额 .transfer进行转账

```solidity
address x = 0x212;
address myAddress = this;

if (x.balance < 10 && myAddress.balance >= 10) 
    x.transfer(10);//这是给x转账，用这个合约的以太转账给0x212

```

Solidity中，有一些数据类型由值类型组合而成，相比于简单的值类型，这些类型通常通过名称引用，被称为引用类型。

引用类型包括：

- 数组 (字符串与bytes是特殊的数组，所以也是引用类型)
- struct (结构体)
- map (映射)

二、变量以及变量的作用域

```solidity
pragma solidity ^0.5.0;
contract SolidityTest {
   uint storedData; // 状态变量
   constructor() public {
      storedData = 10;   
   }
   function getResult() public view returns(uint){
      uint a = 1; // 局部变量
      uint b = 2;
      uint result = a + b;
      return storedData; // 访问状态变量
   }
}

```

状态变量

局部变量

全局变量：提供有关区块链和交易属性的信息

| 名称                                          | 返回                                                     |
| :-------------------------------------------- | :------------------------------------------------------- |
| blockhash(uint blockNumber) returns (bytes32) | 给定区块的哈希值 – 只适用于256最近区块, 不包含当前区块。 |
| block.coinbase (address payable)              | 当前区块矿工的地址                                       |
| block.difficulty (uint)                       | 当前区块的难度                                           |
| block.gaslimit (uint)                         | 当前区块的gaslimit                                       |
| block.number (uint)                           | 当前区块的number                                         |
| block.timestamp (uint)                        | 当前区块的时间戳，为unix纪元以来的秒                     |
| gasleft() returns (uint256)                   | 剩余 gas                                                 |
| msg.data (bytes calldata)                     | 完成 calldata                                            |
| **msg.sender (address payable)**              | **消息发送者 (当前 caller)**                             |
| msg.sig (bytes4)                              | calldata的前四个字节 (function identifier)               |
| msg.value (uint)                              | 当前消息的wei值                                          |
| now (uint)                                    | 当前块的时间戳                                           |
| tx.gasprice (uint)                            | 交易的gas价格                                            |
| tx.origin (address payable)                   | 交易的发送方                                             |



局部变量的作用域仅限于定义它们的函数，但是状态变量可以有三种作用域类型。

- **Public** – 公共状态变量可以在内部访问，也可以通过消息访问。对于公共状态变量，将生成一个自动getter函数。
- **Internal** – 内部状态变量只能从当前合约或其派生合约内访问。
- **Private** – 私有状态变量只能从当前合约内部访问，派生合约内不能访问。

```solidity
pragma solidity ^0.5.0;
contract C {
   uint public data = 30;
   uint internal iData= 10;

   function x() public returns (uint) {
      data = 3; // 内部访问--即在定义该状态变量的合约内访问
      return data;
   }
}
contract Caller {
   C c = new C();
   function f() public view returns (uint) {
      return c.data(); // 外部访问--在其他智能合约内访问其他只能合约的状态变量
   }
}
contract D is C {//D合约是C合约
   uint storedData; // 状态变量

   function y() public returns (uint) {
      iData = 3; // 派生合约内部访问
      return iData;
   }
   function getResult() public view returns(uint){
      uint a = 1; // 局部变量
      uint b = 2;
      uint result = a + b;
      return storedData; // 访问状态变量
   }
}

```

三、位运算符

![image-20221006193027744](C:\Users\魏伯繁\AppData\Roaming\Typora\typora-user-images\image-20221006193027744.png)

四、条件运算符

```solidity
pragma solidity ^0.4.22;
contract learn{
    uint a=5;
    uint b=10;
    function test()public view returns(bool){
        return(a>b?true:false);//重点关注这一句 前面为真就返回true，反之返回false
    }
}

```

 五、数据存储位置

Solidity中，有一些数据类型由简单数据类型组合而成，相比于简单的值类型，这些类型通常通过名称引用，被称为引用类型，

引用类型包括：

- 数组 (字符串与bytes是特殊的数组，所以也是引用类型)
- struct (结构体)
- map (映射)

这些类型涉及到的数据量较大，**复制它们可能要消耗大量Gas**，非常昂贵，所以使用它们时，必须考虑存储位置，例如，是保存在内存中，还是在EVM存储区中。

## 数据位置(data location)

在合约中声明和使用的变量都有一个数据位置，指明变量值应该存储在哪里。合约变量的数据位置将会影响Gas消耗量。

Solidity 提供4种类型的数据位置。

- Storage
- Memory
- Calldata
- Stack

### Storage

该存储位置存储永久数据，**这意味着该数据可以被以太坊所有合约中的所有函数访问**。可以把它视为计算机的硬盘数据，所有数据都永久存储。

保存在存储区(Storage)中的变量，以智能合约的状态存储，并且在函数调用之间保持持久性。与其他数据位置相比，**存储区数据位置的成本较高。**

### Memory

内存位置是临时数据，比存储位置便宜。它只能在函数中访问。

通常，内存数据用于保存临时变量，以便在函数执行期间进行计算。一旦函数执行完毕，它的内容就会被丢弃。你可以把它想象成每个单独函数的内存(RAM)。

### Calldata

Calldata是**不可修改的非持久性数据位置**，所有传递给函数的值（形参值），都存储在这里。此外，Calldata是外部函数的参数(而不是返回参数)的默认位置。

### Stack

堆栈是由EVM (Ethereum虚拟机)维护的非持久性数据。EVM使用堆栈数据位置在执行期间加载变量。堆栈位置最多有1024个级别的限制。

可以看到，要永久性存储，可以保存在存储区(Storage)。

## Solidity的存储规则：

状态变量在存储区；

函数参数包括返回参数都存储在内存中。

值类型的局部变量存储在内存中。但是，对于引用类型，需要显式地指定数据位置（编译器版本大于0.5.0）。

（一）存储变量赋值给存储变量--创建新的副本：

```solidity
pragma solidity ^0.5.0;  

contract Locations {  

  uint public stateVar1 = 10;  
  uint stateVar2 = 20;  

  function doSomething() public returns (uint) {  

   stateVar1 = stateVar2;  
   stateVar2 = 30;  

   return stateVar1; //returns 20  
  }  
}   //并不是让var1的地址指向var2的地址，只是拿出值进行赋值
//该规则同样适用于引用类型
```

（二）内存变量复制到存储变量--创建新的副本

（三）存储变量复制到内存变量--创建新的副本

（四）内存变量复制到内存变量--引用类型的变量不会新建副本；但对于值类型的依然会创建新的副本

```solidity
pragma solidity ^ 0.5.0;

contract Locations {  

    function doSomething() 
        public pure returns(uint[] memory, uint[] memory) {

        uint[] memory localMemoryArray1 = new uint[](3);  
        localMemoryArray1[0] = 4;  
        localMemoryArray1[1] = 5;  
        localMemoryArray1[2] = 6;

        uint[] memory localMemoryArray2 = localMemoryArray1;  
        localMemoryArray1[0] = 10;

        return (localMemoryArray1, localMemoryArray2); 
       //returns 10,4,6 | 10,4,6    
    }  
}  
```

## 字符串

string与bytes

字符串是特殊的数组，是引用类型。

Solidity提供字节与字符串之间的内置转换，可以将字符串赋给`byte32`类型变量。

可以使用`string()`构造函数将bytes转换为字符串。

练习代码：

```solidity
pragma solidity ^0.4.22;
contract test{
    string sdata="test";
    bytes32 bdata="test";
    function doSomething()public view returns(string ,bytes32){
        return(sdata,bdata);//返回string返回的是真正的字符串，但返回bytes只返回16进制字符
    }
}
contract test2{
    string sdata="test";
    bytes data=new bytes(10);
    function doSomething()public returns(bytes){
        data="0x123456";
        return data;
    }
}
contract test3{
    string sdata;
    bytes data=new bytes(40);
    function doSomething()public returns(string){
        data="0x7465737400000000000000000000000000000000000000000000000000000000";
        data="cnm";
        sdata= string (data);
        return sdata;
    }
}

contract test4{
    bytes a=new bytes(33);
    function doSomething()public returns(bytes){
        a="cnm";
        return(a);
    }
}

contract test5{
    bytes a=new bytes(33);
    string b;
    function doSomething()public returns(string){
        a="0x123456";
        b=string (a);
        return(b);
    }
}
```

## 数组

