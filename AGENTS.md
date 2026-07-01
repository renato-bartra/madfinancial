# AGENTS.md

## Repo Shape
- This is not a single workspace package: work from `madfinancial_app/` for Flutter and `madfinancial_api/` for Node/TypeScript.
- `madfinancial_database/initdb/madfinancial.sql` seeds the Docker Postgres container via `/docker-entrypoint-initdb.d`.
- There is no CI, root manifest, task runner, pre-commit config, or root lint/test command checked in.

## Root / Docker
- From the repo root, `docker compose up --build` builds `madfinancial_api/Dockerfile`, starts the API on host port `4000`, and maps Postgres to host port `5433`.
- Do not put credentials in instructions or code; root `.env` and `madfinancial_api/.env` are local runtime inputs for Docker/API.

## API: `madfinancial_api/`
- Package manager is pnpm (`packageManager` pins `pnpm@10.32.1`), but the Dockerfile currently uses npm.
- Use `pnpm install`, then `pnpm build` for TypeScript verification.
- `pnpm dev` runs `tsc-watch --onSuccess "cross-env NODE_ENV=dev node dist/index.js"`; it compiles to `dist/` before running.
- `pnpm prod` runs `cross-env NODE_ENV=prod node dist/index.js`; build first.
- `pnpm test` is a placeholder that exits 1; no test framework is configured.
- No ESLint config or lint script is checked in despite an ESLint dependency.
- `pnpm console-test` is not reliable right now: its target path under `src/api/v1/modules/clases/...` is absent.

## API Architecture
- Runtime entrypoint is `src/index.ts`, which creates `Api` from `src/api.ts`; routes mount under `/api/v1` via `src/routes/index.routes.ts`.
- Environment is loaded with `dotenv-flow`; database config reads `PDB_HOST`, `PDB_PORT`, `PDB_USER`, `PDB_PASSWORD`, and `PDB_DATABASE`.
- Modules live under `src/api/v1/modules/<module>/` with `domain/`, `application/`, and the existing misspelled `infraestructure/` directory.
- Preserve existing misspellings in paths/imports unless doing an explicit rename: `infraestructure`, `catecories`, `exeptions`, `PostrgreSQL`, `PasswordBcript`.
- Controllers return `IResponseObject` (`code`, `message`, `body`) and Express routes set `res.status(responseObject.code).json(responseObject)`.
- PostgreSQL repositories call stored procedures in `users` and `financial` schemas; update `madfinancial_database/initdb/madfinancial.sql` when API changes require DB shape/procedure changes.

## Flutter App: `madfinancial_app/`
- Flutter SDK constraint is Dart `^3.11.4`; dependencies are Riverpod 3, Dio, sqflite, intl, and flutter_lints.
- Use `flutter pub get`, then `flutter analyze` for the normal app verification.
- There is currently no `test/` directory; do not imply `flutter test` coverage exists unless tests are added.
- App entrypoint is `lib/main.dart`; it wraps `MainApp` in `ProviderScope`, uses dark `AppTheme`, and routes `/splash`, `/register`, `/login`, `/home`.
- API base URL is hard-coded in `lib/core/constants/api_constants.dart`: Android emulator uses `http://10.0.2.2:4000/api/v1`, other platforms use `http://localhost:4000/api/v1`.
- Dio is provided by `lib/core/network/dio_client.dart`; it adds the saved token as the `authorization` header and clears the local session on 401/403.
- Local session storage uses sqflite in `lib/core/services/local_storage_service.dart`; schema version is controlled by `StorageConstants.databaseVersion`.
- Feature code follows domain/application/infrastructure/presentation layers under `lib/features/<feature>/`; add Riverpod providers in each feature's `application/providers/` file.
- Movements intentionally fall back to `dummy_movements.dart` when the API returns no data or errors; preserve that UX unless changing product behavior.
