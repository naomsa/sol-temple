// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC1155Permit is IERC165 {
  /// @notice The domain separator used in the encoding of the signature for permits, as defined by EIP-712.
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  /**
   * @notice Returns the nonce of an NFT - useful for creating permits.
   * @return the uint256 representation of the nonce.
   * @param owner the address of the owner.
   */
  function nonces(address owner) external view returns (uint256);

  /**
   * @notice Function to approve by way of owner signature.
   * @param owner the address of the owner.
   * @param operator the address to approve.
   * @param deadline a timestamp expiry for the permit.
   * @param sig a traditional or EIP-2098 signature.
   */
  function permit(
    address owner,
    address operator,
    uint256 deadline,
    bytes memory sig
  ) external;
}
