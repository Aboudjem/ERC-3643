# CLAUDE.md — Claude Code Instructions

Claude Code, Claude in Cursor, and Claude via Anthropic API all read this file.

## Start Here

1. Read [`AGENTS.md`](./AGENTS.md) — it is the canonical agent guide and applies to you.
2. Read [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) before editing any contract.
3. Read [`SECURITY.md`](./SECURITY.md) before touching `Token.sol`, `IdentityRegistry.sol`, or `BasicCompliance.sol`.

## Repository Context

- **Language**: Solidity `0.8.17`, TypeScript (tests), JavaScript (deployment scripts).
- **Test framework**: Hardhat + Mocha + Chai.
- **Coverage tool**: `solidity-coverage` via `npm run coverage`.
- **Lint**: `solhint`, `prettier`, `eslint`. Run `npm run lint:fix` before committing.

## Preferred Workflow

1. `plan → test-first → implement → verify → commit` for any non-trivial change.
2. For a bug: write a failing test in `test/` first, then fix.
3. For a feature: update `AGENTS.md` §6 with the new task pattern.
4. Commit with Conventional Commits prefix (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `ci:`).

## Permission Hints

- **Never push to `main` directly.** Always open a PR from a feature branch.
- **Never force-push** a shared branch.
- **Never modify** `.github/workflows/` without explaining the security implication in the PR.
- **Feel free to create** topic branches, new docs, new tests, and scaffold files without asking.

## Model Routing Hints

- Architecture discussions → prefer Claude Opus.
- Single-file refactors → Claude Sonnet.
- Doc/lint/typo passes → Claude Haiku.

## Output Format

- Commit messages: one line subject ≤ 72 chars + blank line + paragraph body explaining _why_.
- PR descriptions: use the template in `.github/PULL_REQUEST_TEMPLATE.md`.
- Code comments: NatSpec only. Avoid inline tutorial comments — the goal is clarity, not a textbook.

## Escalation Triggers

Stop and ask the human before:

- Introducing proxy/upgradeability patterns.
- Migrating OpenZeppelin major version.
- Adding a new external dependency.
- Changing the license (`GPL-3.0`).
- Modifying `index.js` or `index.d.ts` published artifacts (affects npm consumers).
