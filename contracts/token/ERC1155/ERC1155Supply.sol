// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155.sol";

/**
 * @title ERC1155 Supply
 * @notice Extension of ERC1155 that adds supply tracking features. Extended from
 * the original OpenZeppelin contract.
 */
abstract contract ERC1155Supply is ERC1155 {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  mapping(uint256 => uint256) private _totalSupply;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /// @notice Upgradable pattern constructor.
  function __ERC1155Supply_init() internal {}

  /// @notice Total amount of tokens in with a given id.
  function totalSupply(uint256 id) public view virtual returns (uint256) {
    return _totalSupply[id];
  }

  /// @notice Indicates whether any token exist with a given id, or not./
  function exists(uint256 id) public view virtual returns (bool) {
    return totalSupply(id) > 0;
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /// @notice See {ERC1155-_beforeTokenTransfer}.
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

    if (from == address(0)) {
      for (uint256 i = 0; i < ids.length; ++i) {
        _totalSupply[ids[i]] += amounts[i];
      }
    }

    if (to == address(0)) {
      for (uint256 i = 0; i < ids.length; ++i) {
        _totalSupply[ids[i]] -= amounts[i];
      }
    }
  }
}
