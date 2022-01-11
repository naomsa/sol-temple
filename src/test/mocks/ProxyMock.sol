// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../utils/Auth.sol";

contract ProxyMock is Auth {
  address internal _implementation;

  uint256 public number;

  function store(uint256 num) public {
    number = num;
  }

  function retrieve() public view returns (uint256) {
    return number;
  }
}
