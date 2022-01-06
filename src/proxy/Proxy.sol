// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../utils/Ownable.sol";

/**
 * @title Proxy
 * @notice Ownable proxy pattern used to maintain an upgradable logic structure.
 */
contract Proxy is Ownable {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice The proxy's logic address.
  address public implementation;

  /// @notice Triggered when the proxy is upgraded to a new logic contract.
  event Upgraded(address indexed implementation);

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /// @notice Initialize proxy and set genesis logic address.
  constructor(address implementation_) {
    _upgradeTo(implementation_);
  }

  /**
   * @notice Upgrade proxy to a new logic contract.
   *
   * Requirements:
   * - `to` must not be the zero address.
   * - `to` must not be the current implementation.
   * @param to The new logic contract address.
   */
  function upgradeTo(address to) external onlyOwner {
    require(
      to != address(0),
      "Proxy::upgradeTo: can't upgrade to the zero address"
    );
    require(
      to != implementation,
      "Proxy::upgradeTo: can't upgrade to current implementation"
    );
    _upgradeTo(to);
  }

  /**
   * @dev Fallback function that delegates calls to the implementation address.
   * Will run if no other function in the contract matches the call data.
   */
  fallback() external payable virtual {
    _beforeFallback();
    _delegate(implementation);
  }

  /**
   * @dev Fallback function that delegates calls to the implementation address.
   * Will run if no other function in the contract matches the call data.
   */
  receive() external payable virtual {
    _beforeFallback();
    _delegate(implementation);
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /**
   * @notice Upgrade proxy to a new logic contract.
   * @param to The new logic contract address.
   */
  function _upgradeTo(address to) internal {
    implementation = to;
    emit Upgraded(to);
  }

  /**
   * @notice Passes function call to the implementation through the fallback function.
   * @param implementation_ The contract that will be called.
   */
  function _delegate(address implementation_) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(
        gas(),
        implementation_,
        0,
        calldatasize(),
        0,
        0
      )

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

  function _beforeFallback() internal virtual {}
}
