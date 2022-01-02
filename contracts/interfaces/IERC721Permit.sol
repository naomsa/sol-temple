// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @dev https://eips.ethereum.org/EIPS/eip-4494
interface IERC721Permit is IERC165 {
  /// @notice Returns the domain separator used in the encoding of the signature for permits, as defined by EIP-712
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  /**
   * @notice Returns the nonce of an NFT - useful for creating permits.
   * @param tokenId the index of the NFT to get the nonce of.
   */
  function nonces(uint256 tokenId) external view returns (uint256);

  /**
   * @notice Function to approve by way of owner signature.
   * @param spender the address to approve.
   * @param tokenId the index of the NFT to approve the spender on.
   * @param deadline a timestamp expiry for the permit.
   * @param sig a traditional or EIP-2098 signature.
   */
  function permit(
    address spender,
    uint256 tokenId,
    uint256 deadline,
    bytes memory sig
  ) external;
}
