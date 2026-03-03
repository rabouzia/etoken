
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;



contract Money42 {
  
  string public name = "evil42";
  string public symbol = "e42";
  uint public totalSupply;
  mapping (address => uint) public balances;
  mapping (address => mapping (address=> uint)) public allowances;
  
  address public creator;
  address[] public signatories;
  uint public requiredApprovals;

  constructor (uint _supply, address[] memory _signatories, uint _requiredApprovals) {
    require (_signatories.length > 0, "A least one signatory is required");
    require (_requiredApprovals >  0 && _requiredApprovals <= _signatories.length, "Wrong number of required approvals");
    totalSupply = _supply;
    creator = msg.sender;
    balances[creator] = _supply;
    requiredApprovals = _requiredApprovals;
    signatories = _signatories;
  }

  function getname() external view returns (string memory) {
		return name;
	}

	function getsymbol() external view returns (string memory) {
		return symbol;
	}


	function gettotalSupply() external view returns (uint) {
		return totalSupply;
	}

	function balanceOf(address _account) external view returns (uint) {
		return balances[_account];
	}

	event Transfer(address indexed from, address indexed to, uint256 _amount);
  event Approval(address indexed owner, address indexed spender, uint256 _amount);
 
  modifier onlyCreator() {
    _onlyCreator();
    _;
  }

  function _onlyCreator() internal view{
    require(msg.sender == creator, "Your are not the creator");

  }
 
  modifier onlySignatory(){
    _onlySignatory();
    _;
  }

  function _onlySignatory () internal view {
    bool isSignatory = false;
    address[] memory signers = signatories;
    for (uint i = 0; i < signers.length; i++) {
      if (msg.sender == signers[i]) {
        isSignatory = true;
        break;
      }
    }
    require(isSignatory, "Not Allowed to sign");  
  }
  
  function transfer (address _to, uint256 _amount) external returns (bool) {
    require(balances[msg.sender] >= _amount, "Insuffiecient balance");
    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
    emit Transfer(msg.sender, _to, _amount);
    return true;
  }

  function allowance(address _owner, address _spender) external view returns (uint){
    return allowances[_owner][_spender];
  }

  function approve(address _spender, uint256 _amount) external returns (bool) {
    allowances[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }
  
  function transferFrom(address _from, address _to, uint _amount) external returns (bool) {
    require(balances[_from] >= _amount, "Insuffiecient balances");
    require(allowances[_from][msg.sender] >= _amount, "Not approved for that amount");

    balances[_from] -= _amount;
    allowances[_from][msg.sender] -= _amount;

    balances[_to] += _amount;

    emit Transfer(_from, _to, _amount);
    return true;
  }

  function mint(address _to,uint256 _amount) external onlyCreator {
    emit Transfer(address(0), _to, _amount);
    totalSupply += _amount;
    balances[_to] += _amount;
  }

}

