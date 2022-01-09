// SPDX-License-Identifier: UNLICESED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "./vm.sol";
import "./mocks/ERC1155Mock.sol";
import "./mocks/ERC1155ReceiverMock.sol";

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

  // balanceOf
  function testBalanceOf() public {
    assertEq(token.balanceOf(owner, id), 1);
  }

  // balanceOfBatch
  function testBalanceOfBatch() public {
    address[] memory accounts = new address[](2);
    uint256[] memory ids = new uint256[](2);

    accounts[0] = owner;
    accounts[1] = other;
    ids[0] = id;
    ids[1] = id;

    uint256[] memory balances = token.balanceOfBatch(accounts, ids);
    assertEq(balances.length, 2);
    assertEq(balances[0], 1);
    assertEq(balances[1], 1);
  }

  function testBalanceOfBatchLengthMismatch() public {
    address[] memory accounts = new address[](2);
    uint256[] memory ids = new uint256[](1);

    vm.expectRevert("ERC1155: accounts and ids length mismatch");
    token.balanceOfBatch(accounts, ids);
  }

  // safeTransferFrom
  function testSafeTransferFrom() public {
    ERC1155ReceiverMock receiver = new ERC1155ReceiverMock();
    token.safeTransferFrom(owner, address(receiver), id, 1, "");
    assertEq(token.balanceOf(address(receiver), id), 1);
    require(receiver.received());
  }

  function testSafeTransferFromNotApproved() public {
    vm.expectRevert("ERC1155: caller is not owner nor approved");
    token.safeTransferFrom(other, owner, id, 1, "");
  }

  function testSafeTransferFromToZeroAddress() public {
    vm.expectRevert("ERC1155: transfer to the zero address");
    token.safeTransferFrom(owner, address(0), id, 1, "");
  }

  function testSafeTransferFromInsufficientBalance() public {
    vm.expectRevert("ERC1155: insufficient balance for transfer");
    token.safeTransferFrom(owner, other, id, 2, "");
  }

  function testSafeTransferFromNonReceiver() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC1155: transfer to non ERC1155Receiver implementer");
    token.safeTransferFrom(owner, address(this), id, 1, "");
  }


  // safeBatchTransferFrom
  function testSafeBatchTransferFrom() public {
    ERC1155ReceiverMock receiver = new ERC1155ReceiverMock();

    uint256[] memory ids = new uint256[](1);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id;
    amounts[0] = 1;

    token.safeBatchTransferFrom(owner, address(receiver), ids, amounts, "");
    assertEq(token.balanceOf(address(receiver), id), 1);
    require(receiver.batchReceived());
  }

  function testSafeBatchTransferFromNotApproved() public {
    uint256[] memory ids = new uint256[](2);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id;
    ids[1] = 1;
    vm.expectRevert("ERC1155: transfer caller is not owner nor approved");
    token.safeBatchTransferFrom(other, owner, ids, amounts, "");
  }

  function testSafeBatchTransferFromLengthMismatch() public {
    ERC1155ReceiverMock receiver = new ERC1155ReceiverMock();

    uint256[] memory ids = new uint256[](2);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id;
    ids[1] = 1;
    amounts[0] = 1;

    vm.expectRevert("ERC1155: ids and amounts length mismatch");
    token.safeBatchTransferFrom(owner, address(receiver), ids, amounts, "");
  }

  function testSafeBatchTransferFromToZeroAddress() public {
    uint256[] memory ids = new uint256[](1);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id;
    amounts[0] = 1;
    vm.expectRevert("ERC1155: transfer to the zero address");
    token.safeBatchTransferFrom(owner, address(0), ids, amounts, "");
  }

  function testSafeBatchTransferFromInsufficientBalance() public {
    uint256[] memory ids = new uint256[](1);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id + 1;
    amounts[0] = 2;

    vm.expectRevert("ERC1155: insufficient balance for transfer");
    token.safeBatchTransferFrom(owner, other, ids, amounts, "");
  }

  function testSafeBatchTransferFromNonReceiver() public {
    uint256[] memory ids = new uint256[](1);
    uint256[] memory amounts = new uint256[](1);
    ids[0] = id;
    amounts[0] = 1;

    vm.startPrank(owner);
    vm.expectRevert("ERC1155: transfer to non ERC1155Receiver implementer");
    token.safeBatchTransferFrom(owner, address(this), ids, amounts, "");
  }

  // _mint
  function testMint() public {
    token.mint(owner, id, 1);
    assertEq(token.balanceOf(owner, id), 2);
  }

  // _mintBatch
  function testMintBatch() public {
    uint256[] memory ids = new uint256[](2);
    uint256[] memory amounts = new uint256[](2);
    ids[0] = id;
    ids[1] = id + 1;
    amounts[0] = 1;
    amounts[1] = 1;

    token.mintBatch(owner, ids, amounts);
    assertEq(token.balanceOf(owner, id), 2);
    assertEq(token.balanceOf(owner, id + 1), 1);
  }

  // _burn
  function testBurn() public {
    token.burn(owner, id, 1);
    assertEq(token.balanceOf(owner, id), 0);
  }

  // _burnBatch
  function testBurnBatch() public {
    uint256[] memory ids = new uint256[](2);
    uint256[] memory amounts = new uint256[](2);
    ids[0] = id;
    ids[1] = id + 1;
    amounts[0] = 1;
    amounts[1] = 1;

    token.mint(owner, id + 1, 1); // mint the second token
    assertEq(token.balanceOf(owner, id + 1), 1);

    token.burnBatch(owner, ids, amounts);
    assertEq(token.balanceOf(owner, id), 0);
    assertEq(token.balanceOf(owner, id + 1), 0);
  }

  // setApprovalForAll
  function testSetApprovalForAll() public {
    vm.prank(owner);
    token.setApprovalForAll(other, true);
    require(token.isApprovedForAll(owner, other));
  }

  function testSetApprovalForAllToCaller() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC1155: setting approval status for self");
    token.setApprovalForAll(owner, true);
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