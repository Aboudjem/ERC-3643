import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployFullSuiteFixture } from "../fixtures/deploy-full-suite.fixture";
import { AGENT_ROLE, OWNER_ROLE, accessControlRevert } from "../utils";

describe("Token - Information", () => {
  describe(".setOnchainID()", () => {
    describe("when the caller is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .setOnchainID(ethers.constants.AddressZero)
        ).to.be.revertedWith(accessControlRevert(anotherWallet, OWNER_ROLE));
      });
    });

    describe("when the caller is the owner", () => {
      it("should set the onchainID", async () => {
        const {
          suite: { token }
        } = await loadFixture(deployFullSuiteFixture);
        const tx = await token.setOnchainID(ethers.constants.AddressZero);
        await expect(tx)
          .to.emit(token, "UpdatedTokenInformation")
          .withArgs(
            await token.name(),
            await token.symbol(),
            await token.decimals(),
            await token.version(),
            ethers.constants.AddressZero
          );
        expect(await token.onchainID()).to.equal(ethers.constants.AddressZero);
      });
    });
  });

  describe(".setIdentityRegistry()", () => {
    describe("when the caller is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .setIdentityRegistry(ethers.constants.AddressZero)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e"
        );
      });
    });
  });

  describe(".totalSupply()", () => {
    it("should return the total supply", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet }
      } = await loadFixture(deployFullSuiteFixture);

      const balance = await token
        .balanceOf(aliceWallet.address)
        .then(async (b) => b.add(await token.balanceOf(bobWallet.address)));
      expect(await token.totalSupply()).to.equal(balance);
    });
  });

  describe(".setCompliance", () => {
    describe("when the caller is not the owner", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .setCompliance(ethers.constants.AddressZero)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e"
        );
      });
    });
  });

  describe(".pause()", () => {
    describe("when the caller is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(token.connect(anotherWallet).pause()).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });

    describe("when the caller is an agent", () => {
      describe("when the token is not paused", () => {
        it("should pause the token", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent }
          } = await loadFixture(deployFullSuiteFixture);
          const tx = await token.connect(tokenAgent).pause();
          await expect(tx)
            .to.emit(token, "Paused")
            .withArgs(tokenAgent.address);
          expect(await token.paused()).to.be.true;
        });
      });

      describe("when the token is paused", () => {
        it("should revert", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent }
          } = await loadFixture(deployFullSuiteFixture);
          await token.connect(tokenAgent).pause();
          await expect(token.connect(tokenAgent).pause()).to.be.revertedWith(
            "Pausable: paused"
          );
        });
      });
    });
  });

  describe(".unpause()", () => {
    describe("when the caller is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(token.connect(anotherWallet).unpause()).to.be.revertedWith(
          accessControlRevert(anotherWallet, AGENT_ROLE)
        );
      });
    });

    describe("when the caller is an agent", () => {
      describe("when the token is paused", () => {
        it("should unpause the token", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent }
          } = await loadFixture(deployFullSuiteFixture);
          await token.connect(tokenAgent).pause();
          const tx = await token.connect(tokenAgent).unpause();
          await expect(tx)
            .to.emit(token, "Unpaused")
            .withArgs(tokenAgent.address);
          expect(await token.paused()).to.be.false;
        });
      });

      describe("when the token is not paused", () => {
        it("should revert", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent }
          } = await loadFixture(deployFullSuiteFixture);
          await expect(token.connect(tokenAgent).unpause()).to.be.revertedWith(
            "Pausable: not paused"
          );
        });
      });
    });
  });

  describe(".setAddressFrozen", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .setAddressFrozen(anotherWallet.address, true)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });
  });

  describe(".freezePartialTokens", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .freezePartialTokens(anotherWallet.address, 1)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });

    describe("when sender is an agent", () => {
      describe("when amounts exceed current balance", () => {
        it("should revert", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent, anotherWallet }
          } = await loadFixture(deployFullSuiteFixture);
          await expect(
            token
              .connect(tokenAgent)
              .freezePartialTokens(anotherWallet.address, 1)
          ).to.be.revertedWith("Amount exceeds available balance");
        });
      });
    });
  });

  describe(".unfreezePartialTokens", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet }
        } = await loadFixture(deployFullSuiteFixture);
        await expect(
          token
            .connect(anotherWallet)
            .unfreezePartialTokens(anotherWallet.address, 1)
        ).to.be.revertedWith(
          "AccessControl: account 0xa0ee7a142d267c1f36714e4a8f75612f20a79720 is missing role 0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709"
        );
      });
    });

    describe("when sender is an agent", () => {
      describe("when amounts exceed current frozen balance", () => {
        it("should revert", async () => {
          const {
            suite: { token },
            accounts: { tokenAgent, anotherWallet }
          } = await loadFixture(deployFullSuiteFixture);
          await expect(
            token
              .connect(tokenAgent)
              .unfreezePartialTokens(anotherWallet.address, 1)
          ).to.be.revertedWith(
            "Amount should be less than or equal to frozen tokens"
          );
        });
      });
    });
  });
});
