pragma solidity ^0.8;

import "../../token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {
  constructor() {
    __ERC721_init("ERC721 Mock", "ERC721");
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
}
