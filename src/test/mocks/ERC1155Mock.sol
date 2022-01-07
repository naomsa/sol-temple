pragma solidity ^0.8.0;

import "../../tokens/ERC1155/ERC1155Supply.sol";
import "../../tokens/ERC1155/ERC1155Permit.sol";

contract ERC1155Mock is ERC1155Supply, ERC1155Permit {
  constructor() ERC1155Permit("ERC1155Mock", "1") {}

  function mint(address to, uint256 id, uint256 amount) external {
    _mint(to, id, amount, "");
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts
  ) external {
    _mintBatch(to, ids, amounts, "");
  }

  function burn(address from, uint256 id, uint256 amount) external {
    _burn(from, id, amount);
  }

  function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) external {
    _burnBatch(from, ids, amounts);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC1155Permit) returns(bool) {
    return super.supportsInterface(interfaceId);
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override(ERC1155, ERC1155Supply) {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
  }
}
