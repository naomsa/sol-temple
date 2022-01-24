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
  /*  /',__)| |   /'__` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {ERC721-Transfer}.
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  /// @notice See {ERC721-Approval}.
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
  /// @notice See {ERC721-ApprovalForAll}.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice See {ERC721Metadata-name}.
  string public name;
  /// @notice See {ERC721Metadata-symbol}.
  string public symbol;

  /// @notice See {ERC721Enumerable-totalSupply}.
  uint256 public totalSupply;

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
  function balanceOf(address account_) public view virtual returns (uint256) {
    require(account_ != address(0), "ERC721: balance query for the zero address");
    return _balanceOf[account_];
  }

  /// @notice See {ERC721-ownerOf}.
  function ownerOf(uint256 tokenId_) public view virtual returns (address) {
    require(_exists(tokenId_), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId_];
    return owner;
  }

  /// @notice See {ERC721Metadata-tokenURI}.
  function tokenURI(uint256) public view virtual returns (string memory);

  /// @notice See {ERC721-approve}.
  function approve(address to_, uint256 tokenId_) public virtual {
    address owner = ownerOf(tokenId_);
    require(to_ != owner, "ERC721: approval to current owner");

    require(
      msg.sender == owner || _isApprovedForAll[owner][msg.sender],
      "ERC721: caller is not owner nor approved for all"
    );

    _approve(to_, tokenId_);
  }

  /// @notice See {ERC721-getApproved}.
  function getApproved(uint256 tokenId_) public view virtual returns (address) {
    require(_exists(tokenId_), "ERC721: query for nonexistent token");
    return _tokenApprovals[tokenId_];
  }

  /// @notice See {ERC721-setApprovalForAll}.
  function setApprovalForAll(address operator_, bool approved_) public virtual {
    _setApprovalForAll(msg.sender, operator_, approved_);
  }

  /// @notice See {ERC721-isApprovedForAll}.
  function isApprovedForAll(address account_, address operator_) public view virtual returns (bool) {
    return _isApprovedForAll[account_][operator_];
  }

  /// @notice See {ERC721-transferFrom}.
  function transferFrom(
    address from_,
    address to_,
    uint256 tokenId_
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC721: transfer caller is not owner nor approved");
    _transfer(from_, to_, tokenId_);
  }

  /// @notice See {ERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from_,
    address to_,
    uint256 tokenId_
  ) public virtual {
    safeTransferFrom(from_, to_, tokenId_, "");
  }

  /// @notice See {ERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from_,
    address to_,
    uint256 tokenId_,
    bytes memory data_
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC721: transfer caller is not owner nor approved");
    _safeTransfer(from_, to_, tokenId_, data_);
  }

  /// @notice See {ERC721Enumerable.tokenOfOwnerByIndex}.
  function tokenOfOwnerByIndex(address account_, uint256 index_) public view returns (uint256 tokenId) {
    require(index_ < balanceOf(account_), "ERC721Enumerable: Index out of bounds");
    uint256 count;
    for (uint256 i; i < _owners.length; ++i) {
      if (account_ == _owners[i]) {
        if (count == index_) return i;
        else count++;
      }
    }
    revert("ERC721Enumerable: Index out of bounds");
  }

  /// @notice See {ERC721Enumerable.tokenByIndex}.
  function tokenByIndex(uint256 index_) public view virtual returns (uint256) {
    require(index_ < _owners.length, "ERC721Enumerable: Index out of bounds");
    return index_;
  }

  /// @notice Returns a list of all token Ids owned by `owner`.
  function walletOfOwner(address account_) public view returns (uint256[] memory) {
    uint256 balance = balanceOf(account_);
    uint256[] memory ids = new uint256[](balance);
    for (uint256 i = 0; i < balance; i++) {
      ids[i] = tokenOfOwnerByIndex(account_, i);
    }
    return ids;
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'__` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /**
   * @notice Safely transfers `tokenId_` token from `from_` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   */
  function _safeTransfer(
    address from_,
    address to_,
    uint256 tokenId_,
    bytes memory data_
  ) internal virtual {
    _transfer(from_, to_, tokenId_);
    _checkOnERC721Received(from_, to_, tokenId_, data_);
  }

  /// @notice Returns whether `tokenId_` exists.
  function _exists(uint256 tokenId_) internal view virtual returns (bool) {
    return tokenId_ < _owners.length && _owners[tokenId_] != address(0);
  }

  /// @notice Returns whether `spender_` is allowed to manage `tokenId`.
  function _isApprovedOrOwner(address spender_, uint256 tokenId_) internal view virtual returns (bool) {
    require(_exists(tokenId_), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId_];
    return (spender_ == owner || getApproved(tokenId_) == spender_ || _isApprovedForAll[owner][spender_]);
  }

  /// @notice Safely mints `tokenId_` and transfers it to `to`.
  function _safeMint(address to_, uint256 tokenId_) internal virtual {
    _safeMint(to_, tokenId_, "");
  }

  /**
   * @notice Same as {_safeMint}, but with an additional `data_` parameter which is
   * forwarded in {ERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(
    address to_,
    uint256 tokenId_,
    bytes memory data_
  ) internal virtual {
    _mint(to_, tokenId_);
    _checkOnERC721Received(address(0), to_, tokenId_, data_);
  }

  /// @notice Mints `tokenId_` and transfers it to `to_`.
  function _mint(address to_, uint256 tokenId_) internal virtual {
    require(!_exists(tokenId_), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to_, tokenId_);

    _owners.push(to_);
    totalSupply++;
    unchecked {
      _balanceOf[to_]++;
    }

    emit Transfer(address(0), to_, tokenId_);
    _afterTokenTransfer(address(0), to_, tokenId_);
  }

  /// @notice Destroys `tokenId`. The approval is cleared when the token is burned.
  function _burn(uint256 tokenId_) internal virtual {
    address owner = ownerOf(tokenId_);

    _beforeTokenTransfer(owner, address(0), tokenId_);

    // Clear approvals
    _approve(address(0), tokenId_);
    delete _owners[tokenId_];
    totalSupply--;
    _balanceOf[owner]--;

    emit Transfer(owner, address(0), tokenId_);
    _afterTokenTransfer(owner, address(0), tokenId_);
  }

  /// @notice Transfers `tokenId_` from `from_` to `to`.
  function _transfer(
    address from_,
    address to_,
    uint256 tokenId_
  ) internal virtual {
    require(_owners[tokenId_] == from_, "ERC721: transfer of token that is not own");

    _beforeTokenTransfer(from_, to_, tokenId_);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId_);

    _owners[tokenId_] = to_;
    unchecked {
      _balanceOf[from_]--;
      _balanceOf[to_]++;
    }

    emit Transfer(from_, to_, tokenId_);
    _afterTokenTransfer(from_, to_, tokenId_);
  }

  /// @notice Approve `to_` to operate on `tokenId_`
  function _approve(address to_, uint256 tokenId_) internal virtual {
    _tokenApprovals[tokenId_] = to_;
    emit Approval(_owners[tokenId_], to_, tokenId_);
  }

  /// @notice Approve `operator_` to operate on all of `account_` tokens.
  function _setApprovalForAll(
    address account_,
    address operator_,
    bool approved_
  ) internal virtual {
    require(account_ != operator_, "ERC721: approve to caller");
    _isApprovedForAll[account_][operator_] = approved_;
    emit ApprovalForAll(account_, operator_, approved_);
  }

  /// @notice ERC721Receiver callback checking and calling helper.
  function _checkOnERC721Received(
    address from_,
    address to_,
    uint256 tokenId_,
    bytes memory data_
  ) private {
    if (to_.code.length > 0) {
      try IERC721Receiver(to_).onERC721Received(msg.sender, from_, tokenId_, data_) returns (bytes4 returned) {
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
    address from_,
    address to_,
    uint256 tokenId_
  ) internal virtual {}

  /// @notice Hook that is called after any token transfer.
  function _afterTokenTransfer(
    address from_,
    address to_,
    uint256 tokenId_
  ) internal virtual {}

  /*    ___  _   _  _ _      __   _ __  */
  /*  /',__)( ) ( )( '_`\  /'__`\( '__) */
  /*  \__, \| (_) || (_) )(  ___/| |    */
  /*  (____/`\___/'| ,__/'`\____)(_)    */
  /*               | |                  */
  /*               (_)                  */

  /// @notice See {IERC165-supportsInterface}.
  function supportsInterface(bytes4 interfaceId_) public view virtual returns (bool) {
    return
      interfaceId_ == 0x80ac58cd || // ERC721
      interfaceId_ == 0x5b5e139f || // ERC721Metadata
      interfaceId_ == 0x780e9d63 || // ERC721Enumerable
      interfaceId_ == 0x01ffc9a7; // ERC165
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
