// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../utils/Pausable.sol";

contract PausableMock is Pausable {
  uint256 public number;

  function store(uint256 num) public onlyWhenPaused {
    number = num;
  }

  function retrieve() public view onlyWhenUnpaused returns (uint256) {
    return number;
  }

  function togglePaused() public {
    _togglePaused();
  }
}
