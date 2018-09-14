pragma solidity ^0.4.24;

import "./openzeppelin-solidity/ownership/Ownable.sol";
import "./openzeppelin-solidity/token/ERC827/ERC827Token.sol";

contract Token is ERC827Token, Ownable {
    uint256 public constant decimals = 0;
    string public constant name = "ERC827 Token";
    string public constant symbol = "TOK";
    
    mapping (address => bool) erc827Whitelist;
    
    constructor(uint256 initialSupply) public {
        owner = msg.sender;
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    function addToERC827Whitelist(address _spender) public onlyOwner {
        erc827Whitelist[_spender] = true;
    }
    
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _data
    )
        public
        payable
        returns (bool)
    {
        require(erc827Whitelist[msg.sender]);
        // force first passed in parameter to be msg.sender
        // this deviates from ERC827, but prevents falsifying msg.sender
        bytes memory senderAndData = abi.encodePacked(msg.sender, _data);
        return super.approveAndCall(
            _spender,
            _value,
            senderAndData
        );
    }
    
    // TODO: similarly wrapped versions of increaseApprovalAndCall, etc.
}

contract Marketplace {
    event Listing(address _seller, uint256 _deposit, bytes32 ipfshHash);
    
    Token token;
    
    constructor(Token _token) public {
        token = _token;
    }
    function proxiedCreateListing(
        address _seller, // the original msg.sender *must* be first parameter
        uint256 _deposit,
        bytes32 _ipfsHash
    ) public payable {
        // msg.sender would be token address here
        require(msg.sender == address(token), "proxied function must be called by token");
        require(_seller != address(token), "token can't be the seller");
        require(address(this) != address(token), "marketplace can't be the seller");
        
        require(token.transferFrom(_seller, address(this), _deposit));
        emit Listing(_seller, _deposit, _ipfsHash);
    }
}

contract TestERC827 {
    uint256 constant supply = 100;
    uint256 constant deposit = 42;
    bytes32 constant ipfsHash = 0xbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeef;
    
    function test() public {
        Token token = new Token(supply);
        require(token.balanceOf(address(this)) == supply, "balance doesn't match");
        token.addToERC827Whitelist(address(this));
        
        Marketplace marketplace = new Marketplace(token);
        token.approveAndCall(
            marketplace,
            deposit,
            abi.encodeWithSignature(
                "proxiedCreateListing(address,uint256,bytes32)",
                address(this) /* this will be overwritten */, deposit, ipfsHash
            )
        );
    }
}