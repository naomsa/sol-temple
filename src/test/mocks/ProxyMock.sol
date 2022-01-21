// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../utils/Upgradable.sol";

contract ProxyMock is Upgradable {
  uint256 public number;

  function store(uint256 num) public {
    number = num;
  }

  function retrieve() public view returns (uint256) {
    return number;
  }
}
