// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "./vm.sol";
import "../utils/Proxy.sol";
import "./mocks/ERC20UpgradableMock.sol";

contract TestERC20Upgradable is DSTest {
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC20UpgradableMock implementation;
  Proxy proxy;
  ERC20UpgradableMock token;

  address owner = address(1);
  address other = address(2);

  bytes32 PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

  function setUp() public {
    // Deploy mock(s)
    implementation = new ERC20UpgradableMock();
    proxy = new Proxy(address(implementation));
    token = ERC20UpgradableMock(address(proxy));
    token.initialize("Token", "TKN", 18, "1");
  }

  function testMetadata() public {
    assertEq(token.name(), "Token");
    assertEq(token.symbol(), "TKN");
    assertEq(token.decimals(), 18);
    assertEq(token.version(), "1");
  }

  function testMint() public {
    token.mint(owner, 1e18);

    assertEq(token.totalSupply(), 1e18);
    assertEq(token.balanceOf(owner), 1e18);
  }

  function testBurn() public {
    token.mint(owner, 1e18);
    token.burn(owner, 0.9e18);

    assertEq(token.totalSupply(), 1e18 - 0.9e18);
    assertEq(token.balanceOf(owner), 0.1e18);
  }

  function testApprove() public {
    assertTrue(token.approve(owner, 1e18));
    assertEq(token.allowance(address(this), owner), 1e18);
  }

  function testTransfer() public {
    token.mint(address(this), 1e18);

    assertTrue(token.transfer(owner, 1e18));
    assertEq(token.totalSupply(), 1e18);

    assertEq(token.balanceOf(address(this)), 0);
    assertEq(token.balanceOf(owner), 1e18);
  }

  function testTransferExceedsBalance() public {
    token.mint(address(this), 0.9e18);

    vm.expectRevert("ERC20: insufficient balance");
    token.transfer(owner, 1e18);
  }

  function testTransferFrom() public {
    token.mint(owner, 1e18);
    vm.prank(owner);
    token.approve(address(this), 1e18);

    assertTrue(token.transferFrom(owner, address(this), 1e18));
    assertEq(token.totalSupply(), 1e18);

    assertEq(token.allowance(owner, address(this)), 0);

    assertEq(token.balanceOf(owner), 0);
    assertEq(token.balanceOf(address(this)), 1e18);
  }

  function testTransferFromInifiniteApproval() public {
    token.mint(owner, 1e18);
    vm.prank(owner);
    token.approve(address(this), type(uint256).max);

    assertTrue(token.transferFrom(owner, address(this), 1e18));
    assertEq(token.totalSupply(), 1e18);

    assertEq(token.allowance(owner, address(this)), type(uint256).max);

    assertEq(token.balanceOf(owner), 0);
    assertEq(token.balanceOf(address(this)), 1e18);
  }

  function testTransferFromExceedAllowance() public {
    token.mint(owner, 1e18);

    vm.startPrank(owner);
    token.approve(address(this), 0.9e18);

    vm.expectRevert("ERC20: allowance exceeds transfer value");
    token.transferFrom(owner, address(this), 1e18);
  }

  function testBeforeTransferHook() public {
    token.mint(address(this), 1e18);

    (address from, address to, uint256 value) = abi.decode(token.beforeTransferData(), (address, address, uint256));
    assertEq(from, address(0));
    assertEq(to, address(this));
    assertEq(value, 1e18);

    token.burn(address(this), 0.5e18);

    (from, to, value) = abi.decode(token.beforeTransferData(), (address, address, uint256));
    assertEq(from, address(this));
    assertEq(to, address(0));
    assertEq(value, 0.5e18);

    token.transfer(owner, 0.5e18);

    (from, to, value) = abi.decode(token.beforeTransferData(), (address, address, uint256));
    assertEq(from, address(this));
    assertEq(to, owner);
    assertEq(value, 0.5e18);
  }

  function testAfterTransferHook() public {
    token.mint(address(this), 1e18);

    (address from, address to, uint256 value) = abi.decode(token.afterTransferData(), (address, address, uint256));
    assertEq(from, address(0));
    assertEq(to, address(this));
    assertEq(value, 1e18);

    token.burn(address(this), 0.5e18);

    (from, to, value) = abi.decode(token.afterTransferData(), (address, address, uint256));
    assertEq(from, address(this));
    assertEq(to, address(0));
    assertEq(value, 0.5e18);

    token.transfer(owner, 0.5e18);

    (from, to, value) = abi.decode(token.afterTransferData(), (address, address, uint256));
    assertEq(from, address(this));
    assertEq(to, owner);
    assertEq(value, 0.5e18);
  }

  function testPermit() public {
    uint256 privateKey = 0xBEEF;
    address signer = vm.addr(privateKey);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKey,
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          token.DOMAIN_SEPARATOR(),
          keccak256(abi.encode(PERMIT_TYPEHASH, signer, other, 1e18, 0, block.timestamp))
        )
      )
    );

    token.permit(signer, other, 1e18, block.timestamp, v, r, s);

    assertEq(token.allowance(signer, other), 1e18);
    assertEq(token.nonces(signer), 1);
  }

  function testPermitExpiredDeadline() public {
    uint256 privateKey = 0xBEEF;
    address signer = vm.addr(privateKey);

    // default block.timestamp is 0 so we have to warp it
    vm.warp(42);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKey,
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          token.DOMAIN_SEPARATOR(),
          keccak256(abi.encode(PERMIT_TYPEHASH, signer, other, 1e18, 0, block.timestamp - 1))
        )
      )
    );

    vm.expectRevert("ERC20: expired permit deadline");
    token.permit(signer, other, 1e18, block.timestamp - 1, v, r, s);
  }

  function testPermitSignerNotOwner() public {
    uint256 privateKey = 0xBEEF;
    address signer = vm.addr(privateKey);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKey,
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          token.DOMAIN_SEPARATOR(),
          keccak256(abi.encode(PERMIT_TYPEHASH, owner, other, 1e18, 0, block.timestamp))
        )
      )
    );

    vm.expectRevert("ERC20: invalid signature");
    token.permit(signer, other, 1e18, block.timestamp, v, r, s);
  }

  function testPermitInvalidNonce() public {
    uint256 privateKey = 0xBEEF;
    address signer = vm.addr(privateKey);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKey,
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          token.DOMAIN_SEPARATOR(),
          keccak256(abi.encode(PERMIT_TYPEHASH, signer, other, 1e18, 1, block.timestamp))
        )
      )
    );

    vm.expectRevert("ERC20: invalid signature");
    token.permit(signer, other, 1e18, block.timestamp, v, r, s);
  }

  function testSetImplementation() public {
    ERC20UpgradableMock newToken = new ERC20UpgradableMock();
    proxy.setImplementation(address(newToken));
    token.initialize("Token", "TKN", 18, "2");

    assertEq(proxy.implementation(), address(newToken));
    assertEq(token.version(), "2");
  }
}
