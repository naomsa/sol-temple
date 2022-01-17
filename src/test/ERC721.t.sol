// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./vm.sol";
import "./mocks/ERC721Mock.sol";
import "./mocks/ERC721ReceiverMock.sol";

contract ERC721Test is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC721Mock token;

  address owner = address(1);
  address other = address(2);
  uint256 nextId;

  function setUp() public {
    // Deploy mock(s)
    token = new ERC721Mock();

    // Do required action(s)
    token.mint(owner, 0);
    nextId = 1;
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
    vm.expectRevert("ERC721: balance query for the zero address");
    token.balanceOf(address(0));
  }

  // ownerOf
  function testOwnerOf() public {
    assertEq(token.ownerOf(0), owner);
  }

  function testOwnerOfZeroAddressQuery() public {
    vm.expectRevert("ERC721: query for nonexistent token");
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
    vm.expectRevert("ERC721: transfer of token that is not own");
    token.transferFrom(other, owner, 0);
  }

  function testTransferFromNotApproved() public {
    token.mint(other, nextId);
    vm.expectRevert("ERC721: transfer caller is not owner nor approved");
    token.transferFrom(other, owner, nextId);
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
    vm.expectRevert("ERC721: safe transfer to non ERC721Receiver implementation");
    token.safeTransferFrom(owner, address(this), 0);
  }

  function testSafeTransferFromNotApproved() public {
    token.mint(other, nextId);
    vm.expectRevert("ERC721: transfer caller is not owner nor approved");
    token.safeTransferFrom(other, owner, nextId);
  }

  // _mint
  function testMint() public {
    token.mint(owner, nextId);
    assertEq(token.balanceOf(owner), 2);
  }

  function testMintAlreadyMinted() public {
    vm.expectRevert("ERC721: token already minted");
    token.mint(owner, 0);
  }

  // _burn
  function testBurn() public {
    token.burn(0);
    assertEq(token.balanceOf(owner), 0);
    vm.expectRevert("ERC721: query for nonexistent token");
    assertEq(token.ownerOf(0), address(0));
    vm.expectRevert("ERC721: query for nonexistent token");
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
    vm.expectRevert("ERC721: approve to caller");
    token.setApprovalForAll(owner, true);
  }

  // approve
  function testApproveToOwner() public {
    vm.startPrank(owner);
    vm.expectRevert("ERC721: approval to current owner");
    token.approve(owner, 0);
  }

  function testTotalSupply() public {
    assertEq(token.totalSupply(), nextId);
    token.mint(owner, nextId++);
    assertEq(token.totalSupply(), nextId);
  }

  // tokenOfOwnerByIndex
  function testTokenOfOwnerByIndex() public {
    assertEq(token.tokenOfOwnerByIndex(owner, 0), 0);
    token.mint(owner, nextId++);
    assertEq(token.tokenOfOwnerByIndex(owner, 1), nextId - 1);
    token.mint(other, nextId++);
    assertEq(token.tokenOfOwnerByIndex(other, 0), nextId - 1);
  }

  function testTokenOfOwnerByIndexOutOfBounds() public {
    vm.expectRevert("ERC721Enumerable: Index out of bounds");
    token.tokenOfOwnerByIndex(owner, 1);
  }

  // tokenByIndex
  function testTokenByIndex() public {
    assertEq(token.tokenByIndex(0), 0);
  }

  function testTokenByIndexOutOfBounds() public {
    vm.expectRevert("ERC721Enumerable: Index out of bounds");
    token.tokenByIndex(1);
  }

  // tokensOfOwner
  function testTokensOfOwner() public {
    uint256[] memory wallet = token.walletOfOwner(owner);
    assertEq(wallet.length, 1);
    assertEq(wallet[0], 0);

    token.mint(owner, nextId);
    wallet = token.walletOfOwner(owner);
    assertEq(wallet.length, 2);
    assertEq(wallet[0], 0);
    assertEq(wallet[1], 1);
  }
}
