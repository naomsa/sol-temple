// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./utils/vm.sol";
import "../utils/Proxy.sol";
import "./mocks/ProxyMock.sol";

contract ProxyTest is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ProxyMock implementation;
  Proxy proxy;
  ProxyMock mock;

  address owner = address(1);
  address other = address(2);

  function setUp() public {
    implementation = new ProxyMock();
    proxy = new Proxy(address(implementation));
    mock = ProxyMock(address(proxy));
  }

  // constructor
  function testConstructor() public {
    assertEq(Proxy(payable(address(mock))).implementation(), address(implementation));
  }

  // _delegate
  function testDelegate() public {
    assertEq(mock.retrieve(), 0);
    mock.store(42);
    assertEq(mock.retrieve(), 42);
  }

  // setImplementation
  function testSetImplementation() public {
    ProxyMock _mock = new ProxyMock();

    proxy.setImplementation(address(_mock));
    assertEq(proxy.implementation(), address(_mock));
  }

  function testSetImplementationToZeroAddress() public {
    vm.expectRevert("Proxy: upgrading to the zero address");
    proxy.setImplementation(address(0));
  }

  function testSetImplementationToCurrentImplementation() public {
    vm.expectRevert("Proxy: upgrading to the current implementation");
    proxy.setImplementation(address(implementation));
  }
}
