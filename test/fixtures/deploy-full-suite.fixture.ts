import { BigNumber, Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import OnchainID from "@onchain-id/solidity";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { AGENT_ROLE, TOKEN_ROLE } from "../utils";

export async function deployIdentityProxy(
  implementationAuthority: Contract["address"],
  managementKey: string,
  signer: Signer
) {
  const identity = await new ethers.ContractFactory(
    OnchainID.contracts.IdentityProxy.abi,
    OnchainID.contracts.IdentityProxy.bytecode,
    signer
  ).deploy(implementationAuthority, managementKey);

  return ethers.getContractAt("Identity", identity.address, signer);
}

export async function deployFullSuiteFixture() {
  const [
    deployer,
    tokenIssuer,
    tokenAgent,
    tokenAdmin,
    claimIssuer,
    aliceWallet,
    bobWallet,
    charlieWallet,
    davidWallet,
    anotherWallet,
  ] = await ethers.getSigners();
  const claimIssuerSigningKey = ethers.Wallet.createRandom();
  const aliceActionKey = ethers.Wallet.createRandom();

  const identityImplementation = await new ethers.ContractFactory(
    OnchainID.contracts.Identity.abi,
    OnchainID.contracts.Identity.bytecode,
    deployer
  ).deploy(deployer.address, true);

  const identityImplementationAuthority = await new ethers.ContractFactory(
    OnchainID.contracts.ImplementationAuthority.abi,
    OnchainID.contracts.ImplementationAuthority.bytecode,
    deployer
  ).deploy(identityImplementation.address);

  const ClaimTopicsRegistry = await ethers.getContractFactory(
    "ClaimTopicsRegistry"
  );
  const claimTopicsRegistry = await ClaimTopicsRegistry.deploy();

  const ClaimIssuersRegistry = await ethers.getContractFactory(
    "ClaimIssuersRegistry"
  );
  const claimIssuersRegistry = await ClaimIssuersRegistry.deploy();

  const IdentityRegistryStorage = await ethers.getContractFactory(
    "IdentityRegistryStorage"
  );
  const identityRegistryStorage = await IdentityRegistryStorage.deploy();

  const IdentityRegistry = await ethers.getContractFactory("IdentityRegistry");
  const identityRegistry = await IdentityRegistry.deploy(
    claimIssuersRegistry.address,
    claimTopicsRegistry.address,
    identityRegistryStorage.address
  );

  const basicCompliance = await ethers.deployContract(
    "BasicCompliance",
    deployer
  );

  const tokenOID = await deployIdentityProxy(
    identityImplementationAuthority.address,
    tokenIssuer.address,
    deployer
  );

  const tokenName = "ERC-3643";

  const tokenSymbol = "TREX";

  const tokenDecimals = BigNumber.from("6");

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy(
    identityRegistry.address,
    basicCompliance.address,
    tokenName,
    tokenSymbol,
    tokenDecimals,
    tokenOID.address
  );

  await basicCompliance.grantRole(TOKEN_ROLE, token.address);

  await token.grantRole(AGENT_ROLE, tokenAgent.address);

  await identityRegistryStorage.bindIdentityRegistry(identityRegistry.address);

  const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];
  await claimTopicsRegistry.connect(deployer).addClaimTopic(claimTopics[0]);

  const claimIssuerContract = await ethers.deployContract(
    "ClaimIssuer",
    [claimIssuer.address],
    claimIssuer
  );

  await claimIssuerContract
    .connect(claimIssuer)
    .addKey(
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address"],
          [claimIssuerSigningKey.address]
        )
      ),
      3,
      1
    );

  await claimIssuersRegistry
    .connect(deployer)
    .addClaimIssuer(claimIssuerContract.address, claimTopics);

  const aliceIdentity = await deployIdentityProxy(
    identityImplementationAuthority.address,
    aliceWallet.address,
    deployer
  );

  await aliceIdentity
    .connect(aliceWallet)
    .addKey(
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address"],
          [aliceActionKey.address]
        )
      ),
      2,
      1
    );

  const bobIdentity = await deployIdentityProxy(
    identityImplementationAuthority.address,
    bobWallet.address,
    deployer
  );

  const charlieIdentity = await deployIdentityProxy(
    identityImplementationAuthority.address,
    charlieWallet.address,
    deployer
  );

  await identityRegistry.grantRole(AGENT_ROLE, tokenAgent.address);
  await identityRegistry.grantRole(TOKEN_ROLE, token.address);

  await identityRegistry
    .connect(tokenAgent)
    .batchRegisterIdentity(
      [aliceWallet.address, bobWallet.address],
      [aliceIdentity.address, bobIdentity.address],
      [42, 666]
    );

  const claimForAlice = {
    data: ethers.utils.hexlify(
      ethers.utils.toUtf8Bytes("Some claim public data.")
    ),
    issuer: claimIssuerContract.address,
    topic: claimTopics[0],
    scheme: 1,
    identity: aliceIdentity.address,
    signature: "",
  };

  claimForAlice.signature = await claimIssuerSigningKey.signMessage(
    ethers.utils.arrayify(
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address", "uint256", "bytes"],
          [claimForAlice.identity, claimForAlice.topic, claimForAlice.data]
        )
      )
    )
  );

  await aliceIdentity
    .connect(aliceWallet)
    .addClaim(
      claimForAlice.topic,
      claimForAlice.scheme,
      claimForAlice.issuer,
      claimForAlice.signature,
      claimForAlice.data,
      ""
    );

  const claimForBob = {
    data: ethers.utils.hexlify(
      ethers.utils.toUtf8Bytes("Some claim public data.")
    ),
    issuer: claimIssuerContract.address,
    topic: claimTopics[0],
    scheme: 1,
    identity: bobIdentity.address,
    signature: "",
  };

  claimForBob.signature = await claimIssuerSigningKey.signMessage(
    ethers.utils.arrayify(
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address", "uint256", "bytes"],
          [claimForBob.identity, claimForBob.topic, claimForBob.data]
        )
      )
    )
  );

  await bobIdentity
    .connect(bobWallet)
    .addClaim(
      claimForBob.topic,
      claimForBob.scheme,
      claimForBob.issuer,
      claimForBob.signature,
      claimForBob.data,
      ""
    );

  await token.connect(tokenAgent).mint(aliceWallet.address, 1000);
  await token.connect(tokenAgent).mint(bobWallet.address, 500);

  return {
    accounts: {
      deployer,
      tokenIssuer,
      tokenAgent,
      tokenAdmin,
      claimIssuer,
      claimIssuerSigningKey,
      aliceActionKey,
      aliceWallet,
      bobWallet,
      charlieWallet,
      davidWallet,
      anotherWallet,
    },
    identities: {
      aliceIdentity,
      bobIdentity,
      charlieIdentity,
    },
    suite: {
      claimIssuerContract,
      claimTopicsRegistry,
      claimIssuersRegistry,
      identityRegistryStorage,
      basicCompliance,
      identityRegistry,
      tokenOID,
      token,
    },
    implementations: {
      identityImplementation,
    },
  };
}
