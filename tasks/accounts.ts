import { task } from "hardhat/config";
import type { Signer } from "@ethersproject/abstract-signer";

task("accounts", "Prints the list of accounts", async (_, { ethers }) => {
  const accounts: Signer[] = await ethers.getSigners();
  for (const account of accounts) {
    console.log(await account.getAddress());
  }
});
