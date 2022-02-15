// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Upgradeable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Make your contract compatible with sol-temple's proxy.
 */
contract Upgradeable is Ownable {
  /// @notice See {OwnableProxy-_implementation}.
  address private _implementation;
}
