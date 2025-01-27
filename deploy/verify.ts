import hre from "hardhat";

const upcadeVaultProxyAddress = process.env.VAULT_PROXY_ADDRESS!;
const upcadeVaultImplementationAddress = process.env.VAULT_IMPLEMENTATION_ADDRESS!;
const upcadeVaultFullyQualifedName = "contracts/UpcadeVault.sol:UpcadeVault";

export default async function verify() {
    await hre.run("verify:verify", {
        address: upcadeVaultImplementationAddress,
        contract: upcadeVaultFullyQualifedName,
        constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: upcadeVaultProxyAddress,
        contract: upcadeVaultFullyQualifedName,
        constructorArguments: [],
    });
}

