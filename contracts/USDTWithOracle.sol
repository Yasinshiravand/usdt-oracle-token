// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract USDTWithOracle {
    string public name = "Tether USD";
    string public symbol = "USDT";
    uint8 public decimals = 6;
    uint256 public totalSupply;
    address public owner;

    uint256 public usdtPriceUSD; // قیمت USDT به دلار با 6 رقم اعشار
    uint256 public lastPriceUpdate;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event PriceUpdated(uint256 newPrice, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // ----------- عملیات توکن -----------
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0) && to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        uint256 minted = amount * 10 ** uint256(decimals);
        balanceOf[to] += minted;
        totalSupply += minted;
        emit Transfer(address(0), to, minted);
    }

    function burn(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // ----------- اوراکل قیمت USDT -----------
    function updateUSDTPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Invalid price");
        usdtPriceUSD = _price;
        lastPriceUpdate = block.timestamp;
        emit PriceUpdated(_price, block.timestamp);
    }

    function getUSDTPrice() external view returns (uint256) {
        return usdtPriceUSD;
    }

    // اصلاحات برای جلوگیری از خطای "Ether unit denomination is not supported by the compiler"
    function checkPrice(uint256 price) external view returns (bool) {
        if (price > 1 * 10**18 + tx.gasprice * 200000) {
            return true;
        }
        return false;
    }
}
