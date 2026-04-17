# GitHub Copilot Instructions

This repository implements the **ERC-3643 (T-REX) permissioned token standard** in a simplified, educational form ("Raptor").

## Primary sources

- [`AGENTS.md`](../AGENTS.md) — canonical guide for all AI agents.
- [`CLAUDE.md`](../CLAUDE.md) — Claude-specific guidance.
- [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) — system design.
- [`SECURITY.md`](../SECURITY.md) — threat model.

## Style

- Solidity 0.8.17, pinned.
- NatSpec on every external/public function.
- Revert strings prefixed `"ERC-3643: "`.
- `bytes32` role constants are precomputed keccak256 values with an inline comment showing the source string.
- Private/internal state vars use `_leadingUnderscore`.

## Testing

- Hardhat + Mocha + Chai.
- Fixtures in `test/fixtures/`. Compose via `loadFixture`.
- A new external function MUST ship with at least one happy-path test and one revert-path test.

## Never

- Never suggest `tx.origin`.
- Never remove events from state-mutating functions.
- Never introduce upgradeable proxies.
- Never suggest committing `.env` or keys.
