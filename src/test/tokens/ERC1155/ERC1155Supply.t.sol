// SPDX-License-Identifier: UNLICESED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../../vm.sol";
import "../../mocks/ERC1155Mock.sol";
import "../../mocks/ERC1155ReceiverMock.sol";

contract ERC1155Test is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC1155Mock token;

  address owner = address(1);
  address other = address(2);
  uint256 id = 1;

  function setUp() public {
    // Deploy mock(s)
    token = new ERC1155Mock();

    // Do required action(s)
    token.mint(owner, id, 1);
    token.mint(other, id, 1);
    vm.prank(owner);
    token.setApprovalForAll(address(this), true);
  }

  // totalSupply
  function testTotalSupply() public {
    assertEq(token.totalSupply(id), 2);
    token.mint(owner, id, 1);
    assertEq(token.totalSupply(id), 3);
  }

  // exists
  function testExists(uint256 id_) view public {
    require(token.exists(id));
    require(!token.exists(id_));
  }
}