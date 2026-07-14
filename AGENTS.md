# AGENTS.md

## Repo Shape
- This is not a single workspace package: work from `madfinancial_app/` for Flutter and `madfinancial_api/` for Node/TypeScript.
- `madfinancial_database/initdb/madfinancial.sql` seeds the Docker Postgres container via `/docker-entrypoint-initdb.d`.
- There is no CI, root manifest, task runner, pre-commit config, or root lint/test command checked in.
- `madfinancial_api/AGENTS.md` contains API-specific notes; keep it in sync with this file.

## Root / Docker
- From the repo root, `docker compose up --build` builds `madfinancial_api/Dockerfile`, starts the API on host port `4000`, and maps Postgres to host port `5433`.
- Do not put credentials in instructions or code; root `.env` and `madfinancial_api/.env` are local runtime inputs for Docker/API.
- Docker uses the root `.env` (`PDB_HOST=postgres`), local dev uses `madfinancial_api/.env` (`PDB_HOST=localhost`).

## API: `madfinancial_api/`
- Package manager is pnpm (`packageManager` pins `pnpm@10.32.1`), but the Dockerfile uses npm. Use pnpm locally, npm is fine in Docker.
- Use `pnpm install`, then `pnpm build` for TypeScript verification.
- `pnpm dev` runs `tsc-watch --onSuccess "cross-env NODE_ENV=dev node dist/index.js"`; it compiles to `dist/` before running.
- `pnpm prod` runs `cross-env NODE_ENV=prod node dist/index.js`; build first.
- `pnpm test` is a placeholder that exits 1; no test framework is configured.
- No ESLint config or lint script is checked in despite an ESLint dependency.
- `pnpm console-test` is not reliable: its target path under `src/api/v1/modules/clases/...` is absent.
- Database driver is the `postgres` package. `mysql2` is listed in `package.json` but is a dead dependency — never use it.

## API Architecture
- Runtime entrypoint is `src/index.ts`, which creates `Api` from `src/api.ts`; routes mount under `/api/v1` via `src/routes/index.routes.ts`.
- Environment is loaded with `dotenv-flow`; database config reads `PDB_HOST`, `PDB_PORT`, `PDB_USER`, `PDB_PASSWORD`, and `PDB_DATABASE`.
- Modules live under `src/api/v1/modules/<module>/` with `domain/`, `application/`, and the existing misspelled `infraestructure/` directory.
- Preserve existing misspellings in paths/imports unless doing an explicit rename: `infraestructure`, `catecories`, `exeptions`, `PostrgreSQL`, `PasswordBcript`.
- Private routes mount `/api/v1/users`, `tags`, `categories`, `accounts`, `movements`. All require `VerifyTokenMiddleware(["user"])`.

## API Response Pattern
- `IResponseObject` (defined at `shared/domain/repositories/IResponseObject.ts`):
  - `code: number` — HTTP status (200, 400, 404, 500)
  - `message: string` — human-readable message
  - `body: object` — always a domain entity interface (or array of them) from `<module>/domain/entities/`
- Request flow: **Route** (extracts JWT, calls controller) → **Controller** (wires use case, builds IResponseObject) → **Use Case** (validates, calls repository, returns domain entity) → **Repository** (calls stored procedure, returns domain entity).
- Example: `POST /api/v1/movements` → `MovementController.create()` → `CreateMovementUseCase.create()` returns `Movement` (from `movements/domain/entities/Movement.ts`) → controller puts it in `body`, route sends `res.status(200).json({ code: 200, message: "...", body: <Movement> })`.
- Domain entities extend `Entity` (audit fields: `active`, `created_at`, `updated_at`, `deleted_at`): `User`, `Movement` (+ `MovementType`, `Submovement`), `Tag`, `Account`, `Category`.
- Standard exception → HTTP code mapping: `DataValidationException` → 400 (body: validation errors), `BusinessValidationException` → 400, `EntityNotFoundException` → 404, `DataBaseException` → 500, default → 500.
- PostgreSQL repositories call stored procedures in `users`, `financial`, and `shared` schemas; update `madfinancial_database/initdb/madfinancial.sql` when API changes require DB shape/procedure changes.

