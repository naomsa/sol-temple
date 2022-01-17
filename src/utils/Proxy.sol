// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

import "./Auth.sol";

/**
 * @title Proxy
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice An upgradable proxy util for function delegation following EIP-897.
 * @dev The implementaion MUST reserve the first two storage slots to the
 * `_owner` address and the `_implementation` address.
 */
contract Proxy is Auth {
  /// @notice Emitted when a new implementation is set.
  event Upgraded(address indexed from, address indexed to);

  /// @notice Current implementation address.
  address private _implementation;

  constructor(address implementation_) {
    setImplementation(implementation_);
  }

  /// @notice Set the new implementation.
  function setImplementation(address implementation_) public onlyOwner {
    require(implementation_ != address(0), "Proxy: upgrading to the zero address");
    require(implementation_ != _implementation, "Proxy: upgrading to the current implementation");

    address oldImplementation = _implementation;
    _implementation = implementation_;

    emit Upgraded(oldImplementation, implementation_);
  }

  /// @notice See {EIP897-implementation}.
  function implementation() public view returns (address) {
    return _implementation;
  }

  /// @notice See {EIP897-proxyType}.
  function proxyType() public pure returns (uint256) {
    return 2;
  }

  /**
   * @notice Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
   * function in the contract matches the call data.
   */
  fallback() external payable {
    _beforeFallback();
    _delegate(_implementation);
  }

  /**
   * @notice Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
   * function in the contract matches the call data.
   */
  receive() external payable {
    _beforeFallback();
    _delegate(_implementation);
  }

  /// @notice Delegate the current call to `implementation_`.
  function _delegate(address implementation_) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  /// @notice Hook that is called before any delegation.
  function _beforeFallback() internal {}
}
