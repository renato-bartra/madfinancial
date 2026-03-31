# AGENTS.md - MadFinancial API

## Project Overview

This is a Node.js/TypeScript REST API built with Express.js using Clean Architecture. The project uses PostgreSQL as its database, Zod for validation, and follows a layered domain-driven design pattern.

## Code Style Guidelines

### Architecture

The project follows **Clean Architecture** with these layers:
- `domain/` - Entities, repository interfaces, domain services, exceptions
- `application/` - Use cases, controllers, in this case create only one index.ts for a controller and one for every use case (inside a folder with use case name)
- `infraestructure/` - Repository implementations, routes, adapters

### Directory Structure Pattern

```
modules/
├── users/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── services/
│   │   └── exceptions/
│   ├── application/
│   │   ├── controllers/
│   │   └── usecases/
│   └── infraestructure/
│       ├── routes/
│       ├── PostgreSQL/
│       └── Zod/
```

### TypeScript Conventions

- **Strict mode enabled** - No implicit `any`, strict null checks
- Use **interfaces** for entity definitions (e.g., `User extends Entity`)
- Use **type aliases** for utility types: `type UserID = Pick<User, 'user_id'>`
- Use **readonly modifiers** for class properties when appropriate
- Avoid `any` type - use proper generics or `unknown` with type guards

### Naming Conventions

| Element | Convention | Example | obasertations |
|---------|------------|---------|---------------|
| Files | kebab-case | `private.routes.ts` | `Only for routes in every module` |
| Files | PascalCase | `PostgreSQL.ts` | `Only for repositories and infraestructure files, except routes` |
| Files | no case | `index.ts` | `Only for controllers and use cases` |
| Classes | PascalCase | `UserController` |
| Interfaces | PascalCase with `I` prefix optional | `UserRepository` or `IUserRepository` |
| Methods | camelCase | `getAll`, `createUser` |
| Variables | camelCase | `userId`, `firstName` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Types/Interfaces | PascalCase | `User`, `IResponseObject` |
| Enums | PascalCase | `UserRole` |

### Import Conventions

1. External packages first
2. Internal modules (relative paths)
3. Use absolute paths from `src/` base

```typescript
// External
import { z, ZodError } from "zod";
import express, { Application } from "express";

// Internal - shared modules first
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";

// Then domain modules
import { User } from "../../domain/entities/User";
import { UserRepository } from "../../domain/repositories/UserRepository";
```

### Entity Definition Pattern

```typescript
// src/api/v1/modules/users/domain/entities/User.ts
import { Entity } from "../../../shared/domain/entities/Entity";

export interface User extends Entity {
  user_id: number;
  first_name: string;
  last_name: string | null;
  dni: string;
  email: string;
  password: string;
  image: string | null;
}

type Only<T, K extends keyof T> = Pick<T, K>;
export type UserID = Only<User, 'user_id'>;
```

### Repository Interface Pattern

```typescript
// src/api/v1/modules/users/domain/repositories/UserRepository.ts
import { DomainRepository } from "../../../shared/domain/repositories/DomainRepository";
import { User } from "../entities/User";

export interface UserRepository extends DomainRepository {
  getAll: () => Promise<User[] | string>;
  create: (user: User) => Promise<User | string>;
  getByEmail: (email: string) => Promise<User | string | null>;
  getById: (id: number) => Promise<User | string | null>;
  update: (id: number, user: User) => Promise<User | string | null>;
  delete: (id: number) => Promise<boolean | string>;
}
```

### Controller Pattern

Controllers return `IResponseObject`:
```typescript
interface IResponseObject {
  code: number;
  message: string;
  body: object;
}
```

### Use Case Pattern

```typescript
export class UserCreatorUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordManager: PasswordManager,
    private readonly validatorManager: ValidatorManager
  ) {}

  create = async (user: User): Promise<User> => {
    await this.validatorManager.validate(user);
    if (this.validatorManager.error()) {
      throw new DataValidationException(this.validatorManager.getErrors());
    }
    // ... implementation
  };
}
```

### Exception Handling

Custom exceptions extend `Error`:
```typescript
export class EntityNotFoundException extends Error {
  constructor() {
    super('Error: El registro no existe en la base de datos');
  }
}
```

### Route Definition Pattern

```typescript
export class UserPrivateRoutes {
  private readonly router: Router = Router();
  
  constructor() {
    this.initRoutes();
  }

  private initRoutes = (): void => {
    this.router.use(VerifyTokenMiddleware(['user']));
    this.router.get("/", async (req, res) => {
      // handler
    });
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
```

### Error Handling

- Use `instanceof` for type narrowing in catch blocks
- Return appropriate HTTP status codes in responses
- Never expose internal error details to clients in production

### Zod Validation

```typescript
const userSchema: z.ZodSchema<User> = z.strictObject({
  first_name: z.string().max(90),
  email: z.email(),
  // ...
});
```

### Configuration

- Environment variables via `dotenv-flow`
- Environment-specific configs in `src/api/v1/config/`
- Use `.env` for defaults, `.dev.env` for development

### Async/Await

- Always use `async/await` for asynchronous operations
- Handle errors with try/catch blocks
- Return Promises explicitly when needed

## Important Notes

1. **No test framework configured** - Tests would need to be set up (Jest/Vitest)
2. **No ESLint config** - Consider adding `eslint.config.js` for consistent linting
3. **Spanish comments** - Some existing code uses Spanish comments; English is preferred for new code
4. **CommonJS modules** - Using `module: commonjs` in tsconfig
5. **API responses** - Always use `IResponseObject` pattern for consistency
