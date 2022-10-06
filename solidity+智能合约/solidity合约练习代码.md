示例代码1：

```solidity
pragma solidity >=0.4.0 <0.6.0;

contract SimpleStorage {
   uint storedData;

   function set(uint x) public {
      storedData = x;
   }

   function get() public view returns (uint) {
      return storedData;
   }
}

```

示例代码2：

```solidity
pragma solidity ^0.4.22;
contract test{
    int8 i=4;                          //将int8改成uint再试一试
    function reverse()public  view returns(int8){//别忘记更改返回值的类型
        return (~i);
    }
}
```

