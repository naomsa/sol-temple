// SPDX-License-Identifier: UNLICESED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../../vm.sol";
import "../../mocks/ERC721Mock.sol";
import "../../mocks/ERC721ReceiverMock.sol";

contract ERC721EnumerableTest is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC721Mock token;

  address owner = address(1);
  address other = address(2);
  uint256 nextTokenId;

  function setUp() public {
    // Deploy mock(s)
    token = new ERC721Mock();

    // Do required action(s)
    token.mint(owner, 0);
    nextTokenId = 1;
    vm.prank(owner);
    token.setApprovalForAll(address(this), true);
  }

  // totalSupply
  function testTotalSupply() public {
    assertEq(token.totalSupply(), nextTokenId);
    token.mint(owner, nextTokenId++);
    assertEq(token.totalSupply(), nextTokenId);
  }

  // tokenOfOwnerByIndex
  function testTokenOfOwnerByIndex() public {
    assertEq(token.tokenOfOwnerByIndex(owner, 0), 0);
    token.mint(owner, nextTokenId++);
    assertEq(token.tokenOfOwnerByIndex(owner, 1), nextTokenId - 1);
    token.mint(other, nextTokenId++);
    assertEq(token.tokenOfOwnerByIndex(other, 0), nextTokenId - 1);
  }

  function testTokenOfOwnerByIndexOutOfBounds() public {
    vm.expectRevert("ERC721Enumerable::tokenOfOwnerByIndex: Index out of bounds");
    token.tokenOfOwnerByIndex(owner, 1);
  }

  // tokenByIndex
  function testTokenByIndex() public {
    assertEq(token.tokenByIndex(0), 0);
  }

  function testTokenByIndexOutOfBounds() public {
    vm.expectRevert("ERC721Enumerable::tokenByIndex: Index out of bounds");
    token.tokenByIndex(1);
  }

  // tokensOfOwner
  function testTokensOfOwner() public {
    uint256[] memory wallet = token.tokensOfOwner(owner);
    assertEq(wallet.length, 1);
    assertEq(wallet[0], 0);
  }
}