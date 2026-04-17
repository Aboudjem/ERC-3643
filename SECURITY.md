# Security Policy

> **⚠️ This implementation is not audited and is not intended for production use.** For mainnet security token deployments, use the audited [Tokeny T-REX](https://github.com/TokenySolutions/T-REX) reference implementation and engage a professional audit firm.

## Supported Versions

| Version | Supported |
|---|---|
| Raptor `5.x` (`main`) | ✅ |
| `< 5.0` | ❌ |

## Reporting a Vulnerability

**Do not open a public issue for a security bug.**

Please email **[adam.boudjemaa@protonmail.com](mailto:adam.boudjemaa@protonmail.com)** (or open a [GitHub private security advisory](https://github.com/Aboudjem/ERC-3643/security/advisories/new)) with:

- A description of the issue and its impact.
- Steps to reproduce (a minimal PoC is strongly preferred).
- Suggested fix, if any.
- Your GitHub handle for credit (or request anonymity).

**Response targets:**

| Severity | Initial reply | Fix or mitigation |
|---|---|---|
| Critical | 24h | 7 days |
| High | 48h | 14 days |
| Medium / Low | 7 days | Next minor release |

## Threat Model

### In-scope (for bounty / advisory)

- **Unauthorized state change** — bypass of `AccessControl` role gating.
- **Compliance bypass** — transferring to an unverified wallet or against compliance rules.
- **Balance inflation** — mint without `AGENT_ROLE`, or double-spend via frozen-balance accounting.
- **Reentrancy** — via compliance modules or identity contracts called during `_transfer`.
- **Denial of service** — unbounded loops, griefing via claim issuer list, out-of-gas on batch operations.
- **Front-running / MEV** — privileged transactions where ordering matters (e.g., `recoveryAddress`).

### Out of scope

- Gas optimization suggestions that don't affect correctness.
- Typos / doc issues (please open a normal PR).
- Vulnerabilities in dependencies that are already disclosed upstream — report to the dependency instead.
- Theoretical issues without PoC.
- Issues only reproducible on unsupported Solidity versions (<0.8.17) or forks.

## Security Invariants

Contributors: **do not break these.** Every PR is checked against them.

1. **Total supply = sum of balances.** `totalSupply` mutates only via `_mint`/`_burn`.
2. **Frozen tokens ≤ balance.** `_frozenAmounts[a] <= _balances[a]` always.
3. **Verified recipient.** `_transfer` always checks `identityRegistry.isVerified(to)`.
4. **Compliance consent.** `_transfer` always checks `compliance.canTransfer(from, to, amount)` before moving tokens.
5. **Pause honored.** `transfer` / `transferFrom` / `batchTransfer` honor `whenNotPaused`. Forced / admin functions may bypass — but user wallets may not.
6. **Role-gated mutations.** Every state-mutating external function is either role-gated or whitelisted as public (pure reads, approvals).
7. **Zero-address guards.** Every function that stores an `address` to state checks it is non-zero.
8. **Events on state changes.** Every mutation emits an event. Offchain indexers depend on this.

## Known Caveats (Documented Acceptances)

- `forcedTransfer`, `batchForcedTransfer`, `recoveryAddress`, `mint`, `burn` intentionally bypass `whenNotPaused` so agents can act during incidents.
- `BasicCompliance.canTransfer` returns `true` unconditionally — replace it before production use.
- `recoveryAddress` requires the new wallet to be registered as a key purpose `1` on the lost investor's ONCHAINID. Key compromise on the ONCHAINID side compromises recovery.
- The `DEFAULT_ADMIN_ROLE` on each contract is granted to the deployer in the constructor. Transfer or renounce it before mainnet deployment.

## Secure Development Practices

- CI runs on every PR: lint, compile, tests, coverage, Slither static analysis.
- Dependencies tracked by Dependabot; security alerts enabled.
- Solidity version pinned.
- No secrets in the repository. `.env.example` documents required vars.
- Conventional Commits + signed commits recommended.

## Credits

Thanks to:

- The [Tokeny Solutions](https://github.com/TokenySolutions) team — authors of the original T-REX standard.
- Everyone who responsibly discloses issues here.
