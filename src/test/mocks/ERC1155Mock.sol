// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC1155.sol";

contract ERC1155Mock is ERC1155 {
  function mint(
    address to,
    uint256 id,
    uint256 amount
  ) external {
    _mint(to, id, amount, "");
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts
  ) external {
    _mintBatch(to, ids, amounts, "");
  }

  function burn(
    address from,
    uint256 id,
    uint256 amount
  ) external {
    _burn(from, id, amount);
  }

  function burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) external {
    _burnBatch(from, ids, amounts);
  }
}
