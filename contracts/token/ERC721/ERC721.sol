// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC721
 * @notice An upgradable and gas-efficient ERC1721 standard contract modified
 * from the original OpenZeppelin implementation.
 */
abstract contract ERC721 is ERC165, IERC721, IERC721Metadata {
  using Address for address;
  using Strings for uint256;

  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {IERC721Metadata-name}.
  string public name;

  /// @notice See {IERC721Metadata-symbol}.
  string public symbol;

  /// @notice Array of all owners.
  address[] internal _owners;

  /// @notice Mapping from token ID to approved address.
  mapping(uint256 => address) private _tokenApprovals;

  /// @notice Mapping from owner to operator approvals.
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  modifier ifExists(uint256 tokenId) {
    require(_exists(tokenId), "ERC721::ifExists: query for nonexistent token");
    _;
  }

  /// @notice Upgradable pattern constructor.
  function __ERC721_init(string memory name_, string memory symbol_) internal {
    name = name_;
    symbol = symbol_;
  }

  /// @notice See {IERC721-balanceOf}.
  function balanceOf(address owner)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      owner != address(0),
      "ERC721::balanceOf: balance query for the zero address"
    );
    uint256 count = 0;
    uint256 length = _owners.length;
    for (uint256 i = 0; i < length; ++i) {
      if (owner == _owners[i]) {
        ++count;
      }
    }
    delete length;
    return count;
  }

  /// @notice See {IERC721-ownerOf}.
  function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override
    ifExists(tokenId)
    returns (address)
  {
    address owner = _owners[tokenId];
    return owner;
  }

  /// @notice See {IERC721Metadata-tokenURI}.
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    ifExists(tokenId)
    returns (string memory)
  {
    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
  }

  /// @notice See {IERC721-approve}.
  function approve(address to, uint256 tokenId) public virtual override {
    address owner = ERC721.ownerOf(tokenId);
    require(to != owner, "ERC721::approve: approval to current owner");

    require(
      msg.sender == owner || isApprovedForAll(owner, msg.sender),
      "ERC721::approve: caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  /// @notice See {IERC721-getApproved}.
  function getApproved(uint256 tokenId)
    public
    view
    virtual
    override
    ifExists(tokenId)
    returns (address)
  {
    return _tokenApprovals[tokenId];
  }

  /// @notice See {IERC721-setApprovalForAll}.
  function setApprovalForAll(address operator, bool approved)
    public
    virtual
    override
  {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  /// @notice See {IERC721-isApprovedForAll}.
  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  /// @notice See {IERC721-transferFrom}.
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    require(
      _isApprovedOrOwner(msg.sender, tokenId),
      "ERC721::transferFrom: transfer caller is not owner nor approved"
    );

    _transfer(from, to, tokenId);
  }

  /// @notice See {IERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    safeTransferFrom(from, to, tokenId, "");
  }

  /// @notice See {IERC721-safeTransferFrom}.
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data_
  ) public virtual override {
    require(
      _isApprovedOrOwner(msg.sender, tokenId),
      "ERC721::safeTransferFrom: transfer caller is not owner nor approved"
    );
    _safeTransfer(from, to, tokenId, data_);
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /**
   * @notice Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overriden in child contracts.
   */
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }

  /**
   * @notice Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * `data_` is additional data, it has no specified format and it is sent in call to `to`.
   *
   * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
   * implement alternative mechanisms to perform token transfer, such as signature-based.
   *
   * Requirements:
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
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

  /**
   * @notice Returns whether `tokenId` exists.
   *
   * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
   *
   * Tokens start existing when they are minted (`_mint`),
   * and stop existing when they are burned (`_burn`).
   */
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return tokenId < _owners.length && _owners[tokenId] != address(0);
  }

  /**
   * @notice Returns whether `spender` is allowed to manage `tokenId`.
   *
   * Requirements:
   * - `tokenId` must exist.
   */
  function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    virtual
    ifExists(tokenId)
    returns (bool)
  {
    address owner = ERC721.ownerOf(tokenId);
    return (spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender));
  }

  /**
   * @notice Safely mints `tokenId` and transfers it to `to`.
   *
   * Requirements:
   * - `tokenId` must not exist.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  /**
   * @notice Same as {_safeMint}, but with an additional `data` parameter which is
   * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(
    address to,
    uint256 tokenId,
    bytes memory data_
  ) internal virtual {
    _mint(to, tokenId);
    _checkOnERC721Received(address(0), to, tokenId, data_);
  }

  /**
   * @notice Mints `tokenId` and transfers it to `to`.
   *
   * Requirements:
   * - `tokenId` must not exist.
   * - `to` cannot be the zero address.
   *
   * Emits a {Transfer} event.
   */
  function _mint(address to, uint256 tokenId) internal virtual {
    require(to != address(0), "ERC721::_mint: mint to the zero address");
    require(!_exists(tokenId), "ERC721::_mint: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);
    _owners.push(to);

    emit Transfer(address(0), to, tokenId);
  }

  /**
   * @notice Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual {
    address owner = ERC721.ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);

    // Clear approvals
    _approve(address(0), tokenId);
    delete _owners[tokenId];

    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * @notice Transfers `tokenId` from `from` to `to`.
   *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
   *
   * Requirements:
   * - `to` cannot be the zero address.
   * - `tokenId` token must be owned by `from`.
   *
   * Emits a {Transfer} event.
   */
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {
    require(
      ERC721.ownerOf(tokenId) == from,
      "ERC721::_transfer: transfer of token that is not own"
    );
    require(
      to != address(0),
      "ERC721::_transfer: transfer to the zero address"
    );

    _beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  /**
   * @notice Approve `to` to operate on `tokenId`
   *
   * Emits a {Approval} event.
   */
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
  }

  /**
   * @notice Approve `operator` to operate on all of `owner` tokens
   *
   * Emits a {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC721::_setApprovalForAll: approve to caller");
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @notice Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
   * The call is not executed if the target address is not a contract.
   *
   * @param from address representing the previous owner of the given token ID
   * @param to target address that will receive the tokens
   * @param tokenId uint256 ID of the token to be transferred
   * @param data_ bytes optional data to send along with the call
   */
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data_
  ) private {
    require(
      !to.isContract() ||
        IERC721Receiver(to).onERC721Received(
          msg.sender,
          from,
          tokenId,
          data_
        ) ==
        IERC721Receiver.onERC721Received.selector,
      "ERC721::_checkOnERC721Received: transfer to non ERC721Receiver implementer"
    );
  }

  /**
   * @notice Hook that is called before any token transfer. This includes minting
   * and burning.
   *
   * Calling conditions:
   * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
   * transferred to `to`.
   * - When `from` is zero, `tokenId` will be minted for `to`.
   * - When `to` is zero, ``from``'s `tokenId` will be burned.
   * - `from` and `to` are never both zero.
   */
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
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
