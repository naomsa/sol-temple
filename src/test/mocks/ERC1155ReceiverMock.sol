// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

contract ERC1155ReceiverMock {
  bool public received;
  bool public batchReceived;

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes calldata
  ) external returns (bytes4) {
    received = true;
    return 0xf23a6e61;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] calldata,
    uint256[] calldata,
    bytes calldata
  ) external returns (bytes4) {
    batchReceived = true;
    return 0xbc197c81;
  }
}
