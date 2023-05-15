import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { deployFullSuiteFixture } from "./fixtures/deploy-full-suite.fixture";

describe("basiCompliance", () => {
  it("should revert when calling as another account that the owner", async () => {
    const {
      accounts: { anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      basicCompliance.connect(anotherWallet).bindToken(token.address)
    ).to.be.revertedWith("ERC-3643: Caller not authorized");
  });

  it("should revert when not calling as the token", async () => {
    const {
      accounts: { anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    await basicCompliance.bindToken(token.address);

    await expect(
      basicCompliance.connect(anotherWallet).bindToken(token.address)
    ).to.be.revertedWith("ERC-3643: Caller not authorized");
  });

  it("should revert when binding address zero", async () => {
    const {
      accounts: { deployer, anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      basicCompliance
        .connect(anotherWallet)
        .bindToken(ethers.constants.AddressZero)
    ).to.be.revertedWith("ERC-3643: Caller not authorized");
  });

  it("should revert when unbinding with non Admin role", async () => {
    const {
      accounts: { deployer, anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      basicCompliance
        .connect(anotherWallet)
        .unbindToken(ethers.constants.AddressZero)
    ).to.be.revertedWith("ERC-3643: Caller not authorized");
  });

  it("should revert when unbinding non-bound token", async () => {
    const {
      accounts: { deployer, anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    await expect(
      basicCompliance.unbindToken(ethers.constants.AddressZero)
    ).to.be.revertedWith("ERC-3643: Token not bound");
  });

  it("should return if token is bound", async () => {
    const {
      accounts: { deployer, anotherWallet },
      suite: { token, basicCompliance },
    } = await loadFixture(deployFullSuiteFixture);

    expect(
      await basicCompliance.connect(anotherWallet).isTokenBound(token.address)
    ).to.be.equal(true);
  });
});
