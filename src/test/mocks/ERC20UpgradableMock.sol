// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../utils/Upgradable.sol";
import "../../tokens/ERC20Upgradable.sol";

contract ERC20UpgradableMock is Upgradable, ERC20Upgradable {
  bytes public beforeTransferData;
  bytes public afterTransferData;

  function initialize(
    string memory name,
    string memory symbol,
    uint8 decimals,
    string memory version
  ) external onlyOwner {
    __ERC20_init(name, symbol, decimals, version);
  }

  function mint(address to, uint256 value) external {
    _mint(to, value);
  }

  function burn(address owner, uint256 value) external {
    _burn(owner, value);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 value
  ) internal override {
    beforeTransferData = abi.encode(from, to, value);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 value
  ) internal override {
    afterTransferData = abi.encode(from, to, value);
  }
}
