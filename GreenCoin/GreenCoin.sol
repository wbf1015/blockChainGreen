pragma solidity ^0.4.16;

contract GreenCoin{
    string public name = "Greencoin"; //币值的名称
    string public symbol = "GC"; //币值符号
    uint8 public decimals = 18;  // 18 精度默认值，避免小数运算造成末尾取舍问题，统一采用整数运算
    uint256 public totalSupply = 20000*10**18; //总的发行数额，避免滥发
    uint256 public canBeSupply;//剩余可发的，但是还没有进入流通。
    mapping (uint32 => uint256) public balanceOf;//每一个账户的余额，包括企业和个人的
    mapping (uint256 => bool) public validOf; //用来判定一个兑换码是否有效
    mapping (uint256 => uint256) public valueOf;//一个兑换码代表的金额是多少
/*
1、理论上每一个账户都应该维护一个20byte的信息，称为address，这个信息是在智能合约中唯一索引一个账户的方式，并且这个账户信息不应该被任何用户知道
2、已经为政府部门开好账户，address为0x1   其初始化代币额度由totalSupply规定
3、转移代币总共有两种方式，第一种方式是使用兑换码的方式，需要发送方输入想要转账的金额并调用getRedemption，函数会返回一个256比特的兑换码，接下来需要接收方输入兑换码方能完成转账
   第二种方法是使用直接转账函数，即使用transCoin函数即可
*/
    constructor() public {
        balanceOf[1]=totalSupply;
        canBeSupply=0;
    }

//获取代币的名字
    function getName()public view returns(string n){
        return name;
    }
//获取代币的符号
    function getSmbol()public view returns(string s){
        return symbol;
    }
//查找某个地址的代币数量
    function getBalances(uint32 a)public view returns(uint256 v){
        return balanceOf[a];
    }
//增加总发行量
    function changeTotalSupply(uint256 v)public returns(bool success){
        if(totalSupply+v<totalSupply){return false;}
        totalSupply+=v;
        canBeSupply+=v;
        return true;
    }
//将可发行量转入发行量
    function changeCanBeSupply(uint256 v)public returns(bool success){
        if(canBeSupply<v){return false;}
        canBeSupply-=v;
        balanceOf[0x1]+=v;
    }
//根据你输入的金额返回一个可以兑换等额代币的兑换码，a是转账人的地址信息
    function getRedemption(uint32 a,uint256 v)public returns (bool success,uint256 redemption){
        if(balanceOf[a]<v){return(false,0);}
        do{
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now)));
        }while(validOf[random]==true);
        uint256 r= random;
        validOf[r]=true;
        valueOf[r]=v;
        balanceOf[a]-=v;
        return(true,r);
    }
//使用兑换码，a是收款人的地址信息
    function useRedemption(uint256 redemption,uint32 a)public returns(bool success,uint256 value){
        if(validOf[redemption]!=true){return(false,0);}
        if((balanceOf[a]+valueOf[redemption])<balanceOf[a]){return(false,0);}
        validOf[redemption]=false;
        balanceOf[a]+=valueOf[redemption];
        return(true,balanceOf[a]);
    }
//将代币的金额进行转移,将from的价值为v的代币发送至to
    function transCoin(uint32 from,uint32 to,uint256 v)public returns(bool success){
        if(balanceOf[from]<v){return false;}
        if(balanceOf[to]+v<balanceOf[to]){return false;}
        balanceOf[from]-=v;
        balanceOf[to]+=v;
        return true;
    }
}