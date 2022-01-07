// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC1155
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice An upgradable ERC1155 standard contract modified from the original
 * OpenZeppelin implementation.
 */
abstract contract ERC1155 is ERC165, IERC1155, IERC1155MetadataURI {
  using Address for address;

  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {IERC1155-balanceOf}.
  mapping(address => mapping(uint256 => uint256)) public balanceOf;

  /// @notice See {IERC1155-isApprovedForAll}.
  mapping(address => mapping(address => bool)) public isApprovedForAll;

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
  function uri(uint256) public view virtual override returns (string memory) {
    return "";
  }

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
    override
    returns (uint256[] memory)
  {
    require(
      accounts.length == ids.length,
      "ERC1155::balanceOfBatch: accounts and ids length mismatch"
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
    override
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
  ) public virtual override {
    require(
      from == msg.sender || isApprovedForAll[from][msg.sender],
      "ERC1155::safeTransferFrom: caller is not owner nor approved"
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
  ) public virtual override {
    require(
      from == msg.sender || isApprovedForAll[from][msg.sender],
      "ERC1155::safeBatchTransferFrom: transfer caller is not owner nor approved"
    );
    _safeBatchTransferFrom(from, to, ids, amounts, data);
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
      "ERC1155::_safeTransferFrom: transfer to the zero address"
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
      "ERC1155::_safeTransferFrom: insufficient balance for transfer"
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
      "ERC1155::_safeBatchTransferFrom: ids and amounts length mismatch"
    );
    require(to != address(0), "ERC1155::_safeBatchTransferFrom: transfer to the zero address");

    _beforeTokenTransfer(msg.sender, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; ++i) {
      require(
        balanceOf[from][ids[i]] >= amounts[i],
        "ERC1155::_safeBatchTransferFrom: insufficient balance for transfer"
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
    require(to != address(0), "ERC1155::_mint: mint to the zero address");

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
    require(to != address(0), "ERC1155::_mintBatch: mint to the zero address");
    require(
      ids.length == amounts.length,
      "ERC1155::_mintBatch: ids and amounts length mismatch"
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
      new bytes(0)
    );

    require(
      balanceOf[from][id] >= amount,
      "ERC1155::_burn: burn amount exceeds balance"
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
      "ERC1155::_burnBatch: ids and amounts length mismatch"
    );

    _beforeTokenTransfer(
      msg.sender,
      from,
      address(0),
      ids,
      amounts,
      new bytes(0)
    );

    for (uint256 i = 0; i < ids.length; i++) {
      require(
        balanceOf[from][ids[i]] >= amounts[i],
        "ERC1155::_burnBatch: burn amount exceeds balance"
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
      "ERC1155::_setApprovalForAll: setting approval status for self"
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
  ) internal virtual {}

  function _checkOnERC1155Received(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.isContract()) {
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
          returnValue == IERC1155Receiver.onERC1155Received.selector,
          "ERC1155::_checkOnERC1155Received: transfer to non ERC1155Receiver implementer"
        );
      } catch {
        revert(
          "ERC1155::_checkOnERC1155Received: transfer to non ERC1155Receiver implementer"
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
    if (to.isContract()) {
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
          returnValue == IERC1155Receiver.onERC1155BatchReceived.selector,
          "ERC1155::_checkOnERC1155BatchReceived: transfer to non ERC1155Receiver implementer"
        );
      } catch {
        revert(
          "ERC1155::_checkOnERC1155BatchReceived: transfer to non ERC1155Receiver implementer"
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
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC1155).interfaceId ||
      interfaceId == type(IERC1155MetadataURI).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
