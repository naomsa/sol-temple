// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC20Upgradable.sol";

contract ERC20UpgradableMock is ERC20Upgradable {
  function initialize(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) external {
    __ERC20_init(name, symbol, decimals);
  }

  function mint(address to, uint256 value) external {
    _mint(to, value);
  }

  function burn(address owner, uint256 value) external {
    _burn(owner, value);
  }
}
