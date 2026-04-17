# Contributing to ERC-3643 Raptor

Thanks for your interest in improving ERC-3643 Raptor 🦖. This repo is small on purpose — a clean, educational take on the [ERC-3643 permissioned token standard](https://eips.ethereum.org/EIPS/eip-3643). Contributions that keep it simple, correct, and well-documented are very welcome.

## Quick start

```bash
git clone https://github.com/Aboudjem/ERC-3643.git
cd ERC-3643
npm install
npm test
```

## Ways to contribute

- 🐛 **Bugs** — open an issue with a failing test or minimal repro.
- 📝 **Docs** — typo fixes, clearer explanations, new diagrams.
- 🧪 **Tests** — increase branch coverage on existing contracts.
- ⚡ **Gas optimization** — must include a benchmark before/after.
- 🛡️ **Security** — see [SECURITY.md](./SECURITY.md). Do not open public issues for vulnerabilities.
- 🧩 **Compliance modules** — new modules implementing `ICompliance`.

## Workflow

1. Fork and clone.
2. `git checkout -b feat/<topic>` from `main`.
3. Run `npm test` before you start (baseline). Run it again before committing.
4. Commit using [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat: add conditional transfer compliance module`
   - `fix(token): zero-address guard on setIdentityRegistry`
   - `test(registry): cover claim verification edge cases`
   - `docs: clarify role matrix in ARCHITECTURE.md`
5. Open a PR with:
   - Clear description of what changed and why.
   - Linked issue if any.
   - Gas report delta if you touched hot paths.
   - Test evidence (copy/paste of `npm test` output or a screenshot).

## Style

- **Solidity**: `0.8.17` pinned, NatSpec on every external/public function, revert strings prefixed `"ERC-3643: "`.
- **TypeScript / JS**: ESLint + Prettier enforced. Run `npm run lint:fix`.
- **Markdown**: Prettier handles formatting via `npm run lint:fix`.

## Pre-submit checklist

- [ ] `npm run build` — clean compile
- [ ] `npm test` — all tests pass
- [ ] `npm run coverage` — no regression
- [ ] `npm run lint` — no errors
- [ ] `CHANGELOG.md` updated under `## [Unreleased]`
- [ ] NatSpec added for any new external/public function
- [ ] New invariant or role? Update `docs/ARCHITECTURE.md` and `SECURITY.md`

## AI / LLM contributions

AI-assisted PRs are welcome, but **you** are responsible for every line. Read [`AGENTS.md`](./AGENTS.md) first — it's the canonical guide for AI agents and will save you review cycles.

## License

By submitting a PR you agree that your contribution is licensed under [GPL-3.0](./LICENSE.md), consistent with the rest of the project.

## Code of Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).
