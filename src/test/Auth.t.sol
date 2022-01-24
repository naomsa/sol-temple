// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./utils/vm.sol";
import "./mocks/AuthMock.sol";

contract AuthTest is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  AuthMock mock;

  address owner = address(1);
  address other = address(2);

  function setUp() public {
    mock = new AuthMock();
  }

  // constructor
  function testConstructor() public {
    assertEq(mock.owner(), address(this));
  }

  // transferOwnership
  function testTransferOwnership() public {
    mock.transferOwnership(owner);
    assertEq(mock.owner(), owner);
  }

  function testTransferOwnershipToCurrentOwner() public {
    mock.transferOwnership(owner);
    vm.prank(owner);
    vm.expectRevert("Auth: transfering ownership to current owner");
    mock.transferOwnership(owner);
  }
}
