# AGENTS.md - API

- Repo-wide instructions live in `../AGENTS.md`; keep this file API-specific.
- Package manager is pnpm (`packageManager` pins `pnpm@10.32.1`), but `Dockerfile` currently uses npm.
- Use `pnpm install`, then `pnpm build` for TypeScript verification.
- `pnpm dev` runs `tsc-watch --onSuccess "cross-env NODE_ENV=dev node dist/index.js"`; it compiles to `dist/` before running.
- `pnpm prod` runs `cross-env NODE_ENV=prod node dist/index.js`; build first.
- `pnpm test` is a placeholder that exits 1; no test framework is configured.
- No ESLint config or lint script is checked in despite an ESLint dependency.
- `pnpm console-test` is not reliable right now: its target path under `src/api/v1/modules/clases/...` is absent.
- Runtime entrypoint is `src/index.ts`, which creates `Api` from `src/api.ts`; routes mount under `/api/v1` via `src/routes/index.routes.ts`.
- Environment is loaded with `dotenv-flow`; database config reads `PDB_HOST`, `PDB_PORT`, `PDB_USER`, `PDB_PASSWORD`, and `PDB_DATABASE`.
- Modules live under `src/api/v1/modules/<module>/` with `domain/`, `application/`, and the existing misspelled `infraestructure/` directory.
- Preserve existing misspellings in paths/imports unless doing an explicit rename: `infraestructure`, `catecories`, `exeptions`, `PostrgreSQL`, `PasswordBcript`.
- Controllers return `IResponseObject` (`code`, `message`, `body`) and Express routes set `res.status(responseObject.code).json(responseObject)`.
- PostgreSQL repositories call stored procedures in `users` and `financial` schemas; update `../madfinancial_database/initdb/madfinancial.sql` when API changes require DB shape/procedure changes.
