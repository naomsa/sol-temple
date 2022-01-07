pragma solidity ^0.8.0;

import "../../tokens/ERC721/ERC721Enumerable.sol";
import "../../tokens/ERC721/ERC721Permit.sol";

contract ERC721Mock is ERC721Enumerable, ERC721Permit {
  constructor() ERC721("ERC721 Mock", "MOCK") ERC721Permit("1") {}

  function mint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }

  function burn(uint256 tokenId) external {
    _burn(tokenId);
  }

  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC721Permit) returns(bool) {
    return super.supportsInterface(interfaceId);
  }
}
