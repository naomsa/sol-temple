// SPDX-License-Identifier: UNLICESED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../../vm.sol";
import "../../mocks/ERC721Mock.sol";
import "../../mocks/ERC721ReceiverMock.sol";

contract ERC721Test is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC721Mock token;

  address owner = address(1);
  address other = address(2);
  uint256 nextTokenId = 1;

  function setUp() public{
    token = new ERC721Mock();
    token.mint(owner, 0);

    vm.prank(owner);
    token.setApprovalForAll(address(this), true);
  }

  // constructor
  function testConstructor() public {
    assertEq(token.name(), "ERC721 Mock");
    assertEq(token.symbol(), "MOCK");
  }

  // balanceOf
  function testBalanceOf() public {
    assertEq(token.balanceOf(owner), 1);
  }

  function testBalanceOfZeroAddressQuery() public {
    vm.expectRevert("ERC721::balanceOf: balance query for the zero address");
    token.balanceOf(address(0));
  }

  // ownerOf
  function testOwnerOf() public {
    assertEq(token.ownerOf(0), owner);
  }

  function testOwnerOfZeroAddressQuery() public {
    vm.expectRevert("ERC721::ownerOf: query for nonexistent token");
    token.ownerOf(1);
  }

  // transferFrom
  function testTransferFrom() public {
    token.transferFrom(owner, other, 0);
    assertEq(token.balanceOf(owner), 0);
    assertEq(token.balanceOf(other), 1);
    assertEq(token.ownerOf(0), other);
  }

  function testTransferFromCallback() public {
    ERC721ReceiverMock receiver = new ERC721ReceiverMock();
    token.transferFrom(owner, address(receiver), 0);
    assertEq(token.balanceOf(address(receiver)), 1);
    require(!receiver.received());
  }

  function testTransferFromNotOwner() public {
    vm.expectRevert("ERC721::_transfer: transfer of token that is not own");
    token.transferFrom(other, owner, 0);
  }

  function testTransferFromNotApproved() public {
    token.mint(other, nextTokenId);
    vm.expectRevert("ERC721::transferFrom: transfer caller is not owner nor approved");
    token.transferFrom(other, owner, nextTokenId);
  }

  // safeTransferFrom
  function testSafeTransferFrom() public {
    ERC721ReceiverMock receiver = new ERC721ReceiverMock();
    token.safeTransferFrom(owner, address(receiver), 0);
    assertEq(token.balanceOf(address(receiver)), 1);
    require(receiver.received());
  }

  function testSafeTransferFromNonReceiver() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC721::_checkOnERC721Received: transfer to non ERC721Receiver implementer");
    token.safeTransferFrom(owner, address(this), 0);
  }

  function testSafeTransferFromNotApproved() public {
    token.mint(other, nextTokenId);
    vm.expectRevert("ERC721::safeTransferFrom: transfer caller is not owner nor approved");
    token.safeTransferFrom(other, owner, nextTokenId);
  }

  // _mint
  function testMintAlreadyMinted() public {
    vm.expectRevert("ERC721::_mint: token already minted");
    token.mint(owner, 0);
  }

  // _burn
  function testBurn() public {
    token.burn(0);
    assertEq(token.balanceOf(owner), 0);
    vm.expectRevert("ERC721::ownerOf: query for nonexistent token");
    assertEq(token.ownerOf(0), address(0));
    vm.expectRevert("ERC721::getApproved: query for nonexistent token");
    token.getApproved(0);
  }

  // setApprovalForAll
  function testSetApprovalForAll() public {
    vm.prank(owner);
    token.setApprovalForAll(other, true);
    require(token.isApprovedForAll(owner, other));
  }

  function testSetApprovalForAllToCaller() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC721::_setApprovalForAll: approve to caller");
    token.setApprovalForAll(owner, true);
  }

  // approve
  function testApproveToOwner() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC721::approve: approval to current owner");
    token.approve(owner, 0);
  }
}