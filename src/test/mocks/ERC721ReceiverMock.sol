// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ERC721ReceiverMock {
  bool public received;

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external returns (bytes4) {
    received = true;
    return 0x150b7a02;
  }
}
