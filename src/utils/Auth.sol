// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Auth
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Just a simple authing system.
 */
abstract contract Auth {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice Emitted when the ownership is transfered.
  event OwnershipTransfered(address indexed from, address indexed to);

  /// @notice Contract's owner address.
  address public owner;

  /// @notice A simple modifier just to check whether the sender is the owner.
  modifier onlyOwner() {
    require(msg.sender == owner, "Auth: sender is not the owner");
    _;
  }

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  constructor() {
    _transferOwnership(msg.sender);
  }

  /// @notice Set the owner address to `owner_`.
  function transferOwnership(address owner_) public onlyOwner {
    require(owner != owner_, "Auth: transfering ownership to current owner");
    _transferOwnership(owner_);
  }

  /// @notice Set the owner address to `owner_`. Does not require anything
  function _transferOwnership(address owner_) internal {
    address oldOwner = owner;
    owner = owner_;

    emit OwnershipTransfered(oldOwner, owner_);
  }
}
