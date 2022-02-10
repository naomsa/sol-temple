// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

/**
 * @title ERC20 Upgradable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A complete ERC20 implementation including EIP-2612 permit feature.
 * Inspired by Solmate's ERC20, aiming at efficiency.
 */
abstract contract ERC20Upgradable is IERC20, IERC20Permit {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {ERC20-name}.
  string public name;
  /// @notice See {ERC20-symbol}.
  string public symbol;
  /// @notice See {ERC20-decimals}.
  uint8 public decimals;

  /// @notice Used to hash the Domain Separator.
  string public version;

  /// @notice See {ERC20-totalSupply}.
  uint256 public totalSupply;
  /// @notice See {ERC20-balanceOf}.
  mapping(address => uint256) public balanceOf;
  /// @notice See {ERC20-allowance}.
  mapping(address => mapping(address => uint256)) public allowance;

  /// @notice See {ERC2612-nonces}.
  mapping(address => uint256) public nonces;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  function __ERC20_init(
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    string memory version_
  ) internal {
    name = name_;
    symbol = symbol_;
    decimals = decimals_;
    version = version_;
  }

  /// @notice See {ERC20-transfer}.
  function transfer(address to_, uint256 value_) public returns (bool) {
    _transfer(msg.sender, to_, value_);
    return true;
  }

  /// @notice See {ERC20-transferFrom}.
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

  /// @notice See {ERC20-approve}.
  function approve(address spender_, uint256 value_) public returns (bool) {
    _approve(msg.sender, spender_, value_);
    return true;
  }

  /// @notice See {ERC2612-DOMAIN_SEPARATOR}.
  function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return _hashEIP712Domain(name, version, block.chainid, address(this));
  }

  /// @notice See {ERC2612-permit}.
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

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 digest = _hashEIP712Message(
      DOMAIN_SEPARATOR(),
      keccak256(
        abi.encode(
          0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9,
          owner_,
          spender_,
          value_,
          nonces[owner_]++,
          deadline_
        )
      )
    );

    address signer = ecrecover(digest, v_, r_, s_);
    require(signer != address(0) && signer == owner_, "ERC20: invalid signature");

    _approve(owner_, spender_, value_);
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /// @notice Internal transfer helper. Throws if `value_` exceeds `from_` balance.
  function _transfer(
    address from_,
    address to_,
    uint256 value_
  ) internal {
    require(balanceOf[from_] >= value_, "ERC20: insufficient balance");
    _beforeTokenTransfer(from_, to_, value_);

    unchecked {
      balanceOf[from_] -= value_;
      balanceOf[to_] += value_;
    }

    emit Transfer(from_, to_, value_);
    _afterTokenTransfer(from_, to_, value_);
  }

  /// @notice Internal approve helper.
  function _approve(
    address owner_,
    address spender_,
    uint256 value_
  ) internal {
    allowance[owner_][spender_] = value_;
    emit Approval(owner_, spender_, value_);
  }

  /// @notice Internal minting logic.
  function _mint(address to_, uint256 value_) internal {
    _beforeTokenTransfer(address(0), to_, value_);

    totalSupply += value_;
    unchecked {
      balanceOf[to_] += value_;
    }

    emit Transfer(address(0), to_, value_);
    _afterTokenTransfer(address(0), to_, value_);
  }

  /// @notice Internal burning logic.
  function _burn(address from_, uint256 value_) internal {
    _beforeTokenTransfer(from_, address(0), value_);
    require(balanceOf[from_] >= value_, "ERC20: burn value exceeds balance");

    unchecked {
      balanceOf[from_] -= value_;
      totalSupply -= value_;
    }

    emit Transfer(from_, address(0), value_);
    _afterTokenTransfer(from_, address(0), value_);
  }

  /**
   * @notice EIP721 domain hashing helper.
   * @dev Modified from https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol
   */
  function _hashEIP712Domain(
    string memory name_,
    string memory version_,
    uint256 chainId_,
    address verifyingContract_
  ) private pure returns (bytes32) {
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

  /**
   * @notice EIP721 typed message hashing helper.
   * @dev Modified from https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol
   */
  function _hashEIP712Message(bytes32 domainSeparator_, bytes32 hash_) private pure returns (bytes32) {
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

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 value
  ) internal virtual {}

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 value
  ) internal virtual {}
}
