import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployFullSuiteFixture } from "../fixtures/deploy-full-suite.fixture";

describe("IdentityRegistry", () => {
  describe("Deployment", () => {
    it("should reject zero address for Trustes Issuers Registry", async () => {
      const IdentityRegistry = await ethers.getContractFactory(
        "IdentityRegistry"
      );
      const address = ethers.Wallet.createRandom().address;
      await expect(
        IdentityRegistry.deploy(ethers.constants.AddressZero, address, address)
      ).to.be.revertedWith("invalid argument - zero address");
    });

    it("should reject zero address for Claim Topics Registry", async () => {
      const IdentityRegistry = await ethers.getContractFactory(
        "IdentityRegistry"
      );
      const address = ethers.Wallet.createRandom().address;
      await expect(
        IdentityRegistry.deploy(address, ethers.constants.AddressZero, address)
      ).to.be.revertedWith("invalid argument - zero address");
    });

    it("should reject zero address for Identity Storage", async () => {
      const IdentityRegistry = await ethers.getContractFactory(
        "IdentityRegistry"
      );
      const address = ethers.Wallet.createRandom().address;
      await expect(
        IdentityRegistry.deploy(address, address, ethers.constants.AddressZero)
      ).to.be.revertedWith("invalid argument - zero address");
    });
  });

  describe(".updateIdentity()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet },
          identities: { bobIdentity, charlieIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .updateIdentity(bobIdentity.address, charlieIdentity.address)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });
  });

  describe(".updateCountry()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet },
          identities: { bobIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .updateCountry(bobIdentity.address, 100)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });
  });

  describe(".deleteIdentity()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet, bobWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .deleteIdentity(bobWallet.address)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });
  });

  describe(".registerIdentity()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .registerIdentity(
              ethers.constants.AddressZero,
              ethers.constants.AddressZero,
              0
            )
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });
  });

  describe(".setIdentityRegistryStorage()", () => {
    describe("when sender is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .setIdentityRegistryStorage(ethers.constants.AddressZero)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e"
        );
      });
    });

    describe("when sender is the owner", () => {
      it("should set the identity registry storage", async () => {
        const {
          suite: { identityRegistry },
          accounts: { deployer }
        } = await loadFixture(deployFullSuiteFixture);

        const tx = await identityRegistry
          .connect(deployer)
          .setIdentityRegistryStorage(ethers.constants.AddressZero);
        await expect(tx)
          .to.emit(identityRegistry, "IdentityStorageSet")
          .withArgs(ethers.constants.AddressZero);
        expect(await identityRegistry.identityStorage()).to.be.equal(
          ethers.constants.AddressZero
        );
      });
    });
  });

  describe(".setClaimTopicsRegistry()", () => {
    describe("when sender is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .setClaimTopicsRegistry(ethers.constants.AddressZero)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e"
        );
      });
    });

    describe("when sender is the owner", () => {
      it("should set the claim topics registry", async () => {
        const {
          suite: { identityRegistry },
          accounts: { deployer }
        } = await loadFixture(deployFullSuiteFixture);

        const tx = await identityRegistry
          .connect(deployer)
          .setClaimTopicsRegistry(ethers.constants.AddressZero);
        await expect(tx)
          .to.emit(identityRegistry, "ClaimTopicsRegistrySet")
          .withArgs(ethers.constants.AddressZero);
        expect(await identityRegistry.topicsRegistry()).to.be.equal(
          ethers.constants.AddressZero
        );
      });
    });
  });

  describe(".setClaimIssuersRegistry()", () => {
    describe("when sender is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { identityRegistry },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          identityRegistry
            .connect(anotherWallet)
            .setClaimIssuersRegistry(ethers.constants.AddressZero)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e"
        );
      });
    });

    describe("when sender is the owner", () => {
      it("should set the claimssuers registry", async () => {
        const {
          suite: { identityRegistry },
          accounts: { deployer }
        } = await loadFixture(deployFullSuiteFixture);

        const tx = await identityRegistry
          .connect(deployer)
          .setClaimIssuersRegistry(ethers.constants.AddressZero);
        await expect(tx)
          .to.emit(identityRegistry, "ClaimIssuersRegistrySet")
          .withArgs(ethers.constants.AddressZero);
        expect(await identityRegistry.issuersRegistry()).to.be.equal(
          ethers.constants.AddressZero
        );
      });
    });
  });

  describe(".isVerified()", () => {
    describe("when there are no require claim topics", () => {
      it("should return true when the identity is registered", async () => {
        const {
          suite: { identityRegistry, claimTopicsRegistry },
          accounts: { tokenAgent, charlieWallet },
          identities: { charlieIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        await identityRegistry
          .connect(tokenAgent)
          .registerIdentity(charlieWallet.address, charlieIdentity.address, 0);

        await expect(identityRegistry.isVerified(charlieWallet.address)).to
          .eventually.be.false;

        const topics = await claimTopicsRegistry.getClaimTopics();
        await Promise.all(
          topics.map((topic) => claimTopicsRegistry.removeClaimTopic(topic))
        );

        await expect(identityRegistry.isVerified(charlieWallet.address)).to
          .eventually.be.true;
      });
    });

    describe("when claim topics are required but there are not claimssuers for them", () => {
      it("should return false", async () => {
        const {
          suite: {
            identityRegistry,
            claimTopicsRegistry,
            claimIssuersRegistry
          },
          accounts: { aliceWallet }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.true;

        const topics = await claimTopicsRegistry.getClaimTopics();
        const claimIssuers =
          await claimIssuersRegistry.getClaimIssuersForClaimTopic(topics[0]);
        await Promise.all(
          claimIssuers.map((issuer) =>
            claimIssuersRegistry.removeClaimIssuer(issuer)
          )
        );

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.false;
      });
    });

    describe("when the only claim required was revoked", () => {
      it("should return false", async () => {
        const {
          suite: { identityRegistry, claimTopicsRegistry, claimIssuerContract },
          accounts: { aliceWallet },
          identities: { aliceIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.true;

        const topics = await claimTopicsRegistry.getClaimTopics();
        const claimIds = await aliceIdentity.getClaimIdsByTopic(topics[0]);
        const claim = await aliceIdentity.getClaim(claimIds[0]);

        await claimIssuerContract.revokeClaimBySignature(claim.signature);

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.false;
      });
    });

    describe("when the claim issuer throws an error", () => {
      it("should return true if there is another valid claim", async () => {
        const {
          suite: {
            identityRegistry,
            claimTopicsRegistry,
            claimIssuersRegistry,
            claimIssuerContract
          },
          accounts: { aliceWallet },
          identities: { aliceIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        const trickyClaimIssuer = await ethers.deployContract(
          "ClaimIssuerTrick"
        );
        const claimTopics = await claimTopicsRegistry.getClaimTopics();
        await claimIssuersRegistry.removeClaimIssuer(
          claimIssuerContract.address
        );
        await claimIssuersRegistry.addClaimIssuer(
          trickyClaimIssuer.address,
          claimTopics
        );
        await claimIssuersRegistry.addClaimIssuer(
          claimIssuerContract.address,
          claimTopics
        );
        const claimIds = await aliceIdentity.getClaimIdsByTopic(claimTopics[0]);
        const claim = await aliceIdentity.getClaim(claimIds[0]);
        await aliceIdentity.connect(aliceWallet).removeClaim(claimIds[0]);
        await aliceIdentity
          .connect(aliceWallet)
          .addClaim(
            claimTopics[0],
            1,
            trickyClaimIssuer.address,
            "0x00",
            "0x00",
            ""
          );
        await aliceIdentity
          .connect(aliceWallet)
          .addClaim(
            claim.topic,
            claim.scheme,
            claim.issuer,
            claim.signature,
            claim.data,
            claim.uri
          );

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.true;
      });

      it("should return false if there are no other valid claim", async () => {
        const {
          suite: {
            identityRegistry,
            claimTopicsRegistry,
            claimIssuersRegistry
          },
          accounts: { aliceWallet },
          identities: { aliceIdentity }
        } = await loadFixture(deployFullSuiteFixture);

        const trickyClaimIssuer = await ethers.deployContract(
          "ClaimIssuerTrick"
        );
        const claimTopics = await claimTopicsRegistry.getClaimTopics();
        await claimIssuersRegistry.addClaimIssuer(
          trickyClaimIssuer.address,
          claimTopics
        );

        const claimIds = await aliceIdentity.getClaimIdsByTopic(claimTopics[0]);
        await aliceIdentity.connect(aliceWallet).removeClaim(claimIds[0]);
        await aliceIdentity
          .connect(aliceWallet)
          .addClaim(
            claimTopics[0],
            1,
            trickyClaimIssuer.address,
            "0x00",
            "0x00",
            ""
          );

        await expect(identityRegistry.isVerified(aliceWallet.address)).to
          .eventually.be.false;
      });
    });
  });
});
