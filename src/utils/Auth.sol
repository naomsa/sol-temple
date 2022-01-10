// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Auth
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A simple but powerful authing system where the `owner` can authorize
 * function calls to other addresses as well as control the contract by his own.
 */
abstract contract Auth {
  /// @notice Contract's owner address.
  address private _owner;

  /// @notice A mapping to retrieve if a call data was authed and is valid for the address.
  mapping(address => mapping(bytes => bool)) private _isAuthorized;

  /**
   * @notice A modifier that requires the user to be the owner or authorization to call.
   * After the call, the user loses it's authorization if he's not the owner.
   */
  modifier onlyAuthorized() {
    require(isAuthorized(msg.sender, msg.data), "Auth: sender is not the owner or authorized to call");
    _;
    if (msg.sender != _owner) _isAuthorized[msg.sender][msg.data] = false;
  }

  /// @notice A simple modifier just to check whether the sender is the owner.
  modifier onlyOwner() {
    require(msg.sender == _owner, "Auth: sender is not the owner");
    _;
  }

  constructor() {
    _owner = msg.sender;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function isAuthorized(address user_, bytes memory data_) public view returns (bool) {
    return user_ == _owner || _isAuthorized[user_][data_];
  }

  /// @notice Set the owner address to `owner_`.
  function transferOwnership(address owner_) public onlyOwner {
    require(_owner != owner_, "Auth: transfering ownership to current owner");
    _owner = owner_;
  }

  /// @notice Authorize a call with `data_` to the address `to_`.
  function auth(address to_, bytes memory data_) public onlyOwner {
    require(to_ != _owner, "Auth: authorizing call to the owner");
    require(!_isAuthorized[to_][data_], "Auth: authorized calls cannot be authed");
    _isAuthorized[to_][data_] = true;
  }

  /// @notice Authorize a call with `data_` to the address `to_`.
  function forbid(address to_, bytes memory data_) public onlyOwner {
    require(_isAuthorized[to_][data_], "Auth: unauthorized calls cannot be forbidden");
    delete _isAuthorized[to_][data_];
  }
}
