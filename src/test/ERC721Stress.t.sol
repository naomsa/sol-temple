// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./vm.sol";
import "./mocks/ERC721Mock.sol";
import "./mocks/ERC721ReceiverMock.sol";

contract ERC721StressTest is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC721Mock token;

  address owner = address(1);

  function setUp() public {
    // Deploy mock(s)
    token = new ERC721Mock();

    // Do required action(s)
    uint256 nextId;
    for (uint256 i = 0; i < 10000; i++) token.mint(owner, nextId++);
  }

  function testBalanceOfStress() public {
    assertEq(token.balanceOf(owner), 10000);
  }

  function testOwnerOfStress() public {
    assertEq(token.ownerOf(9999), owner);
  }
}
