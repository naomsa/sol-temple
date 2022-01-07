pragma solidity ^0.8.0;

import "../../tokens/ERC721/ERC721Enumerable.sol";

contract ERC721Mock is ERC721Enumerable {
  constructor() ERC721("ERC721 Mock", "MOCK") {}

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
