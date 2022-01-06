pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721ReceiverMock is IERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
}
