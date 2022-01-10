// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./vm.sol";
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

  // auth
  function testAuth() public {
    vm.prank(owner);
    vm.expectRevert("Auth: sender is not the owner or authorized to call");
    mock.store(123);

    bytes memory data = abi.encodeWithSignature("store(uint256)", 123);
    mock.auth(owner, data);
    require(mock.isAuthorized(owner, data));

    vm.prank(owner);
    mock.store(123);
    assertEq(mock.number(), 123);

    require(!mock.isAuthorized(owner, data));
  }

  function testAuthToOwner() public {
    mock.transferOwnership(owner);

    vm.prank(owner);
    vm.expectRevert("Auth: authorizing call to the owner");
    mock.auth(owner, "");
  }

  function testAuthWithAuthorizedData() public {
    bytes memory data = abi.encodeWithSignature("store(uint256)", 123);
    mock.auth(owner, data);
    require(mock.isAuthorized(owner, data));

    vm.expectRevert("Auth: authorized calls cannot be authed");
    mock.auth(owner, data);
  }

  // forbid
  function testForbid() public {
    bytes memory data = abi.encodeWithSignature("store(uint256)", 123);

    mock.auth(owner, data);
    mock.forbid(owner, data);
    require(!mock.isAuthorized(owner, data));
  }

  function testForbidWithUnauthorizedData() public {
    bytes memory data = abi.encodeWithSignature("store(uint256)", 123);

    vm.expectRevert("Auth: unauthorized calls cannot be forbidden");
    mock.forbid(owner, data);
  }
}
