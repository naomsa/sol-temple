// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./ERC721.sol";

/**
 * @title ERC721Enumerable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice An upgradable and gas-efficient ERC1721 (enumerable) extension contract modified
 * from the original OpenZeppelin implementation.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /// @notice See {IERC721Enumerable.tokenOfOwnerByIndex}.
  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    override
    returns (uint256 tokenId)
  {
    require(
      index < ERC721.balanceOf(owner),
      "ERC721Enumerable::tokenOfOwnerByIndex: Index out of bounds"
    );
    uint256 count;
    for (uint256 i; i < _owners.length; ++i) {
      if (owner == _owners[i]) {
        if (count == index) return i;
        else count++;
      }
    }
    revert("ERC721Enumerable::tokenOfOwnerByIndex: Index out of bounds");
  }

  /// @notice See {IERC721Enumerable.totalSupply}.
  function totalSupply() public view virtual override returns (uint256) {
    return _owners.length;
  }

  /// @notice See {IERC721Enumerable.tokenByIndex}.
  function tokenByIndex(uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      index < ERC721Enumerable.totalSupply(),
      "ERC721Enumerable::tokenByIndex: Index out of bounds"
    );
    return index;
  }

  /// @notice Returns a list of all token Ids owned by `owner`.
  function tokensOfOwner(address owner) public view returns (uint256[] memory) {
    uint256 balance = balanceOf(owner);
    uint256[] memory ids = new uint256[](balance);
    for (uint256 i = 0; i < balance; i++) {
      ids[i] = tokenOfOwnerByIndex(owner, i);
    }
    return ids;
  }

  /*    ___  _   _  _ _      __   _ __  */
  /*  /',__)( ) ( )( '_`\  /'__`\( '__) */
  /*  \__, \| (_) || (_) )(  ___/| |    */
  /*  (____/`\___/'| ,__/'`\____)(_)    */
  /*               | |                  */
  /*               (_)                  */

  /// @notice See {ERC165.supportsInterface}.
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      interfaceId == type(IERC721Enumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
