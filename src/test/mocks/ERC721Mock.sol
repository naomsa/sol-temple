// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC721.sol";

contract ERC721Mock is ERC721("ERC721 Mock", "MOCK") {
  function mint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }

  function burn(uint256 tokenId) external {
    _burn(tokenId);
  }

  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }
}
