/**
 * ERC-3643 Raptor — published contract artifacts.
 *
 * This module re-exports the ABI and bytecode of every deployable contract in
 * this repository. After `npm run build`, consumers can import them as:
 *
 *   const { contracts, interfaces } = require("erc-3643");
 *   console.log(contracts.Token.abi);
 */

"use strict";

function safeRequire(path) {
  try {
    // eslint-disable-next-line global-require, import/no-dynamic-require
    return require(path);
  } catch (_) {
    return undefined;
  }
}

// Core token
const Token = safeRequire("./artifacts/contracts/token/Token.sol/Token.json");
const IToken = safeRequire("./artifacts/contracts/token/IToken.sol/IToken.json");

// Registries
const IdentityRegistry = safeRequire(
  "./artifacts/contracts/registry/IdentityRegistry.sol/IdentityRegistry.json",
);
const IIdentityRegistry = safeRequire(
  "./artifacts/contracts/registry/interface/IIdentityRegistry.sol/IIdentityRegistry.json",
);
const IdentityRegistryStorage = safeRequire(
  "./artifacts/contracts/registry/IdentityRegistryStorage.sol/IdentityRegistryStorage.json",
);
const IIdentityRegistryStorage = safeRequire(
  "./artifacts/contracts/registry/interface/IIdentityRegistryStorage.sol/IIdentityRegistryStorage.json",
);
const ClaimTopicsRegistry = safeRequire(
  "./artifacts/contracts/registry/ClaimTopicsRegistry.sol/ClaimTopicsRegistry.json",
);
const IClaimTopicsRegistry = safeRequire(
  "./artifacts/contracts/registry/interface/IClaimTopicsRegistry.sol/IClaimTopicsRegistry.json",
);
const ClaimIssuersRegistry = safeRequire(
  "./artifacts/contracts/registry/ClaimIssuersRegistry.sol/ClaimIssuersRegistry.json",
);
const IClaimIssuersRegistry = safeRequire(
  "./artifacts/contracts/registry/interface/IClaimIssuersRegistry.sol/IClaimIssuersRegistry.json",
);

// Compliance
const BasicCompliance = safeRequire(
  "./artifacts/contracts/compliance/BasicCompliance.sol/BasicCompliance.json",
);
const ICompliance = safeRequire(
  "./artifacts/contracts/compliance/interface/ICompliance.sol/ICompliance.json",
);

module.exports = {
  contracts: {
    Token,
    IdentityRegistry,
    IdentityRegistryStorage,
    ClaimTopicsRegistry,
    ClaimIssuersRegistry,
    BasicCompliance,
  },
  interfaces: {
    IToken,
    IIdentityRegistry,
    IIdentityRegistryStorage,
    IClaimTopicsRegistry,
    IClaimIssuersRegistry,
    ICompliance,
  },
};
