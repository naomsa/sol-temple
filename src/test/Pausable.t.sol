// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./vm.sol";
import "./mocks/PausableMock.sol";

contract PausableTest is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  PausableMock mock;

  address owner = address(1);
  address other = address(2);

  function setUp() public {
    mock = new PausableMock();
  }

  // constructor
  function testConstructor() public view {
    require(!mock.paused());
  }

  // _togglePaused
  function testTogglePaused() public {
    mock.togglePaused();
    require(mock.paused());
  }

  // onlyWhenPaused
  function testOnlyWhenPaused() public {
    vm.expectRevert("Pausable: contract not paused");
    mock.store(42);

    mock.togglePaused();
    mock.store(42);
  }

  // onlyWhenPaused
  function testOnlyWhenUnpaused() public {
    mock.togglePaused();
    vm.expectRevert("Pausable: contract paused");
    mock.retrieve();

    mock.togglePaused();
    mock.retrieve();
  }
}