## Cross-cutting Rules

### R1. ID fields are integers in JSON
- All `*_id` fields (`user_id`, `movement_id`, `submovement_id`, `type_id`, `category_id`, `account_id`, `tag_id`) are returned by the API as JSON numbers, never as strings.
- DTOs and entities must declare these fields as `int` and parse with `(json['<field>'] as num).toInt()`.
- Do **not** use `int.tryParse`, string interpolation, or any defensive `is num ? ... : int.tryParse(...)` pattern. The API contract is the README (`madfinancial_api/README.md`); trust it.
- If the API ever returns a string for an ID, that is an API bug — fix the API, not the DTO.

### R2. Money fields are numbers with two decimals
- All monetary values (`amount` on `Movement`, `amount` on `Submovement`) are returned by the API as JSON numbers with two decimal places (e.g. `100.00`, `39.90`).
- DTOs and entities must declare these fields as `double` and parse with `(json['amount'] as num).toDouble()`.
- Do **not** read amounts from strings. The `postgres` driver sends numerics as JSON numbers — read them as such.
- Never store money as `int` (cents) in the app layer; the API contract is decimal.

### R3. The API README is the source of truth
- `madfinancial_api/README.md` documents every endpoint, its request/response shape, and example JSON.
- Frontend DTOs and entities must match the contract documented there.
- When the API changes: **update the README first, then the code, then the DTOs.** A DTO that diverges from the README is a bug.

## Flutter App: `madfinancial_app/`
- Flutter SDK constraint is Dart `^3.11.4`; this matches the current local Flutter 3.41.6 install.
- Dependencies: Riverpod 3, Dio, sqflite, intl, flutter_lints, flutter_expandable_fab, equatable, path, path_provider. No codegen (no build_runner, freezed, json_serializable).
- Use `flutter pub get`, then `flutter analyze` for verification. APK build is `flutter build apk --debug`.
- No `test/` directory exists; do not imply `flutter test` coverage unless tests are added.
- Analysis options only include `package:flutter_lints/flutter.yaml`; no custom rules.
- App entrypoint is `lib/main.dart`: wraps `MainApp` in `ProviderScope`, uses dark-only `AppTheme.dark` (Material 3, green `#43A047` primary), routes `/splash`, `/register`, `/login`, `/home`.
- Splash page routing: valid token → `/home`, no token but registered → `/login`, first-time → `/register`.
- API base URL is hard-coded in `lib/core/constants/api_constants.dart`: Android emulator uses `http://10.0.2.2:4000/api/v1`, other platforms use `http://localhost:4000/api/v1`.
- Dio is provided by `lib/core/network/dio_client.dart`; it adds the saved token as the `authorization` header and clears the local session on 401/403.
- Local session storage uses sqflite in `lib/core/services/local_storage_service.dart` (schema version 2, controlled by `StorageConstants.databaseVersion`). Schema is created in `_onCreate` and migrated in `_onUpgrade`; the v1→v2 migration adds the `movements`, `movement_tags`, `submovements`, `submovement_tags`, `categories`, and `tags` tables. Movements are queried/upserted via `lib/core/services/movement_local_dao.dart`.
- Only 2 features exist: `auth` (login/register) and `movements` (home/dashboard). Both follow domain/application/infrastructure/presentation layers.
- Add Riverpod providers in each feature's `application/providers/` file.
- Movements fall back to `dummy_movements.dart` only when the API errors out; an empty local+empty API shows an empty state on the home page. The controller (`MovementsController`) is the only place that reads/writes `state.movements`; `MonthSummaryHeader` and `DayGroupHeader` re-render automatically when it changes.
- `Account` is hard-coded to `id: 1, description: 'Efectivo'` in the form; account selection is a future feature.
