import { ethers } from "hardhat";

async function main() {
  const greeter = await (
    await ethers.getContractFactory("Greeter")
  ).deploy("Hello, World!");

  await greeter.deployed();
  console.log("Greeter: ", greeter.address);
}

main().catch((error) => {
  console.log(error);
  process.exit(1);
});
