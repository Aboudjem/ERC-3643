# AGENTS.md — AI Coding Agent Guide

> Canonical instructions for AI coding agents (Claude Code, Cursor, Codex, Aider, Continue, etc.) working in this repository. Read this before making any change.

## 1. Project Summary

**ERC-3643 Raptor** is an educational, gas-optimized implementation of the [ERC-3643 (T-REX) Permissioned Token Standard](https://eips.ethereum.org/EIPS/eip-3643) — the leading standard for regulated, onchain security tokens and Real World Asset (RWA) tokenization.

- **Not audited. Not for production.** Use [Tokeny's T-REX](https://github.com/TokenySolutions/T-REX) for production deployments.
- **Raptor** = Regulated Asset Platform for Tokenized Operations & Resources.
- Stack: Solidity `0.8.17+`, Hardhat, TypeScript, OpenZeppelin Contracts, ONCHAINID.

## 2. Architecture Map

```
contracts/
├── token/
│   ├── Token.sol              ERC-3643 compliant ERC-20 with transfer gating
│   └── IToken.sol             Token interface
├── registry/
│   ├── IdentityRegistry.sol          Binds wallets → ONCHAINID identities
│   ├── IdentityRegistryStorage.sol   Shared identity storage across multiple registries
│   ├── ClaimIssuersRegistry.sol      Whitelist of authorized claim issuers
│   ├── ClaimTopicsRegistry.sol       Required KYC/AML claim topics
│   └── interface/…                   Interfaces for all registries
├── compliance/
│   ├── BasicCompliance.sol    Pass-through compliance (always returns true)
│   └── interface/ICompliance.sol
└── _testContracts/            Mocks and malicious fixtures for tests only
```

**Transfer flow** (read this before editing `Token._transfer`):

1. `Token.transfer` → `_transfer(from, to, amount)`
2. Checks non-zero addresses, non-frozen wallets, free balance ≥ amount
3. Calls `_identityRegistry.isVerified(to)` — reverts if `to` lacks required claims
4. Calls `_compliance.canTransfer(from, to, amount)` — custom rule hook
5. Updates balances, emits `Transfer`
6. Calls `_compliance.transferred(from, to, amount)` — post-hook for accounting

## 3. Ground Rules

### ALWAYS

- **Read `README.md`, `docs/ARCHITECTURE.md`, and this file before proposing changes.**
- **Run the full test suite before and after any contract change:** `npm test`.
- **Run lint before committing:** `npm run lint`.
- **Preserve NatSpec** (`/// @notice`, `/// @param`) on every external/public function.
- **Emit an event** for every state change.
- **Check zero-address** on every function that stores an `address` parameter.
- **Reference ERC-3643** when adding or changing behavior — cite the section in commit messages.
- **Use `OWNER_ROLE` / `AGENT_ROLE`** — never reintroduce `Ownable` on registries that already use `AccessControl`.

### NEVER

- Never change the `_TOKEN_VERSION` constant without a CHANGELOG entry and a version bump in `package.json`.
- Never introduce upgradeable proxies — Raptor deliberately ships as non-upgradeable for clarity. Add them only if the user explicitly requests it.
- Never weaken role checks — `onlyRole(AGENT_ROLE)` is load-bearing.
- Never remove the `whenNotPaused` modifier from user-facing transfers.
- Never use `tx.origin` for authorization.
- Never use floating-point arithmetic or blockchain timestamps for financial logic.
- Never commit `.env`, `secrets`, mnemonics, or private keys.

## 4. Code Conventions

**Solidity:**

- Solidity `0.8.17` pinned. Use `unchecked { ++i; }` for loop counters after the require-bounds pattern already established.
- Constants are uppercase with keccak256 precomputed in comments above them.
- Private/internal state variables use leading underscore (`_name`, `_frozen`, `_identityRegistry`).
- Revert messages are `"ERC-3643: Reason"` — keep the prefix.
- Follow `@openzeppelin/contracts` patterns (Pausable, AccessControl, Context).

**TypeScript (tests):**

- `ethers@5` conventions — `.address`, `BigNumber`, `hardhat-network-helpers`.
- Fixtures in `test/fixtures/` — compose with `loadFixture()`.
- Each contract has its own test file. Prefer `describe` per function, `it` per scenario.

## 5. Verification Checklist (Definition of Done)

Before marking any task complete:

- [ ] `npm run build` — clean compile, no warnings
- [ ] `npm test` — all tests pass
- [ ] `npm run coverage` — no regression in line/branch coverage
- [ ] `npm run lint` — zero errors
- [ ] Gas report compared against `main` (reported in PR description if ≥ 5% delta)
- [ ] NatSpec complete on any new/changed external function
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] New security-relevant change: update `SECURITY.md` threat model if applicable

## 6. Task Patterns

**Adding a new compliance module:**

1. Extend `ICompliance`
2. Implement `bindToken`, `canTransfer`, `transferred`, `created`, `destroyed`
3. Write tests covering enforcement path AND bypass attempts (forced transfer, mint)
4. Update `docs/ARCHITECTURE.md` compliance section

**Modifying `Token._transfer`:**

1. Re-read all call sites (`transfer`, `transferFrom`, `_forcedTransfer`, `recoveryAddress`)
2. Confirm compliance hooks still fire with correct `from` (not `msg.sender`)
3. Add a regression test for your specific scenario
4. Check gas delta — `_transfer` runs on every transfer

**Adding a new role:**

1. Add `bytes32 public constant X_ROLE = <precomputed keccak256>;` with comment
2. Grant in constructor (or via an explicit grant function gated by default admin)
3. Document the capability boundaries in `AGENTS.md` §3 and `SECURITY.md`

## 7. External References

- [EIP-3643: T-REX — Official Spec](https://eips.ethereum.org/EIPS/eip-3643)
- [ERC-3643 Association](https://www.erc3643.org/)
- [Tokeny T-REX reference implementation](https://github.com/TokenySolutions/T-REX)
- [ONCHAINID](https://github.com/onchain-id/solidity) — onchain identity layer
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)

## 8. When You Are Stuck

1. Search the [T-REX reference repo](https://github.com/TokenySolutions/T-REX) for the original implementation.
2. Cross-check [EIP-3643 text](https://eips.ethereum.org/EIPS/eip-3643) — if behavior diverges, prefer the spec.
3. Open an issue using `.github/ISSUE_TEMPLATE/` rather than guessing.

---

_This file is the authoritative contract between humans and AI agents contributing to this repo. Keep it accurate._
