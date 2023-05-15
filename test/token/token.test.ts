import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { deployFullSuiteFixture } from "../fixtures/deploy-full-suite.fixture";
import { AGENT_ROLE, OWNER_ROLE, accessControlRevert } from "../utils";
import { Signer, constants } from "ethers";

async function getZeroSigner(): Promise<Signer> {
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [constants.AddressZero],
  });

  await network.provider.send("hardhat_setBalance", [
    constants.AddressZero,
    "0xFFFFFFFFFFFFFFFFFFFFFFFF",
  ]);

  return ethers.provider.getSigner(constants.AddressZero);
}

describe("Token - Unit testing", () => {
  it("Should return the name of the token", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.name()).to.equal("ERC-3643");
  });

  it("Should return the symbol of the token", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.symbol()).to.equal("TREX");
  });

  it("Should return the decimals of the token", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.decimals()).to.equal(6);
  });

  it("Should return the compliance of the token", async () => {
    const {
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.compliance()).to.equal(basicCompliance.address);
  });

  it("Should return the identityRegistry of the token", async () => {
    const {
      suite: { token, identityRegistry },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.identityRegistry()).to.equal(identityRegistry.address);
  });

  it("Should return the version of the token", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);
    expect(await token.version()).to.equal("RAPTOR-5.0.0");
  });

  it("Should fail if _transfer is from zero address", async () => {
    const {
      suite: { token },
      accounts: { aliceWallet },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      token.connect(await getZeroSigner()).transfer(aliceWallet.address, 100)
    ).to.be.revertedWith("ERC-3643: transfer from zero address");
  });

  it("Should fail if _transfer is to zero address", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(token.transfer(constants.AddressZero, 100)).to.be.revertedWith(
      "ERC-3643: transfer to zero address"
    );
  });

  it("Should fail if _approve is from zero address", async () => {
    const {
      suite: { token },
      accounts: { aliceWallet },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      token.connect(await getZeroSigner()).approve(aliceWallet.address, 100)
    ).to.be.revertedWith("ERC-3643: approve from zero address");
  });

  it("Should fail if _approve is to zero address", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(token.approve(constants.AddressZero, 100)).to.be.revertedWith(
      "ERC-3643: approve to zero address"
    );
  });

  it("Should fail if _burn is from zero address", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(token.burn(constants.AddressZero, 100)).to.be.revertedWith(
      "ERC-3643: burn from the zero address"
    );
  });

  it("Should set new IdentityRegistry", async () => {
    const {
      suite: {
        token,
        claimTopicsRegistry,
        claimIssuersRegistry,
        identityRegistryStorage,
      },
    } = await loadFixture(deployFullSuiteFixture);

    const IdentityRegistry = await ethers.getContractFactory(
      "IdentityRegistry"
    );

    const identityRegistry = await IdentityRegistry.deploy(
      claimIssuersRegistry.address,
      claimTopicsRegistry.address,
      identityRegistryStorage.address
    );

    await token.setIdentityRegistry(identityRegistry.address);
  });

  it("Should fail to set new IdentityRegistry if caller is not Owner", async () => {
    const {
      suite: {
        token,
        claimTopicsRegistry,
        claimIssuersRegistry,
        identityRegistryStorage,
      },
      accounts: { anotherWallet },
    } = await loadFixture(deployFullSuiteFixture);

    const IdentityRegistry = await ethers.getContractFactory(
      "IdentityRegistry"
    );

    const identityRegistry = await IdentityRegistry.deploy(
      claimIssuersRegistry.address,
      claimTopicsRegistry.address,
      identityRegistryStorage.address
    );

    await expect(
      token.connect(anotherWallet).setIdentityRegistry(identityRegistry.address)
    ).to.be.revertedWith(accessControlRevert(anotherWallet, OWNER_ROLE));
  });

  it("Should set new Compliance", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);

    const Compliance = await ethers.getContractFactory("BasicCompliance");

    const compliance = await Compliance.deploy();

    await token.setCompliance(compliance.address);
  });

  it("Should fail to set new Compliance if caller is not Owner", async () => {
    const {
      suite: { token },
      accounts: { anotherWallet },
    } = await loadFixture(deployFullSuiteFixture);

    const Compliance = await ethers.getContractFactory("BasicCompliance");

    const compliance = await Compliance.deploy();

    await token.setCompliance(compliance.address);

    await expect(
      token.connect(anotherWallet).setIdentityRegistry(compliance.address)
    ).to.be.revertedWith(accessControlRevert(anotherWallet, OWNER_ROLE));
  });

  it("Should fail to set new Compliance if it is address zero", async () => {
    const {
      suite: { token },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(token.setCompliance(constants.AddressZero)).to.be.revertedWith(
      "ERC-3643: Invalid zero address"
    );
  });

  it("Should fail if unfreezing more than the frozen amount", async () => {
    const {
      suite: { token },
      accounts: { aliceWallet },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      token.unfreezePartialTokens(aliceWallet.address, 1000000000000)
    ).to.be.revertedWith(
      "Amount should be less than or equal to frozen tokens"
    );
  });

  it("Should unfreezing amount", async () => {
    const {
      suite: { token },
      accounts: { aliceWallet },
    } = await loadFixture(deployFullSuiteFixture);
    await token.freezePartialTokens(aliceWallet.address, 10);

    await token.unfreezePartialTokens(aliceWallet.address, 10);
  });

  describe("Batch", () => {
    it("Should batchTransfer", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      const aliceBalance = await token.balanceOf(aliceWallet.address);
      const bobBalance = await token.balanceOf(bobWallet.address);
      await token
        .connect(charlieWallet)
        .batchTransfer([aliceWallet.address, bobWallet.address], [100, 100]);
      expect(await token.balanceOf(aliceWallet.address)).to.be.equal(
        aliceBalance.add(100)
      );
      expect(await token.balanceOf(bobWallet.address)).to.be.equal(
        bobBalance.add(100)
      );
    });

    it("Should fail batchTransfer is paused", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      await token.pause();
      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await expect(
        token
          .connect(charlieWallet)
          .batchTransfer([aliceWallet.address, bobWallet.address], [100, 100])
      ).to.be.revertedWith("Pausable: paused");
    });

    it("Should batchTransferFrom", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);
      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);
      const aliceBalance = await token.balanceOf(aliceWallet.address);
      const bobBalance = await token.balanceOf(bobWallet.address);

      await token
        .connect(tokenAgent)
        .batchTransferFrom(
          [charlieWallet.address, charlieWallet.address],
          [aliceWallet.address, bobWallet.address],
          [100, 100]
        );
      expect(await token.balanceOf(aliceWallet.address)).to.be.equal(
        aliceBalance.add(100)
      );
      expect(await token.balanceOf(bobWallet.address)).to.be.equal(
        bobBalance.add(100)
      );
    });

    it("Should fail batchTransferFrom if paused", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);
      await token.pause();

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);
      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);

      await expect(
        token
          .connect(tokenAgent)
          .batchTransferFrom(
            [charlieWallet.address, charlieWallet.address],
            [aliceWallet.address, bobWallet.address],
            [100, 100]
          )
      ).to.be.revertedWith("Pausable: paused");
    });

    it("Should batchForcedTransfer", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      const aliceBalance = await token.balanceOf(aliceWallet.address);
      const bobBalance = await token.balanceOf(bobWallet.address);

      await token
        .connect(tokenAgent)
        .batchForcedTransfer(
          [charlieWallet.address, charlieWallet.address],
          [aliceWallet.address, bobWallet.address],
          [100, 100]
        );
      expect(await token.balanceOf(aliceWallet.address)).to.be.equal(
        aliceBalance.add(100)
      );
      expect(await token.balanceOf(bobWallet.address)).to.be.equal(
        bobBalance.add(100)
      );
    });

    it("Should fail batchForcedTransfer if amounts mismatches", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await expect(
        token
          .connect(tokenAgent)
          .batchForcedTransfer(
            [charlieWallet.address, charlieWallet.address],
            [aliceWallet.address, bobWallet.address],
            [100]
          )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchForcedTransfer if toList mismatches", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await expect(
        token
          .connect(tokenAgent)
          .batchForcedTransfer(
            [charlieWallet.address, charlieWallet.address],
            [aliceWallet.address],
            [100, 100]
          )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchForcedTransfer if amounts mismatches", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, charlieWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await expect(
        token
          .connect(anotherWallet)
          .batchForcedTransfer(
            [charlieWallet.address, charlieWallet.address],
            [aliceWallet.address, bobWallet.address],
            [100]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });

    it("Should fail batchTransferFrom if amounts mismatch", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);
      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);

      await expect(
        token
          .connect(tokenAgent)
          .batchTransferFrom(
            [charlieWallet.address, charlieWallet.address],
            [aliceWallet.address, bobWallet.address],
            [100]
          )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchTransferFrom if toList mismatch", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);
      await token.mint(charlieWallet.address, 1000000);

      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);
      await token.connect(charlieWallet).approve(tokenAgent.address, 10000);

      await expect(
        token
          .connect(tokenAgent)
          .batchTransferFrom(
            [charlieWallet.address, charlieWallet.address],
            [bobWallet.address],
            [100, 100]
          )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should batchMint", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      const charlieBalance = await token.balanceOf(charlieWallet.address);
      const aliceBalance = await token.balanceOf(aliceWallet.address);
      const bobBalance = await token.balanceOf(bobWallet.address);

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);

      await token.batchMint(
        [charlieWallet.address, aliceWallet.address, bobWallet.address],
        [100, 200, 300]
      );

      expect(await token.balanceOf(charlieWallet.address)).to.be.equal(
        charlieBalance.add(100)
      );
      expect(await token.balanceOf(aliceWallet.address)).to.be.equal(
        aliceBalance.add(200)
      );
      expect(await token.balanceOf(bobWallet.address)).to.be.equal(
        bobBalance.add(300)
      );
    });

    it("Should fail batchMint if array mismatches", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);

      await expect(
        token.batchMint(
          [charlieWallet.address, aliceWallet.address, bobWallet.address],
          [100, 300]
        )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchMint if not agent", async () => {
      const {
        suite: { token, claimTopicsRegistry },
        accounts: { aliceWallet, bobWallet, charlieWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await expect(
        token
          .connect(anotherWallet)
          .batchMint(
            [charlieWallet.address, aliceWallet.address, bobWallet.address],
            [100, 300]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });

    it("Should batchBurn", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);

      await token.batchMint(
        [charlieWallet.address, aliceWallet.address, bobWallet.address],
        [100, 200, 300]
      );

      const charlieBalance = await token.balanceOf(charlieWallet.address);
      const aliceBalance = await token.balanceOf(aliceWallet.address);
      const bobBalance = await token.balanceOf(bobWallet.address);

      await token.batchBurn(
        [charlieWallet.address, aliceWallet.address, bobWallet.address],
        [100, 200, 300]
      );

      expect(await token.balanceOf(charlieWallet.address)).to.be.equal(
        charlieBalance.sub(100)
      );
      expect(await token.balanceOf(aliceWallet.address)).to.be.equal(
        aliceBalance.sub(200)
      );
      expect(await token.balanceOf(bobWallet.address)).to.be.equal(
        bobBalance.sub(300)
      );
    });

    it("Should fail batchBurn if array mismatches", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, tokenAgent, charlieWallet },
        identities: { charlieIdentity },
      } = await loadFixture(deployFullSuiteFixture);

      const claimTopics = [ethers.utils.id("CLAIM_TOPIC")];

      await claimTopicsRegistry.removeClaimTopic(claimTopics[0]);

      await identityRegistry
        .connect(tokenAgent)
        .registerIdentity(charlieWallet.address, charlieIdentity.address, 10);

      await token.batchMint(
        [charlieWallet.address, aliceWallet.address, bobWallet.address],
        [100, 200, 300]
      );

      await expect(
        token.batchBurn(
          [charlieWallet.address, aliceWallet.address, bobWallet.address],
          [100]
        )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchBurn if not agent", async () => {
      const {
        suite: { token, claimTopicsRegistry, identityRegistry },
        accounts: { aliceWallet, bobWallet, charlieWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await expect(
        token
          .connect(anotherWallet)
          .batchBurn(
            [charlieWallet.address, aliceWallet.address, bobWallet.address],
            [100, 200, 300]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });

    it("Should batchSetAddressFrozen", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, charlieWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await token.batchSetAddressFrozen(
        [charlieWallet.address, aliceWallet.address, bobWallet.address],
        [true, true, false]
      );

      expect(await token.isFrozen(charlieWallet.address)).to.be.equal(true);
      expect(await token.isFrozen(aliceWallet.address)).to.be.equal(true);
      expect(await token.isFrozen(bobWallet.address)).to.be.equal(false);
    });

    it("Should fail batchSetAddressFrozen if array mismatches", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, charlieWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await expect(
        token.batchSetAddressFrozen(
          [charlieWallet.address, aliceWallet.address, bobWallet.address],
          [true, false]
        )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchSetAddressFrozen if not agent", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, charlieWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await expect(
        token
          .connect(anotherWallet)
          .batchSetAddressFrozen(
            [charlieWallet.address, aliceWallet.address, bobWallet.address],
            [true, true, false]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });

    it("Should batchFreezePartialTokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await token.batchFreezePartialTokens(
        [aliceWallet.address, bobWallet.address],
        [20, 30]
      );

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(20);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(30);
    });

    it("Should batchFreezePartialTokens if array mismatches", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await expect(
        token.batchFreezePartialTokens(
          [aliceWallet.address, bobWallet.address],
          [30]
        )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchFreezePartialTokens if not agent", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await expect(
        token
          .connect(anotherWallet)
          .batchFreezePartialTokens(
            [aliceWallet.address, bobWallet.address],
            [20, 30]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });

    it("Should batchUnfreezePartialTokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await token.batchFreezePartialTokens(
        [aliceWallet.address, bobWallet.address],
        [20, 30]
      );

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(20);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(30);

      await token.batchUnfreezePartialTokens(
        [aliceWallet.address, bobWallet.address],
        [10, 10]
      );

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(10);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(20);
    });

    it("Should batchUnfreezePartialTokens if array mismatches", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await token.batchFreezePartialTokens(
        [aliceWallet.address, bobWallet.address],
        [20, 30]
      );

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(20);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(30);

      await expect(
        token.batchUnfreezePartialTokens(
          [aliceWallet.address, bobWallet.address],
          [10]
        )
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });

    it("Should fail batchUnfreezePartialTokens if not agent", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(0);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(0);

      await token.batchFreezePartialTokens(
        [aliceWallet.address, bobWallet.address],
        [20, 30]
      );

      expect(await token.getFrozenTokens(aliceWallet.address)).to.be.equal(20);
      expect(await token.getFrozenTokens(bobWallet.address)).to.be.equal(30);

      await expect(
        token
          .connect(anotherWallet)
          .batchUnfreezePartialTokens(
            [aliceWallet.address, bobWallet.address],
            [10, 10]
          )
      ).to.be.revertedWith(accessControlRevert(anotherWallet, AGENT_ROLE));
    });
  });
});
