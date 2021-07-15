
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Token is Context, AccessControl {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _maxCap = 1000000000;
    bool private _paused = false;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address[] memory minters,
        address[] memory burners,
        address admin
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        for (uint256 i = 0; i < minters.length; ++i) {
            _setupRole(MINTER_ROLE, minters[i]);
        }

        for (uint256 i = 0; i < burners.length; ++i) {
            _setupRole(BURNER_ROLE, burners[i]);
        }

    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        require(_recipient != address(0), "Address of recipient is ilegal");
        require(_sender != address(0), "Address of sender is ilegal");
        require(
            _amount <= _balances[_sender],
            "Transfer amount exceeds account balance"
        );

        _balances[_sender] -= _amount;
        _balances[_recipient] += _amount;

        emit Transfer(_sender, _recipient, _amount);
    }

    function _approve(
        address _approver,
        address _spender,
        uint256 _amount
    ) private {
        require(_approver != address(0), "Address of approver is illegal");
        require(_spender != address(0), "Address of spender is illegal");

        _allowances[_approver][_spender] = _amount;

        emit Approval(_approver, _spender, _amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "Transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function mint(address account, uint256 amount)
        public
        _isNotPause
        onlyRole(MINTER_ROLE)
    {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply + amount < _maxCap, "Exeeding cap!");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function pause() public _isAdmin returns (bool){
        require(!_paused, 'Already paused');
        _paused = true;
        return true;
    }

    function unpause() public _isAdmin returns (bool){
        require(_paused, 'Already unpaused');
        _paused = false;
        return true;
    }

    function burn(address account, uint256 amount)
        public
        _isNotPause
        onlyRole(BURNER_ROLE)
    {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] = accountBalance - amount;

        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    modifier _isMinter() {
        _checkRole(MINTER_ROLE, _msgSender());
        _;
    }

    modifier _isBurner() {
        _checkRole(BURNER_ROLE, _msgSender());
        _;
    }

    modifier _isAdmin() {
        _checkRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _;
    }

    modifier _isNotPause() {
        if (_paused) {
            revert();
        }
        _;
    }
}
