// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC721.sol";

contract ERC721Mock is ERC721("ERC721 Mock", "MOCK") {
  bytes public beforeTransferData;
  bytes public afterTransferData;

  function tokenURI(uint256) public pure override returns (string memory) {
    return "";
  }

  function mint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }

  function burn(uint256 tokenId) external {
    _burn(tokenId);
  }

  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 id
  ) internal override {
    beforeTransferData = abi.encode(from, to, id);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 id
  ) internal override {
    afterTransferData = abi.encode(from, to, id);
  }
}
