// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "../../utils/Upgradable.sol";
import "../../tokens/ERC721Upgradable.sol";

contract ERC721UpgradableMock is Upgradable, ERC721Upgradable {
  function inititialize(string memory name, string memory symbol) external onlyOwner {
    __ERC721_init(name, symbol);
  }

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
}
