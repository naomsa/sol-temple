// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Upgradable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Make your contract compatible with Sol-Temple's proxy.
 */
contract Upgradable {
  /// @notice See {Auth-OwnershipTransfered}.
  event OwnershipTransfered(address indexed from, address indexed to);

  /// @notice See {Auth-owner}.
  address public owner;

  /// @notice See {Proxy-_implementation}.
  address private _implementation;

  /// @notice See {Auth-onlyOwner}.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @notice See {Auth-transferOwnership}.
  function transferOwnership(address owner_) public onlyOwner {
    require(owner != owner_, "Auth: transfering ownership to current owner");
    _transferOwnership(owner_);
  }

  /// @notice See {Auth-_transferOwnership}.
  function _transferOwnership(address owner_) internal {
    address oldOwner = owner;
    owner = owner_;

    emit OwnershipTransfered(oldOwner, owner_);
  }
}
