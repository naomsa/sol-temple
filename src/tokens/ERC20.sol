// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title ERC20
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A complete ERC20 implementation including EIP-2612 permit feature.
 * Inspired by Solmate's ERC20, aiming at efficiency.
 */
abstract contract ERC20 {
  /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

  string public name;

  string public symbol;

  uint8 public immutable decimals;

  /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

  uint256 public totalSupply;

  mapping(address => uint256) public balanceOf;

  mapping(address => mapping(address => uint256)) public allowance;

  /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

  // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

  mapping(address => uint256) public nonces;

  /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    name = name_;
    symbol = symbol_;
    decimals = decimals_;
  }

  /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

  function transfer(address to_, uint256 value_) public returns (bool) {
    _transfer(msg.sender, to_, value_);
    return true;
  }

  function transferFrom(
    address from_,
    address to_,
    uint256 value_
  ) public returns (bool) {
    uint256 allowed = allowance[from_][msg.sender];
    require(allowed >= value_, "ERC20: allowance exceeds transfer value");
    if (allowed != type(uint256).max) allowance[from_][msg.sender] -= value_;

    _transfer(from_, to_, value_);
    return true;
  }

  function approve(address spender_, uint256 value_) public returns (bool) {
    _approve(msg.sender, spender_, value_);
    return true;
  }

  function _transfer(
    address from_,
    address to_,
    uint256 value_
  ) internal {
    require(balanceOf[from_] >= value_, "ERC20: insufficient balance");

    balanceOf[from_] -= value_;
    unchecked {
      balanceOf[to_] += value_;
    }

    emit Transfer(from_, to_, value_);
  }

  function _approve(
    address owner_,
    address spender_,
    uint256 value_
  ) internal {
    allowance[owner_][spender_] = value_;
    emit Approval(owner_, spender_, value_);
  }

  /*///////////////////////////////////////////////////////////////
                              EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

  function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return _hashEIP712Domain(name, "1", block.chainid, address(this));
  }

  function permit(
    address owner_,
    address spender_,
    uint256 value_,
    uint256 deadline_,
    uint8 v_,
    bytes32 r_,
    bytes32 s_
  ) public {
    require(deadline_ >= block.timestamp, "ERC20: expired permit deadline");

    bytes32 digest = _hashEIP712Message(
      DOMAIN_SEPARATOR(),
      keccak256(abi.encode(PERMIT_TYPEHASH, owner_, spender_, value_, nonces[owner_]++, deadline_))
    );
    address signer = ecrecover(digest, v_, r_, s_);
    require(signer != address(0) && signer == owner_, "ERC20: invalid signature");

    _approve(owner_, spender_, value_);
  }

  function _hashEIP712Domain(
    string memory name_,
    string memory version_,
    uint256 chainId_,
    address verifyingContract_
  ) internal pure returns (bytes32) {
    bytes32 result;
    assembly {
      // Calculate hashes of dynamic data
      let nameHash := keccak256(add(name_, 32), mload(name_))
      let versionHash := keccak256(add(version_, 32), mload(version_))

      // Load free memory pointer
      let memPtr := mload(64)

      // Store params in memory
      mstore(memPtr, 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f)
      mstore(add(memPtr, 32), nameHash)
      mstore(add(memPtr, 64), versionHash)
      mstore(add(memPtr, 96), chainId_)
      mstore(add(memPtr, 128), verifyingContract_)

      // Compute hash
      result := keccak256(memPtr, 160)
    }
    return result;
  }

  function _hashEIP712Message(bytes32 domainSeparator_, bytes32 hash_) internal pure returns (bytes32) {
    bytes32 result;
    assembly {
      // Load free memory pointer
      let memPtr := mload(64)

      mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000) // EIP191 header
      mstore(add(memPtr, 2), domainSeparator_) // EIP712 domain hash
      mstore(add(memPtr, 34), hash_) // Hash of struct

      // Compute hash
      result := keccak256(memPtr, 66)
    }
    return result;
  }

  /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

  function _mint(address to_, uint256 value_) internal {
    totalSupply += value_;
    unchecked {
      balanceOf[to_] += value_;
    }

    emit Transfer(address(0), to_, value_);
  }

  function _burn(address from_, uint256 value_) internal {
    balanceOf[from_] -= value_;
    unchecked {
      totalSupply -= value_;
    }

    emit Transfer(from_, address(0), value_);
  }
}