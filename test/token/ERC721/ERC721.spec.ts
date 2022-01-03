import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { ERC721Mock } from "../../../typechain/ERC721Mock";

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

describe("ERC721", () => {
  let [owner, other]: SignerWithAddress[] = [];
  let contract: ERC721Mock;
  let nextTokenId: number;

  beforeEach(async () => {
    [owner, other] = await ethers.getSigners();

    contract = (await (
      await ethers.getContractFactory("ERC721Mock")
    ).deploy()) as ERC721Mock;
    await contract.mint(owner.address, 0);
    await contract.mint(owner.address, 1);
    nextTokenId = 2;
  });

  describe("balanceOf", () => {
    it("Should return owner's balance", async () => {
      expect(await contract.balanceOf(owner.address)).to.equal(2);
    });

    it("Should return other's balance", async () => {
      expect(await contract.balanceOf(other.address)).to.equal(0);
    });

    it("Should throw when querying the 0 address", async () => {
      await expect(contract.balanceOf(ZERO_ADDRESS)).to.be.revertedWith(
        "ERC721::balanceOf: balance query for the zero address",
      );
    });
  });

  describe("ownerOf", () => {
    it("Should point owner and other", async () => {
      expect(await contract.ownerOf(0)).to.equal(owner.address);
      await contract.mint(other.address, nextTokenId);
      expect(await contract.ownerOf(2)).to.equal(other.address);
    });

    it("Should throw when querying for nonexisting token", async () => {
      await expect(contract.ownerOf(42)).to.be.revertedWith(
        "ERC721::ownerOf: query for nonexistent token",
      );
    });
  });

  describe("safeTransferFrom & transferFrom", () => {
    it("Should safeTransfer token #0 from owner to other and transfer back", async () => {
      await contract["safeTransferFrom(address,address,uint256)"](
        owner.address,
        other.address,
        0,
      );
      expect(await contract.ownerOf(0)).to.equal(other.address);
      await contract
        .connect(other)
        .transferFrom(other.address, owner.address, 0);
      expect(await contract.ownerOf(0)).to.equal(owner.address);
    });

    it("Should invoke receiver callback", async () => {
      const receiver = await (
        await ethers.getContractFactory("ERC721ReceiverMock")
      ).deploy();

      await contract["safeTransferFrom(address,address,uint256)"](
        owner.address,
        receiver.address,
        0,
      );
      expect(await contract.balanceOf(receiver.address)).to.equal(1);
    });

    it("Should throw when transfering to non receiver contract", async () => {
      await expect(
        contract["safeTransferFrom(address,address,uint256)"](
          owner.address,
          contract.address,
          0,
        ),
      ).to.be.revertedWith(
        "ERC721::_checkOnERC721Received: transfer to non ERC721Receiver implementer",
      );
    });

    it("Should throw when sender not approved", async () => {
      await expect(
        contract.connect(other).transferFrom(owner.address, other.address, 0),
      ).to.be.revertedWith(
        "ERC721::transferFrom: transfer caller is not owner nor approved",
      );

      await expect(
        contract
          .connect(other)
          ["safeTransferFrom(address,address,uint256)"](
            owner.address,
            other.address,
            0,
          ),
      ).to.be.revertedWith(
        "ERC721::safeTransferFrom: transfer caller is not owner nor approved",
      );
    });
  });

  describe("_mint", () => {
    it("Should throw when token was already minted", async () => {
      await expect(contract.mint(other.address, 0)).to.be.revertedWith(
        "ERC721::_mint: token already minted",
      );
    });
  });

  describe("_burn", async () => {
    it("Should burn token #0", async () => {
      await contract.burn(0);
      await expect(contract.ownerOf(0)).to.revertedWith(
        "ERC721::ownerOf: query for nonexistent token",
      );
    });
  });

  describe("approve, getApproved, isApprovedForAll & setApprovalForAll", () => {
    it("Should approve token #0 to other", async () => {
      await contract.approve(other.address, 0);
      expect(await contract.getApproved(0)).to.equal(other.address);
    });

    it("Should approve all tokens from the owner to other", async () => {
      await contract.setApprovalForAll(other.address, true);
      expect(
        await contract.isApprovedForAll(owner.address, other.address),
      ).to.equal(true);
    });

    it("Should have no approves", async () => {
      expect(await contract.getApproved(0)).to.equal(ZERO_ADDRESS);
    });

    it("Should throw when operator is owner", async () => {
      await expect(
        contract.setApprovalForAll(owner.address, true),
      ).to.be.revertedWith("ERC721::_setApprovalForAll: approve to caller");

      await expect(contract.approve(owner.address, 0)).to.be.revertedWith(
        "ERC721::approve: approval to current owner",
      );
    });
  });
});
