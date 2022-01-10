// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Pausable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A pausable contract without events.
 */
abstract contract Pausable {
  /// @notice Read-only pause state.
  bool private _paused;

  /// @notice A modifier to be used when the contract must be paused.
  modifier onlyWhenPaused() {
    require(_paused, "Pausable: contract not paused");
    _;
  }

  /// @notice A modifier to be used when the contract must be unpaused.
  modifier onlyWhenUnpaused() {
    require(!_paused, "Pausable: contract paused");
    _;
  }

  /// @notice Retrieve contracts pause state.
  function paused() public view returns (bool) {
    return _paused;
  }

  /// @notice Inverts pause state. Declared internal so it can be combined with the Auth contract.
  function _togglePaused() internal {
    _paused = !_paused;
  }
}
