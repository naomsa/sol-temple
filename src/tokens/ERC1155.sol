// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title ERC1155
 * @author naomsa <https://twitter.com/naomsa666>
 */
abstract contract ERC1155 {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

  /// @notice Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).      
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

  /// @notice MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absence of an event assumes disabled).        
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice MUST emit when the URI is updated for a token ID.
  event URI(string _value, uint256 indexed _id);

  /// @notice See {IERC1155-balanceOf}.
  mapping(address => mapping(uint256 => uint256)) public balanceOf;

  /// @notice See {IERC1155-isApprovedForAll}.
  mapping(address => mapping(address => bool)) public isApprovedForAll;

  /// @notice See {IERC1155Supple-totalSupply}
  mapping(uint256 => uint256) public totalSupply;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /**
   * @notice See {IERC1155MetadataURI-uri}.
   * This implementation returns the same URI for *all* token types. It relies
   * on the token type ID substitution mechanism e.g. https://token-cdn-domain/{id}.json
   */
  function uri(uint256) public view virtual returns (string memory) {}

  /**
   * @notice See {IERC1155-balanceOfBatch}.
   *
   * Requirements:
   * - `accounts` and `ids` must have the same length.
   */
  function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    returns (uint256[] memory)
  {
    require(
      accounts.length == ids.length,
      "ERC1155: accounts and ids length mismatch"
    );

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; i++) {
      batchBalances[i] = balanceOf[accounts[i]][ids[i]];
    }

    return batchBalances;
  }

  /**
   * @notice See {IERC1155-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved)
    public
    virtual
  {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  /**
   * @notice See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual {
    require(
      from == msg.sender || isApprovedForAll[from][msg.sender],
      "ERC1155: caller is not owner nor approved"
    );
    _safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @notice See {IERC1155-safeBatchTransferFrom}.
   */
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

  /**
   * @notice Transfers `amount` tokens of token type `id` from `from` to `to`.
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   * - `to` cannot be the zero address.
   * - `from` must have a balance of tokens of type `id` of at least `amount`.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(
      to != address(0),
      "ERC1155: transfer to the zero address"
    );

    _beforeTokenTransfer(
      msg.sender,
      from,
      to,
      _asSingletonArray(id),
      _asSingletonArray(amount),
      data
    );

    require(
      balanceOf[from][id] >= amount,
      "ERC1155: insufficient balance for transfer"
    );
    unchecked {
      balanceOf[from][id] -= amount;
    }
    balanceOf[to][id] += amount;

    emit TransferSingle(msg.sender, from, to, id, amount);

    _checkOnERC1155Received(msg.sender, from, to, id, amount, data);
  }

  /**
   * @notice Safe version of the batchTransferFrom function.
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(
      ids.length == amounts.length,
      "ERC1155: ids and amounts length mismatch"
    );
    require(to != address(0), "ERC1155: transfer to the zero address");

    _beforeTokenTransfer(msg.sender, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; ++i) {
      require(
        balanceOf[from][ids[i]] >= amounts[i],
        "ERC1155: insufficient balance for transfer"
      );
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
      }
      balanceOf[to][ids[i]] += amounts[i];
    }

    emit TransferBatch(msg.sender, from, to, ids, amounts);

    _checkOnERC1155BatchReceived(msg.sender, from, to, ids, amounts, data);
  }

  /**
   * @notice Creates `amount` tokens of token type `id`, and assigns them to `to`.
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   * - `to` cannot be the zero address.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");

    _beforeTokenTransfer(
      msg.sender,
      address(0),
      to,
      _asSingletonArray(id),
      _asSingletonArray(amount),
      data
    );

    balanceOf[to][id] += amount;
    emit TransferSingle(msg.sender, address(0), to, id, amount);

    _checkOnERC1155Received(msg.sender, address(0), to, id, amount, data);
  }

  /**
   * @notice Batch version of {mint}.
   *
   * Requirements:
   * - `ids` and `amounts` must have the same length.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(
      ids.length == amounts.length,
      "ERC1155: ids and amounts length mismatch"
    );

    _beforeTokenTransfer(msg.sender, address(0), to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; i++) {
      balanceOf[to][ids[i]] += amounts[i];
    }

    emit TransferBatch(msg.sender, address(0), to, ids, amounts);

    _checkOnERC1155BatchReceived(
      msg.sender,
      address(0),
      to,
      ids,
      amounts,
      data
    );
  }

  /**
   * @notice Destroys `amount` tokens of token type `id` from `from`
   *
   * Requirements:
   * - `from` must have at least `amount` tokens of token type `id`.
   */
  function _burn(
    address from,
    uint256 id,
    uint256 amount
  ) internal virtual {
    _beforeTokenTransfer(
      msg.sender,
      from,
      address(0),
      _asSingletonArray(id),
      _asSingletonArray(amount),
      ""
    );

    require(
      balanceOf[from][id] >= amount,
      "ERC1155: burn amount exceeds balance"
    );
    unchecked {
      balanceOf[from][id] -= amount;
    }

    emit TransferSingle(msg.sender, from, address(0), id, amount);
  }

  /**
   * @notice Batch version of {burn}.
   *
   * Requirements:
   * - `ids` and `amounts` must have the same length.
   */
  function _burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal virtual {
    require(
      ids.length == amounts.length,
      "ERC1155: ids and amounts length mismatch"
    );

    _beforeTokenTransfer(
      msg.sender,
      from,
      address(0),
      ids,
      amounts,
      ""
    );

    for (uint256 i = 0; i < ids.length; i++) {
      require(
        balanceOf[from][ids[i]] >= amounts[i],
        "ERC1155: burn amount exceeds balance"
      );
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
      }
    }

    emit TransferBatch(msg.sender, from, address(0), ids, amounts);
  }

  /**
   * @notice Approve `operator` to operate on all of `owner` tokens
   * Emits a {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(
      owner != operator,
      "ERC1155: setting approval status for self"
    );
    isApprovedForAll[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @notice Hook that is called before any token transfer. This includes minting
   * and burning, as well as batched variants.
   *
   * Calling conditions (for each `id` and `amount` pair):
   * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * of token type `id` will be  transferred to `to`.
   * - When `from` is zero, `amount` tokens of token type `id` will be minted
   * for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
   * will be burned.
   * - `from` and `to` are never both zero.
   * - `ids` and `amounts` have the same, non-zero length.
   */
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
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

  function _checkOnERC1155Received(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try
        IERC1155Receiver(to).onERC1155Received(
          operator,
          from,
          id,
          amount,
          data
        )
      returns (bytes4 returnValue) {
        require(
          returnValue == 0xf23a6e61,
          "ERC1155: transfer to non ERC1155Receiver implementer"
        );
      } catch {
        revert(
          "ERC1155: transfer to non ERC1155Receiver implementer"
        );
      }
    }
  }

  function _checkOnERC1155BatchReceived(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try
        IERC1155Receiver(to).onERC1155BatchReceived(
          operator,
          from,
          ids,
          amounts,
          data
        )
      returns (bytes4 returnValue) {
        require(
          returnValue == 0xbc197c81,
          "ERC1155: transfer to non ERC1155Receiver implementer"
        );
      } catch {
        revert(
          "ERC1155: transfer to non ERC1155Receiver implementer"
        );
      }
    }
  }

  function _asSingletonArray(uint256 element)
    private
    pure
    returns (uint256[] memory)
  {
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

  /**
   * @notice See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    returns (bool)
  {
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
