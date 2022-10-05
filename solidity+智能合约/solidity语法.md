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

​			公开可见的函数参数一定是memory类型，如果要求是storage则必须是private或者internal函数