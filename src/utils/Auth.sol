// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Auth
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Authing system where the `owner` can authorize function calls
 * to other addresses as well as control the contract by his own.
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

  /// @notice Emitted a new call with `data` is authorized to `to`.
  event AuthorizationGranted(address indexed to, bytes data);

  /// @notice Emitted a new call with `data` is forbidden to `to`.
  event AuthorizationForbidden(address indexed to, bytes data);

  /// @notice Contract's owner address.
  address public owner;

  /// @notice A mapping to retrieve if a call data was authed and is valid for the address.
  mapping(address => mapping(bytes => bool)) private _isAuthorized;

  /// @notice Requires the user to be the owner or authorized to call and delete is authorization.
  modifier onlyAuthorized() {
    require(isAuthorized(msg.sender, msg.data), "Auth: sender is not the owner or authorized to call");
    _;
    if (msg.sender != owner) _isAuthorized[msg.sender][msg.data] = false;
  }

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

  /// @notice Retrieves whether `user_` is authorized to call with `data_`.
  function isAuthorized(address user_, bytes memory data_) public view returns (bool) {
    return user_ == owner || _isAuthorized[user_][data_];
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

  /// @notice Authorize a call with `data_` to the address `to_`.
  function auth(address to_, bytes memory data_) public onlyOwner {
    require(to_ != owner, "Auth: authorizing call to the owner");
    require(!_isAuthorized[to_][data_], "Auth: authorized calls cannot be authed");
    _isAuthorized[to_][data_] = true;

    emit AuthorizationGranted(to_, data_);
  }

  /// @notice Authorize a call with `data_` to the address `to_`.
  function forbid(address to_, bytes memory data_) public onlyOwner {
    require(_isAuthorized[to_][data_], "Auth: unauthorized calls cannot be forbidden");
    delete _isAuthorized[to_][data_];

    emit AuthorizationForbidden(to_, data_);
  }
}
