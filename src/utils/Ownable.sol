// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Ownable
 * @notice Provides a secure owner admin implementation to the
 * proxy standard. This contract is a modification from OpenZeppelin's Ownable.
 *
 * Modifications:
 *  - Removed the renounceOwnership() function.
 *  - Removed the private owner variable to avoid storage collision.
 */
abstract contract Ownable is Context {
  /// @notice The contract owner address.
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /// @notice Initializes the contract setting the deployer as the initial owner.
  constructor() {
    _transferOwnership(_msgSender());
  }

  /// @notice Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(
      owner == _msgSender(),
      "Ownable::onlyOwner: caller is not the owner"
    );
    _;
  }

  /**
   * @notice Transfers ownership of the contract to `owner_`.
   * Can only be called by the current owner.
   */
  function transferOwnership(address owner_) public virtual onlyOwner {
    require(
      owner_ != address(0),
      "Ownable::transferOwnership: new owner is the zero address"
    );
    _transferOwnership(owner_);
  }

  /**
   * @notice Transfers ownership of the contract to `owner_`.
   * Implies no restrictions.
   */
  function _transferOwnership(address owner_) internal virtual {
    address oldOwner = owner;
    owner = owner_;
    emit OwnershipTransferred(oldOwner, owner_);
  }
}
