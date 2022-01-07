// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../../interfaces/IERC1155Permit.sol";
import "../../interfaces/IERC1271.sol";
import "./ERC1155.sol";

/**
 * @title ERC1155 Permit
 * @notice Extension of ERC1155 that implements EIP-4494 for cheaper transactions
 * making approve transactions off-chain and gasless.
 */
abstract contract ERC1155Permit is IERC1155Permit, ERC1155 {
  using ECDSA for bytes32;
  using Address for address;

  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  /// @notice See {IERC1155Permit-nonces}.
  mapping(address => uint256) public nonces;

  /// @notice keccak256("Permit(address owner,address operator,uint256 nonce,uint256 deadline)");
  bytes32 public constant PERMIT_TYPEHASH =
    0x16efd59368a9abbac9954a7e691dd7d75c14d374c4fd2e0ea5eb8eebe3cfc3fd;

  bytes32 public _DOMAIN_SEPARATOR;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  /// @notice Upgradable pattern constructor.
  constructor (string memory name_, string memory version_) {
    _DOMAIN_SEPARATOR = _hashDomain(
      name_,
      version_,
      block.chainid,
      address(this)
    );
  }

  /// @notice See {IERC1155Permit-DOMAIN_SEPARATOR}.
  function DOMAIN_SEPARATOR() external view returns (bytes32) {
    return _DOMAIN_SEPARATOR;
  }

  /// @notice See {IERC1155Permit-permit}.
  function permit(
    address owner,
    address operator,
    uint256 deadline,
    bytes memory sig
  ) external {
    require(
      deadline >= block.timestamp,
      "ERC1155Permit::permit: expired signature"
    );
    require(
      owner != operator,
      "ERC1155Permit::permit: setting approval status for self"
    );

    bytes32 message = _hashMessage(
      _DOMAIN_SEPARATOR,
      keccak256(
        abi.encode(PERMIT_TYPEHASH, owner, operator, nonces[owner]++, deadline)
      )
    );

    if (owner.isContract()) {
      require(
        IERC1271(owner).isValidSignature(message, sig) == 0x1626ba7e,
        "ERC1155Permit::permit: invalid signature"
      );
    } else {
      address signer = message.recover(sig);
      require(signer != address(0), "ERC1155Permit::permit: invalid signature");
      require(signer == owner, "ERC1155Permit::permit: signer not authorized");
    }

    _setApprovalForAll(owner, operator, true);
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /// @dev Assembly logic as seen on the 0x contracts.
  function _hashDomain(
    string memory name_,
    string memory version_,
    uint256 chainId,
    address verifyingContract
  ) internal pure returns (bytes32) {
    bytes32 result;

    assembly {
      // Calculate hashes of dynamic data
      let nameHash := keccak256(add(name_, 32), mload(name_))
      let versionHash := keccak256(add(version_, 32), mload(version_))

      // Load free memory pointer
      let memPtr := mload(64)

      // Store params in memory
      // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
      mstore(memPtr, 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f)
      mstore(add(memPtr, 32), nameHash)
      mstore(add(memPtr, 64), versionHash)
      mstore(add(memPtr, 96), chainId)
      mstore(add(memPtr, 128), verifyingContract)

      // Compute hash
      result := keccak256(memPtr, 160)
    }

    return result;
  }

  /// @dev Another assembly implementation as seen on the 0x contracts.
  function _hashMessage(bytes32 separator, bytes32 digest)
    internal
    pure
    returns (bytes32)
  {
    bytes32 message;
    assembly {
      // Load free memory pointer
      let memPtr := mload(64)

      mstore(
        memPtr,
        0x1901000000000000000000000000000000000000000000000000000000000000
      ) // EIP191 header
      mstore(add(memPtr, 2), separator) // EIP712 domain hash
      mstore(add(memPtr, 34), digest) // Digest

      // Compute hash
      message := keccak256(memPtr, 66)
    }
    return message;
  }

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
    override(IERC165, ERC1155)
    returns (bool)
  {
    return
      interfaceId == type(IERC1155Permit).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
