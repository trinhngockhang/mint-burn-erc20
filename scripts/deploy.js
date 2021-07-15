const hre = require("hardhat");
require("@nomiclabs/hardhat-web3");
async function main() {
  const [owner] = await ethers.getSigners();
  const Token = await ethers.getContractFactory('Token');
  const argsDeploy = ["Khang", 'TNK', '18', [owner.address], [owner.address], owner.address]
  const token = await Token.deploy(argsDeploy);
  console.log('DEPLOY TO: ', token.address);

  // chua chay, phai chay lan 2
  await hre.run("verify:verify", {
    address: token.address,
    constructorArguments: argsDeploy,
  });
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
