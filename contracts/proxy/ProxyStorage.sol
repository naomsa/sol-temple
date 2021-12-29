// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Proxy Storage
 * @notice `owner` and `implementation` variables are reserved proxy slots,
 * so the child must inherit their slots to avoid storage collision.
 */
abstract contract ProxyStorage {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice Proxy's reserved storage slot.
  address public owner;

  /// @notice Proxy's reserved storage slot.
  address public implementation;
}
