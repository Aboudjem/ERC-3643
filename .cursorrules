# Cursor Rules — ERC-3643 Raptor

You are contributing to an educational ERC-3643 (T-REX) permissioned token implementation.

## Read First
- `AGENTS.md` — canonical agent guide
- `CLAUDE.md` — Claude-specific instructions
- `docs/ARCHITECTURE.md` — system design
- `SECURITY.md` — threat model

## Golden Rules
- Solidity 0.8.17, pinned.
- Every external state change MUST emit an event.
- Every `address` parameter stored to state MUST be zero-checked.
- Revert strings are prefixed `"ERC-3643: "`.
- Role-gate every privileged function using `onlyRole(AGENT_ROLE)` or `onlyRole(OWNER_ROLE)`.
- User transfers MUST respect `whenNotPaused`.
- Preserve NatSpec on every external/public function.

## Before Commit
- `npm run build && npm test && npm run lint`
- Update `CHANGELOG.md` under `## [Unreleased]`
- Reference the ERC-3643 spec section or T-REX commit when applicable.

## Never
- Never reintroduce `Ownable` on registries that use `AccessControl`.
- Never remove `whenNotPaused` from user-facing transfers.
- Never use `tx.origin` for authorization.
- Never introduce upgradeable proxies without explicit human approval.
- Never commit secrets, `.env`, or private keys.
