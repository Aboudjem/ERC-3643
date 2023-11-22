const {
  deployFullSuiteFixture,
} = require("../test/fixtures/deploy-full-suite.fixture.ts");

async function main() {
  const deployment = await deployFullSuiteFixture();

  console.log(deployment);
  console.log("\n~~ Accounts ~~");
  console.log("Deployer: ", deployment.accounts.deployer.address);
  console.log("Token Issuer: ", deployment.accounts.tokenIssuer.address);
  console.log("Token Agent: ", deployment.accounts.tokenAgent.address);
  console.log("Token Admin: ", deployment.accounts.tokenAdmin.address);
  console.log("Claim Issuer: ", deployment.accounts.claimIssuer.address);
  console.log(
    "Claim Issuer Signing Key: ",
    deployment.accounts.claimIssuerSigningKey.address
  );
  console.log("Alice Action Key: ", deployment.accounts.aliceActionKey.address);
  console.log("Alice Wallet: ", deployment.accounts.aliceWallet.address);
  console.log("Bob WAllet: ", deployment.accounts.bobWallet.address);
  console.log("Charlie Wallet: ", deployment.accounts.charlieWallet.address);
  console.log("David Wallet: ", deployment.accounts.davidWallet.address);
  console.log("Another Wallet: ", deployment.accounts.anotherWallet.address);
  console.log("\n~~ Identities ~~");
  console.log("Alice Identity: ", deployment.identities.aliceIdentity.address);
  console.log("Bob Identity: ", deployment.identities.bobIdentity.address);
  console.log(
    "Charlie Identity: ",
    deployment.identities.charlieIdentity.address
  );
  console.log("\n~~ Suite ~~");
  console.log(
    "Claim Issuer Contract: ",
    deployment.suite.claimIssuerContract.address
  );
  console.log(
    "Claim Topics Registry: ",
    deployment.suite.claimTopicsRegistry.address
  );
  console.log(
    "Identity Registry Storage: ",
    deployment.suite.identityRegistryStorage.address
  );
  console.log("Basic Compliance: ", deployment.suite.basicCompliance.address);
  console.log("Identity Registry: ", deployment.suite.identityRegistry.address);
  console.log("TokenOID: ", deployment.suite.tokenOID.address);
  console.log("Token: ", deployment.suite.token.address);
  console.log("\n--- --- --- --- ---");
  console.log("Deployment completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
