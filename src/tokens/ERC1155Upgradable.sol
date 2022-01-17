// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title ERC1155 Upgradable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A complete ERC1155 implementation including supply tracking and
 * enumerable functions. Completely gas optimized and extensible.
 */
abstract contract ERC1155Upgradable {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {ERC1155-TransferSingle}.
  event TransferSingle(
    address indexed _operator,
    address indexed _from,
    address indexed _to,
    uint256 _id,
    uint256 _value
  );
  /// @notice See {ERC1155-TransferBatch}.
  event TransferBatch(
    address indexed _operator,
    address indexed _from,
    address indexed _to,
    uint256[] _ids,
    uint256[] _values
  );
  /// @notice See {ERC1155-ApprovalForAll}.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  /// @notice See {ERC1155-URI}.
  event URI(string _value, uint256 indexed _id);

  /// @notice See {Auth-owner}.
  address public owner;
  /// @notice See {Proxy-_implementation}.
  address private _implementation;

  /// @notice See {ERC1155-balanceOf}.
  mapping(address => mapping(uint256 => uint256)) public balanceOf;
  /// @notice See {ERC1155-isApprovedForAll}.
  mapping(address => mapping(address => bool)) public isApprovedForAll;

  /// @notice Tracker for tokens in circulation by Id.
  mapping(uint256 => uint256) public totalSupply;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /// @notice See {ERC1155Metadata_URI-uri}.
  function uri(uint256) public view virtual returns (string memory);

  /// @notice See {ERC1155-balanceOfBatch}.
  function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    returns (uint256[] memory)
  {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; i++) {
      batchBalances[i] = balanceOf[accounts[i]][ids[i]];
    }

    return batchBalances;
  }

  /// @notice See {ERC1155-setApprovalForAll}.
  function setApprovalForAll(address operator, bool approved) public virtual {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  /// @notice See {ERC1155-safeTransferFrom}.
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual {
    require(from == msg.sender || isApprovedForAll[from][msg.sender], "ERC1155: caller is not owner nor approved");
    _safeTransferFrom(from, to, id, amount, data);
  }

  /// @notice See {ERC1155-safeBatchTransferFrom}.
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual {
    require(
      from == msg.sender || isApprovedForAll[from][msg.sender],
      "ERC1155: transfer caller is not owner nor approved"
    );
    _safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  /// @notice Indicates whether any token exist with a given id, or not./
  function exists(uint256 id) public view virtual returns (bool) {
    return totalSupply[id] > 0;
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /// @notice Transfers `amount` tokens of token type `id` from `from` to `to`.
  function _safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: transfer to the zero address");

    _trackSupplyBeforeTransfer(from, to, _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

    require(balanceOf[from][id] >= amount, "ERC1155: insufficient balance for transfer");
    unchecked {
      balanceOf[from][id] -= amount;
    }
    balanceOf[to][id] += amount;

    emit TransferSingle(msg.sender, from, to, id, amount);

    _checkOnERC1155Received(msg.sender, from, to, id, amount, data);
  }

  /// @notice Safe version of the batchTransferFrom function.
  function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    _trackSupplyBeforeTransfer(from, to, ids, amounts);

    _beforeTokenTransfer(msg.sender, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; ++i) {
      require(balanceOf[from][ids[i]] >= amounts[i], "ERC1155: insufficient balance for transfer");
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
      }
      balanceOf[to][ids[i]] += amounts[i];
    }

    emit TransferBatch(msg.sender, from, to, ids, amounts);

    _checkOnERC1155BatchReceived(msg.sender, from, to, ids, amounts, data);
  }

  /// @notice Creates `amount` tokens of token type `id`, and assigns them to `to`.
  function _mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");

    _trackSupplyBeforeTransfer(address(0), to, _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

    balanceOf[to][id] += amount;
    emit TransferSingle(msg.sender, address(0), to, id, amount);

    _checkOnERC1155Received(msg.sender, address(0), to, id, amount, data);
  }

  /// @notice Batch version of {mint}.
  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    _trackSupplyBeforeTransfer(address(0), to, ids, amounts);

    _beforeTokenTransfer(msg.sender, address(0), to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; i++) {
      balanceOf[to][ids[i]] += amounts[i];
    }

    emit TransferBatch(msg.sender, address(0), to, ids, amounts);

    _checkOnERC1155BatchReceived(msg.sender, address(0), to, ids, amounts, data);
  }

  /// @notice Destroys `amount` tokens of token type `id` from `from`
  function _burn(
    address from,
    uint256 id,
    uint256 amount
  ) internal virtual {
    _trackSupplyBeforeTransfer(from, address(0), _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

    require(balanceOf[from][id] >= amount, "ERC1155: burn amount exceeds balance");
    unchecked {
      balanceOf[from][id] -= amount;
    }

    emit TransferSingle(msg.sender, from, address(0), id, amount);
  }

  /// @notice Batch version of {burn}.
  function _burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal virtual {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    _trackSupplyBeforeTransfer(from, address(0), ids, amounts);

    _beforeTokenTransfer(msg.sender, from, address(0), ids, amounts, "");

    for (uint256 i = 0; i < ids.length; i++) {
      require(balanceOf[from][ids[i]] >= amounts[i], "ERC1155: burn amount exceeds balance");
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
      }
    }

    emit TransferBatch(msg.sender, from, address(0), ids, amounts);
  }

  /// @notice Approve `operator` to operate on all of `owner` tokens
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC1155: setting approval status for self");
    isApprovedForAll[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /// @notice Hook that is called before any token transfer.
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  /// @notice Internal helper for tracking token supply before transfers.
  function _trackSupplyBeforeTransfer(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts
  ) private {
    if (from == address(0)) {
      for (uint256 i = 0; i < ids.length; i++) {
        totalSupply[ids[i]] += amounts[i];
      }
    }

    if (to == address(0)) {
      for (uint256 i = 0; i < ids.length; i++) {
        totalSupply[ids[i]] -= amounts[i];
      }
    }
  }

  /// @notice ERC1155Receiver callback checking and calling helper for single transfers.
  function _checkOnERC1155Received(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 returnValue) {
        require(returnValue == 0xf23a6e61, "ERC1155: transfer to non ERC1155Receiver implementer");
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

  /// @notice ERC1155Receiver callback checking and calling helper for batch transfers.
  function _checkOnERC1155BatchReceived(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 returnValue) {
        require(returnValue == 0xbc197c81, "ERC1155: transfer to non ERC1155Receiver implementer");
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

  /// @notice Helper for single item arrays.
  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = element;

    return array;
  }

  /*    ___  _   _  _ _      __   _ __  */
  /*  /',__)( ) ( )( '_`\  /'__`\( '__) */
  /*  \__, \| (_) || (_) )(  ___/| |    */
  /*  (____/`\___/'| ,__/'`\____)(_)    */
  /*               | |                  */
  /*               (_)                  */

  /// @notice See {IERC165-supportsInterface}.
  function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    return
      interfaceId == 0xd9b67a26 || // ERC1155
      interfaceId == 0x0e89341c || // ERC1155MetadataURI
      interfaceId == 0x01ffc9a7; // ERC165
  }
}

interface IERC1155Receiver {
  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external returns (bytes4);

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external returns (bytes4);
}
