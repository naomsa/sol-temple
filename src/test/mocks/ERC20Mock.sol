// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC20.sol";

contract ERC20Mock is ERC20 {
  constructor(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) ERC20(name, symbol, decimals) {}

  function mint(address to, uint256 value) external {
    _mint(to, value);
  }

  function burn(address owner, uint256 value) external {
    _burn(owner, value);
  }
}
