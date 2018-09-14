pragma solidity ^0.4.24;

import "./openzeppelin-solidity/token/ERC20/StandardToken.sol";

contract Token is StandardToken {
    string public constant name = "ERC20 Token";
    string public constant symbol = "TOK";
    uint256 public constant decimals = 0;
    
    uint256 public constant initialSupply = 1000000000;
    
    constructor() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    function approveInfinite(address _spender) public returns (bool) {
        return super.approve(_spender, uint(-1));
    }
}