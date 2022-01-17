// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title ERC721 Upgradable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A complete ERC721 implementation including metadata and enumerable
 * functions. Completely gas optimized and extensible.
 */
abstract contract ERC721Upgradable {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {ERC721-Transfer}.
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

  /// @notice See {ERC721-Approval}.
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  /// @notice See {ERC721-ApprovalForAll}.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice See {Auth-owner}.
  address public owner;

  /// @notice See {Proxy-_implementation}.
  address private _implementation;

  /// @notice See {ERC721Metadata-name}.
  string public name;

  /// @notice See {ERC721Metadata-symbol}.
  string public symbol;

  /// @notice Array of all owners.
  address[] private _owners;

  /// @notice Mapping of all balances.
  mapping(address => uint256) private _balanceOf;

  /// @notice Mapping from token Id to it's approved address.
  mapping(uint256 => address) private _tokenApprovals;

  /// @notice Mapping of approvals between owner and operator.
  mapping(address => mapping(address => bool)) private _isApprovedForAll;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  function __ERC721_init(string memory name_, string memory symbol_) internal {
    name = name_;
    symbol = symbol_;
  }

  /// @notice See {ERC721-balanceOf}.
  function balanceOf(address owner) public view virtual returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _balanceOf[owner];
  }

  /// @notice See {ERC721-ownerOf}.
  function ownerOf(uint256 tokenId) public view virtual returns (address) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId];
    return owner;
  }

  /// @notice See {ERC721Metadata-tokenURI}.
  function tokenURI(uint256) public view virtual returns (string memory);

  /// @notice See {ERC721-approve}.
  function approve(address to, uint256 tokenId) public virtual {
    address owner = ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");

    require(
      msg.sender == owner || _isApprovedForAll[owner][msg.sender],
      "ERC721: caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  /// @notice See {ERC721-getApproved}.
  function getApproved(uint256 tokenId) public view virtual returns (address) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    return _tokenApprovals[tokenId];
  }

  /// @notice See {ERC721-setApprovalForAll}.
  function setApprovalForAll(address operator, bool approved) public virtual {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  /// @notice See {ERC721-isApprovedForAll}
  function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
    return _isApprovedForAll[owner][operator];
  }

  /// @notice See {ERC721-transferFrom}.
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
    _transfer(from, to, tokenId);
  }

  /// @notice See {ERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    safeTransferFrom(from, to, tokenId, "");
  }

  /// @notice See {ERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data_
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
    _safeTransfer(from, to, tokenId, data_);
  }

  /// @notice See {ERC721Enumerable.tokenOfOwnerByIndex}.
  function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId) {
    require(index < balanceOf(owner), "ERC721Enumerable: Index out of bounds");
    uint256 count;
    for (uint256 i; i < _owners.length; ++i) {
      if (owner == _owners[i]) {
        if (count == index) return i;
        else count++;
      }
    }
    revert("ERC721Enumerable: Index out of bounds");
  }

  /// @notice See {ERC721Enumerable.totalSupply}.
  function totalSupply() public view virtual returns (uint256) {
    return _owners.length;
  }

  /// @notice See {ERC721Enumerable.tokenByIndex}.
  function tokenByIndex(uint256 index) public view virtual returns (uint256) {
    require(index < _owners.length, "ERC721Enumerable: Index out of bounds");
    return index;
  }

  /// @notice Returns a list of all token Ids owned by `owner`.
  function walletOfOwner(address owner) public view returns (uint256[] memory) {
    uint256 balance = balanceOf(owner);
    uint256[] memory ids = new uint256[](balance);
    for (uint256 i = 0; i < balance; i++) {
      ids[i] = tokenOfOwnerByIndex(owner, i);
    }
    return ids;
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /**
   * @notice Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   */
  function _safeTransfer(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data_
  ) internal virtual {
    _transfer(from, to, tokenId);
    _checkOnERC721Received(from, to, tokenId, data_);
  }

  /// @notice Returns whether `tokenId` exists.
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return tokenId < _owners.length && _owners[tokenId] != address(0);
  }

  /// @notice Returns whether `spender` is allowed to manage `tokenId`.
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId];
    return (spender == owner || getApproved(tokenId) == spender || _isApprovedForAll[owner][spender]);
  }

  /// @notice Safely mints `tokenId` and transfers it to `to`.
  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  /**
   * @notice Same as {_safeMint}, but with an additional `data` parameter which is
   * forwarded in {ERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(
    address to,
    uint256 tokenId,
    bytes memory data_
  ) internal virtual {
    _mint(to, tokenId);
    _checkOnERC721Received(address(0), to, tokenId, data_);
  }

  /// @notice Mints `tokenId` and transfers it to `to`.
  function _mint(address to, uint256 tokenId) internal virtual {
    require(!_exists(tokenId), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _owners.push(to);
    unchecked {
      _balanceOf[to]++;
    }

    emit Transfer(address(0), to, tokenId);
  }

  /// @notice Destroys `tokenId`. The approval is cleared when the token is burned.
  function _burn(uint256 tokenId) internal virtual {
    address owner = ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);

    // Clear approvals
    _approve(address(0), tokenId);
    delete _owners[tokenId];
    _balanceOf[owner]--;

    emit Transfer(owner, address(0), tokenId);
  }

  /// @notice Transfers `tokenId` from `from` to `to`.
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {
    require(_owners[tokenId] == from, "ERC721: transfer of token that is not own");

    _beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);

    _owners[tokenId] = to;
    unchecked {
      _balanceOf[from]--;
      _balanceOf[to]++;
    }

    emit Transfer(from, to, tokenId);
  }

  /// @notice Approve `to` to operate on `tokenId`
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(_owners[tokenId], to, tokenId);
  }

  /// @notice Approve `operator` to operate on all of `owner` tokens
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC721: approve to caller");
    _isApprovedForAll[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /// @notice ERC721Receiver callback checking and calling helper.
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 returned) {
        require(returned == 0x150b7a02, "ERC721: safe transfer to non ERC721Receiver implementation");
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: safe transfer to non ERC721Receiver implementation");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  /// @notice Hook that is called before any token transfer.
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  /*    ___  _   _  _ _      __   _ __  */
  /*  /',__)( ) ( )( '_`\  /'__`\( '__) */
  /*  \__, \| (_) || (_) )(  ___/| |    */
  /*  (____/`\___/'| ,__/'`\____)(_)    */
  /*               | |                  */
  /*               (_)                  */

  /// @notice See {IERC165-supportsInterface}.
  function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    return
      interfaceId == 0x80ac58cd || // ERC721
      interfaceId == 0x5b5e139f || // ERC721Metadata
      interfaceId == 0x780e9d63 || // ERC721Enumerable
      interfaceId == 0x01ffc9a7; // ERC165
  }
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes memory data
  ) external returns (bytes4);
}
