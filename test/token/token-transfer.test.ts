import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployFullSuiteFixture } from "../fixtures/deploy-full-suite.fixture";
import { AGENT_ROLE, accessControlRevert } from "../utils";
import { constants } from "ethers";

describe("Token - Transfers", () => {
  describe(".approve()", () => {
    it("should approve a contract to spend a certain amount of tokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      const tx = await token
        .connect(aliceWallet)
        .approve(anotherWallet.address, 100);
      await expect(tx)
        .to.emit(token, "Approval")
        .withArgs(aliceWallet.address, anotherWallet.address, 100);

      await expect(
        token.allowance(aliceWallet.address, anotherWallet.address)
      ).to.eventually.equal(100);
    });
  });

  describe(".increaseAllowance()", () => {
    it("should increase the allowance of a contract to spend a certain amount of tokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await token.connect(aliceWallet).approve(anotherWallet.address, 100);

      const tx = await token
        .connect(aliceWallet)
        .increaseAllowance(anotherWallet.address, 100);
      await expect(tx)
        .to.emit(token, "Approval")
        .withArgs(aliceWallet.address, anotherWallet.address, 200);

      await expect(
        token.allowance(aliceWallet.address, anotherWallet.address)
      ).to.eventually.equal(200);
    });
  });

  describe(".decreaseAllowance()", () => {
    it("should decrease the allowance of a contract to spend a certain amount of tokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, anotherWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await token.connect(aliceWallet).approve(anotherWallet.address, 150);

      const tx = await token
        .connect(aliceWallet)
        .decreaseAllowance(anotherWallet.address, 100);
      await expect(tx)
        .to.emit(token, "Approval")
        .withArgs(aliceWallet.address, anotherWallet.address, 50);

      await expect(
        token.allowance(aliceWallet.address, anotherWallet.address)
      ).to.eventually.equal(50);
    });
  });

  describe(".transfer()", () => {
    describe("when the token is paused", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token.connect(tokenAgent).pause();

        await expect(
          token.connect(aliceWallet).transfer(bobWallet.address, 100)
        ).to.be.revertedWith("Pausable: paused");
      });
    });

    describe("when the recipient balance is frozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { tokenAgent, aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .setAddressFrozen(bobWallet.address, true);

        await expect(
          token.connect(aliceWallet).transfer(bobWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Wallet frozen");
      });
    });

    describe("when the sender balance is frozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { tokenAgent, aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .setAddressFrozen(aliceWallet.address, true);

        await expect(
          token.connect(aliceWallet).transfer(bobWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Wallet frozen");
      });
    });

    describe("when the sender has not enough balance", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);

        await expect(
          token
            .connect(aliceWallet)
            .transfer(bobWallet.address, balance.add(1000))
        ).to.be.revertedWith("ERC-3643: amount exceeds balance");
      });
    });

    describe("when the sender has not enough balance unfrozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);
        await token
          .connect(tokenAgent)
          .freezePartialTokens(aliceWallet.address, balance.sub(100));

        await expect(
          token.connect(aliceWallet).transfer(bobWallet.address, balance)
        ).to.be.revertedWith("ERC-3643: Freezed balance");
      });
    });

    describe("when the recipient identity is not verified", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, anotherWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token.connect(aliceWallet).transfer(anotherWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Unverified identity");
      });
    });

    describe("when the transfer is compliant", () => {
      it("should transfer tokens", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        const tx = await token
          .connect(aliceWallet)
          .transfer(bobWallet.address, 100);
        await expect(tx)
          .to.emit(token, "Transfer")
          .withArgs(aliceWallet.address, bobWallet.address, 100);
      });
    });
  });

  describe(".batchTransfer()", () => {
    it("should transfer tokens", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      const tx = await token
        .connect(aliceWallet)
        .batchTransfer([bobWallet.address, bobWallet.address], [100, 200]);
      await expect(tx)
        .to.emit(token, "Transfer")
        .withArgs(aliceWallet.address, bobWallet.address, 100);
      await expect(tx)
        .to.emit(token, "Transfer")
        .withArgs(aliceWallet.address, bobWallet.address, 200);
    });

    it("should failed if array size mismatches", async () => {
      const {
        suite: { token },
        accounts: { aliceWallet, bobWallet },
      } = await loadFixture(deployFullSuiteFixture);

      await expect(
        token
          .connect(aliceWallet)
          .batchTransfer([bobWallet.address], [200, 100, 100])
      ).to.be.revertedWith("ERC-3643: Array size mismatch");
    });
  });

  describe(".transferFrom()", () => {
    describe("when the token is paused", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token.connect(tokenAgent).pause();

        await expect(
          token
            .connect(aliceWallet)
            .transferFrom(aliceWallet.address, bobWallet.address, 100)
        ).to.be.revertedWith("Pausable: paused");
      });
    });

    describe("when sender address is frozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .setAddressFrozen(aliceWallet.address, true);

        await token.connect(aliceWallet).approve(bobWallet.address, 1000);

        await expect(
          token
            .connect(bobWallet)
            .transferFrom(aliceWallet.address, bobWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Wallet frozen");
      });
    });

    describe("when transfer more than allowance", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .setAddressFrozen(aliceWallet.address, true);

        await token.connect(aliceWallet).approve(bobWallet.address, 1);

        await expect(
          token
            .connect(bobWallet)
            .transferFrom(aliceWallet.address, bobWallet.address, 100)
        ).to.be.revertedWith("ERC3643: Insufficient allowance");
      });
    });

    describe("when allowance is uint max", () => {
      it("should transfer with max allowance", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(aliceWallet)
          .approve(bobWallet.address, constants.MaxUint256);

        await token
          .connect(bobWallet)
          .transferFrom(aliceWallet.address, bobWallet.address, 10);
      });
    });

    describe("when recipient address is frozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .setAddressFrozen(bobWallet.address, true);

        await token.connect(aliceWallet).approve(bobWallet.address, 100);

        await expect(
          token
            .connect(bobWallet)
            .transferFrom(aliceWallet.address, bobWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Wallet frozen");
      });
    });

    describe("when sender has not enough balance", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, charlieWallet },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);

        await token.connect(aliceWallet).approve(charlieWallet.address, 10000);

        await expect(
          token
            .connect(charlieWallet)
            .transferFrom(
              aliceWallet.address,
              charlieWallet.address,
              balance.add(1000)
            )
        ).to.be.revertedWith("ERC-3643: amount exceeds balance");
      });
    });

    describe("when sender has not enough balance unfrozen", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);
        await token
          .connect(tokenAgent)
          .freezePartialTokens(aliceWallet.address, balance.sub(100));

        token.connect(aliceWallet).approve(tokenAgent.address, 10000000000);

        await expect(
          token
            .connect(tokenAgent)
            .transferFrom(aliceWallet.address, bobWallet.address, balance)
        ).to.be.revertedWith("ERC-3643: Freezed balance");
      });
    });

    describe("when the recipient identity is not verified", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, anotherWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await token.connect(aliceWallet).approve(anotherWallet.address, 100);

        await expect(
          token
            .connect(anotherWallet)
            .transferFrom(aliceWallet.address, anotherWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Unverified identity");
      });
    });

    describe("when the transfer is compliant", () => {
      it("should transfer tokens and reduce allowance of transferred value", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, anotherWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await token.connect(aliceWallet).approve(anotherWallet.address, 100);

        const tx = await token
          .connect(anotherWallet)
          .transferFrom(aliceWallet.address, bobWallet.address, 100);
        await expect(tx)
          .to.emit(token, "Transfer")
          .withArgs(aliceWallet.address, bobWallet.address, 100);

        await expect(
          token.allowance(aliceWallet.address, anotherWallet.address)
        ).to.be.eventually.equal(0);
      });
    });
  });

  describe(".forcedTransfer()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token
            .connect(aliceWallet)
            .forcedTransfer(aliceWallet.address, bobWallet.address, 100)
        ).to.be.revertedWith(accessControlRevert(aliceWallet, AGENT_ROLE));
      });
    });

    describe("when source wallet has not enough balance", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);

        await expect(
          token
            .connect(tokenAgent)
            .forcedTransfer(
              aliceWallet.address,
              bobWallet.address,
              balance.add(1000)
            )
        ).to.be.revertedWith("ERC-3643: Sender low balance");
      });
    });

    describe("when recipient identity is not verified", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, anotherWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token
            .connect(tokenAgent)
            .forcedTransfer(aliceWallet.address, anotherWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Unverified identity");
      });
    });

    describe("when amount is greater than unfrozen balance", () => {
      it("should unfroze tokens", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);
        await token
          .connect(tokenAgent)
          .freezePartialTokens(aliceWallet.address, balance.sub(100));

        const tx = await token
          .connect(tokenAgent)
          .forcedTransfer(
            aliceWallet.address,
            bobWallet.address,
            balance.sub(50)
          );
        await expect(tx)
          .to.emit(token, "Transfer")
          .withArgs(aliceWallet.address, bobWallet.address, balance.sub(50));
        await expect(tx)
          .to.emit(token, "TokensUnfrozen")
          .withArgs(aliceWallet.address, balance.sub(150));
        await expect(
          token.getFrozenTokens(aliceWallet.address)
        ).to.be.eventually.equal(50);
      });
    });
  });

  describe(".mint", () => {
    describe("when compliance return false", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet },
        } = await loadFixture(deployFullSuiteFixture);

        const FalseCompliance = await ethers.getContractFactory(
          "FalseCompliance"
        );

        const falseCompliance = await FalseCompliance.deploy();

        await token.setCompliance(falseCompliance.address);

        await expect(token.mint(aliceWallet.address, 100)).to.be.revertedWith(
          "ERC-3643: Compliance failure"
        );
      });
    });

    describe("when compliance return false", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        const FalseCompliance = await ethers.getContractFactory(
          "FalseCompliance"
        );

        const falseCompliance = await FalseCompliance.deploy();

        await token.setCompliance(falseCompliance.address);

        await expect(
          token.connect(bobWallet).transfer(aliceWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Compliance failure");
      });
    });

    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token.connect(aliceWallet).mint(aliceWallet.address, 100)
        ).to.be.revertedWith(accessControlRevert(aliceWallet, AGENT_ROLE));
      });
    });

    describe("when receiver is zero address", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(token.mint(constants.AddressZero, 100)).to.be.revertedWith(
          "ERC-3643: mint to zero address"
        );
      });
    });

    describe("when recipient identity is not verified", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { anotherWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token.connect(tokenAgent).mint(anotherWallet.address, 100)
        ).to.be.revertedWith("ERC-3643: Unverified identity");
      });
    });
  });

  describe(".burn()", () => {
    describe("when sender is not an agent", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await expect(
          token.connect(aliceWallet).burn(aliceWallet.address, 100)
        ).to.be.revertedWith(accessControlRevert(aliceWallet, AGENT_ROLE));
      });
    });

    describe("where the balance is more than the frozen amount", () => {
      it("should succeed", async () => {
        const {
          suite: { token },
          accounts: { tokenAgent, bobWallet },
        } = await loadFixture(deployFullSuiteFixture);

        await token
          .connect(tokenAgent)
          .freezePartialTokens(bobWallet.address, 70);

        await token.burn(bobWallet.address, 80);
      });
    });

    describe("when source wallet has not enough balance", () => {
      it("should revert", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);

        await expect(
          token.connect(tokenAgent).burn(aliceWallet.address, balance.add(1000))
        ).to.be.revertedWith("ERC-3643: burn exceeds balance");
      });
    });

    describe("when amount to burn is greater that unfrozen balance", () => {
      it("should burn and decrease frozen balance", async () => {
        const {
          suite: { token },
          accounts: { aliceWallet, tokenAgent },
        } = await loadFixture(deployFullSuiteFixture);

        const balance = await token.balanceOf(aliceWallet.address);
        await token
          .connect(tokenAgent)
          .freezePartialTokens(aliceWallet.address, balance.sub(100));

        const tx = await token
          .connect(tokenAgent)
          .burn(aliceWallet.address, balance.sub(50));
        await expect(tx)
          .to.emit(token, "Transfer")
          .withArgs(
            aliceWallet.address,
            ethers.constants.AddressZero,
            balance.sub(50)
          );
        await expect(tx)
          .to.emit(token, "TokensUnfrozen")
          .withArgs(aliceWallet.address, balance.sub(150));
        await expect(
          token.getFrozenTokens(aliceWallet.address)
        ).to.be.eventually.equal(50);
      });
    });
  });
});
