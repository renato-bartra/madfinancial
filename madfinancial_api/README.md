# MadFinancial API

HTTP API for the MadFinancial personal-finance app. Built with Node.js + TypeScript + Express, backed by PostgreSQL via the `postgres` driver and stored procedures.

## Table of contents

- [Overview](#overview)
- [Response envelope](#response-envelope)
- [Authentication](#authentication)
- [Error codes](#error-codes)
- [Shared data types](#shared-data-types)
- [Endpoint index](#endpoint-index)
- [Public endpoints](#public-endpoints)
  - [Create user](#post-apiv1users)
  - [Login](#post-apiv1userslogin)
  - [Refresh token](#post-apiv1usersrefresh)
  - [Reset password](#put-apiv1reset-password)
  - [Forgot password](#post-apiv1forgot-password)
  - [Verify token](#post-apiv1verify-token)
- [Private endpoints](#private-endpoints)
  - [List users](#get-apiv1users)
  - [Get user by id](#get-apiv1usersid)
  - [Update user](#put-apiv1usersid)
  - [Get user by email](#get-apiv1usersget-by-emailemail)
  - [List tags](#get-apiv1tags)
  - [Create tag](#post-apiv1tags)
  - [List categories](#get-apiv1categories)
  - [Create category](#post-apiv1categories)
  - [List accounts](#get-apiv1accounts)
  - [Create account](#post-apiv1accounts)
  - [Create movement](#post-apiv1movements)
  - [List movements by month](#get-apiv1movements)
  - [Update movement](#put-apiv1movementsmovement_id)
  - [Delete movement](#delete-apiv1movementsmovement_id)

---

## Overview

- **Base URL**: `http://localhost:4000/api/v1` (Android emulator: `http://10.0.2.2:4000/api/v1`)
- **Content type**: `application/json` for all requests and responses
- **Auth**: JWT in the `Authorization: Bearer <token>` header for all private routes
- **Date format**: `YYYY-MM-DD` (e.g. `2026-03-31`)

## Response envelope

Every endpoint returns the same envelope — `IResponseObject`:

```json
{
  "code": 200,
  "message": "Human-readable message",
  "body": { /* endpoint-specific payload */ }
}
```

- `code` — HTTP-style status code. Mirrors what `res.status(...)` will return.
- `message` — human-readable string. For login and refresh, this is the **JWT token**. For all other endpoints, it is a description.
- `body` — payload. Always a single domain entity (object) or a list of them. Defined in `<module>/domain/entities/`.

## Authentication

The login and refresh endpoints return a JWT in the `message` field of the envelope. Pass it on every private request as `Authorization: Bearer <token>`. The token's `tou` claim must include `"user"` to access private routes — this is enforced by `VerifyTokenMiddleware(["user"])`.

When the token is missing, expired, or invalid, the middleware returns a `401` (expired) or `403` (insufficient role or invalid) response with the standard envelope.

## Error codes

| `code` | Meaning |
| --- | --- |
| `200` | Success. |
| `400` | Validation error. `body` is `[]` for business validation, or a list of field errors for data validation. |
| `401` | Token expired. need to refresh token |
| `403` | Insufficient role, or invalid token. |
| `404` | Entity not found, or generic not-found (e.g. login with wrong credentials). `body` is `[]`. |
| `500` | Server error. `body` is `[]`. |

## Shared data types

All entities extend `Entity` (audit fields: `active`, `created_at`, `updated_at`, `deleted_at`). Audit fields are optional and may be `null`.

### `User`

```json
{
  "id": 2,
  "first_name": "Renato",
  "last_name": "Bartra Reategui",
  "dni": "71721506",
  "email": "rbr1994@hotmail.com",
  "image": ""
}
```

> **Note**: the login response uses `user_id` (not `id`) in the body. All other user endpoints use `id`.

### `MovementType`

```json
{
  "type_id": 2,
  "description": "Gasto"
}
```

### `Category`

```json
{
  "category_id": 3,
  "category_type": true,
  "description": "Supermercado"
}
```

`category_type` is `true` for expense categories and `false` for income categories.

### `Account`

```json
{
  "account_id": 1,
  "description": "Efectivo"
}
```

### `Tag`

```json
{
  "tag_id": 1,
  "description": "Carimi"
}
```

### `Submovement`

```json
{
  "submovement_id": 1,
  "description": "Shampoo Carimi",
  "amount": 40.00,
  "subcategory": {
    "category_id": 13,
    "category_type": true,
    "description": "Limpieza"
  },
  "tags": [
    { "tag_id": 2, "description": "Carimi" }
  ]
}
```

### `Movement`

```json
{
  "movement_id": 1,
  "user_id": 2,
  "title": "Compras semana",
  "description": "Compras semana en Plaza Vea",
  "amount": 100.00,
  "accounting_date": "2026-03-31",
  "type": { "type_id": 2, "description": "Gasto" },
  "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
  "account": { "account_id": 1, "description": "Efectivo" },
  "tags": [],
  "submovements": [
    {
      "submovement_id": 1,
      "description": "Shampoo Carimi",
      "amount": 40.00,
      "subcategory": { "category_id": 13, "category_type": true, "description": "Limpieza" },
      "tags": [{ "tag_id": 2, "description": "Carimi" }]
    }
  ]
}
```

> **Contract note**: `amount` is always a JSON number with two decimal places. `*_id` fields are always JSON numbers, never strings.

---

## Endpoint index

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/v1/users` | Public | Create a new user |
| `POST` | `/api/v1/users/login` | Public | Authenticate and obtain a JWT |
| `POST` | `/api/v1/users/refresh` | Public | Refresh an existing JWT |
| `PUT` | `/api/v1/reset-password` | Public | Reset password using a reset token |
| `POST` | `/api/v1/forgot-password` | Public | Request a password-reset email |
| `POST` | `/api/v1/verify-token` | Public | Verify that a JWT is valid for a given role |
| `GET` | `/api/v1/users` | Private | List all users |
| `GET` | `/api/v1/users/:id` | Private | Get a user by id |
| `PUT` | `/api/v1/users/:id` | Private | Update a user |
| `GET` | `/api/v1/users/get-by-email/:email` | Private | Get a user by email |
| `GET` | `/api/v1/tags` | Private | List tags for the user |
| `POST` | `/api/v1/tags` | Private | Create a tag |
| `GET` | `/api/v1/categories` | Private | List categories for the user |
| `POST` | `/api/v1/categories` | Private | Create a category |
| `GET` | `/api/v1/accounts` | Private | List accounts for the user |
| `POST` | `/api/v1/accounts` | Private | Create an account |
| `POST` | `/api/v1/movements` | Private | Create a movement (income or expense) |
| `GET` | `/api/v1/movements` | Private | List movements for a given month |
| `PUT` | `/api/v1/movements/:movement_id` | Private | Update a movement (replaces it; the API returns a new `movement_id`) |
| `DELETE` | `/api/v1/movements/:movement_id` | Private | Soft-delete a movement |

---

## Public endpoints

### `POST /api/v1/users`

Create a new user account.

**Auth**: not required.

**Request body**

```json
{
  "user_id": 0,
  "first_name": "Renato",
  "last_name": "Bartra Reategui",
  "dni": "71721506",
  "email": "rbr1994@hotmail.com",
  "password": "renato",
  "active": true,
  "image": ""
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "El Usuario se creó correctamente",
  "body": {
    "id": 2,
    "first_name": "Renato",
    "last_name": "Bartra Reategui",
    "dni": "71721506",
    "email": "rbr1994@hotmail.com",
    "image": ""
  }
}
```

`body` matches the `User` shape. `id` (not `user_id`) is used here. The `password` is never returned.

**Error responses**

- `400` — email already in use, or validation failure. `body: []` for duplicates; list of field errors for validation.
- `500` — server error.

---

### `POST /api/v1/users/login`

Authenticate with email and password, receive a JWT.

**Auth**: not required.

**Request body**

```json
{
  "email": "rbr1994@hotmail.com",
  "password": "renato"
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "body": {
    "user_id": 2,
    "first_name": "Renato",
    "last_name": "Bartra Reategui",
    "email": "rbr1994@hotmail.com",
    "dni": "71721506"
  }
}
```

- `message` is the **JWT token** (not a human-readable message). Pass it as `Authorization: Bearer <message>` on private requests.
- `body.user_id` is the numeric user id.

**Error responses**

- `404` — wrong email or password. `body: []`.
- `400` — token issue. `body: []`.
- `500` — server error.

---

### `POST /api/v1/users/refresh`

Refresh an existing JWT.

**Auth**: the existing token is passed in the `Authorization` header.

**Request body**

```json
{
  "email": "rbr1994@hotmail.com"
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "body": []
}
```

`message` is the new JWT token. `body` is always `[]` for this endpoint.

**Error responses**

- `400` — invalid or expired token. `body: []`.
- `500` — server error.

---

### `PUT /api/v1/reset-password`

Reset a password using a token delivered via the forgot-password flow.

**Auth**: not required (the token in the body is the credential).

**Request body**

```json
{
  "token": "<reset-token>",
  "password": "new-password",
  "confirm": "new-password"
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "La contraseña se cambió exitosamente",
  "body": []
}
```

**Error responses**

- `400` — token issue or password mismatch. `body: []`.
- `404` — token not associated with a user. `body: []`.
- `500` — server error.

---

### `POST /api/v1/forgot-password`

Request a password-reset email.

**Auth**: not required.

**Request body**

```json
{
  "email": "rbr1994@hotmail.com"
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "El email fue enviado con exito, por favor revise su bandeja de entrada",
  "body": []
}
```

**Error responses**

- `404` — email not in the database. `body: []`.
- `400` — token issue. `body: []`.
- `503` — SMTP failure. `body: []`.
- `500` — server error.

---

### `POST /api/v1/verify-token`

Verify that a JWT is valid for a given role.

**Auth**: not required (the token in the body is the credential).

**Request body**

```json
{
  "token": "<jwt>",
  "role": "user"
}
```

**Response (200)**

When the token is valid and carries the requested role, the response is the bare boolean `true` (not an envelope):

```
true
```

When the token is invalid, the standard envelope is returned:

```json
{
  "code": 403,
  "message": "Usted no tiene los permisos requeridos para ver esta información",
  "body": []
}
```

**Error responses**

- `401` — token expired.
- `403` — invalid token or insufficient role.
- `500` — server error.

---

## Private endpoints

All private endpoints require:

```
Authorization: Bearer <jwt>
```

The token's `tou` claim must include `"user"`. A missing, expired, or wrong-role token returns `401`/`403` from the middleware before the route handler runs.

### `GET /api/v1/users`

List all users.

**Auth**: required.

**Path parameters**: none.

**Request body**: none.

**Response (200)**

```json
{
  "code": 200,
  "message": "un gran poder conlleva una gran responsabilidad",
  "body": [
    {
      "id": 1,
      "first_name": "Renato",
      "last_name": "Bartra Reategui",
      "dni": "71721506",
      "email": "rbr1994@hotmail.com",
      "image": ""
    }
  ]
}
```

`body` is a list of `User` objects (without `password`).

**Error responses**

- `500` — server error. `body: []`.

---

### `GET /api/v1/users/:id`

Get a user by id.

**Auth**: required.

**Path parameters**

| Name | Type | Description |
| --- | --- | --- |
| `id` | integer | User id |

**Request body**: none.

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": {
    "id": 2,
    "first_name": "Renato",
    "last_name": "Bartra Reategui",
    "dni": "71721506",
    "email": "rbr1994@hotmail.com",
    "image": ""
  }
}
```

**Error responses**

- `404` — user not found. `body: []`.
- `500` — server error.

---

### `PUT /api/v1/users/:id`

Update a user. Sends the full user object; fields not in the payload are overwritten.

**Auth**: required.

**Path parameters**

| Name | Type | Description |
| --- | --- | --- |
| `id` | integer | User id |

**Request body**

```json
{
  "user_id": 2,
  "first_name": "Renato",
  "last_name": "Bartra Reategui",
  "dni": "71721506",
  "email": "rbr1994@hotmail.com",
  "password": "renato",
  "active": true,
  "image": ""
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "El usuario se actualizó correctamente",
  "body": {
    "id": 2,
    "first_name": "Renato",
    "last_name": "Bartra Reategui",
    "dni": "71721506",
    "email": "rbr1994@hotmail.com",
    "image": ""
  }
}
```

**Error responses**

- `400` — validation failure. `body` is a list of field errors.
- `404` — user not found. `body: []`.
- `500` — server error.

---

### `GET /api/v1/users/get-by-email/:email`

Get a user by email. The email is passed in the URL — make sure to URL-encode the `@` and `.` characters.

**Auth**: required.

**Path parameters**

| Name | Type | Description |
| --- | --- | --- |
| `email` | string | Email address (URL-encoded) |

**Request body**: none.

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": {
    "id": 2,
    "first_name": "Renato",
    "last_name": "Bartra Reategui",
    "dni": "71721506",
    "email": "rbr1994@hotmail.com",
    "image": ""
  }
}
```

**Error responses**

- `404` — user not found. `body: []`.
- `500` — server error.

---

### `GET /api/v1/tags`

List tags for the user. Despite using `GET`, this endpoint reads the user id from the request body.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "un gran poder conlleva una gran responsabilidad",
  "body": [
    { "tag_id": 1, "description": "Carimi" }
  ]
}
```

`body` is a list of `Tag` objects.

**Error responses**

- `404` — user has no tags. `body: []`.
- `500` — server error. `body: []`.

---

### `POST /api/v1/tags`

Create a tag.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2,
  "tag_id": 0,
  "description": "Almuerzo"
}
```

`tag_id` in the request is a placeholder; the API assigns the real id and returns it in `body`.

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": {
    "tag_id": 4,
    "description": "Almuerzo"
  }
}
```

**Error responses**

- `400` — validation or DB failure. `body: []`.
- `500` — server error.

---

### `GET /api/v1/categories`

List categories for the user. Despite using `GET`, this endpoint reads the user id from the request body.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "un gran poder conlleva una gran responsabilidad",
  "body": [
    {
      "category_id": 3,
      "category_type": true,
      "description": "Supermercado"
    }
  ]
}
```

`body` is a list of `Category` objects.

**Error responses**

- `404` — user has no categories. `body: []`.
- `500` — server error. `body: []`.

---

### `POST /api/v1/categories`

Create a category.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2,
  "category_id": 0,
  "category_type": true,
  "description": "Transporte"
}
```

`category_id` in the request is a placeholder; the API assigns the real id and returns it in `body`. `category_type` is `true` for expense categories and `false` for income categories.

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": {
    "category_id": 6,
    "category_type": true,
    "description": "Transporte"
  }
}
```

**Error responses**

- `400` — validation or DB failure. `body: []`.
- `500` — server error.

---

### `GET /api/v1/accounts`

List accounts for the user. Despite using `GET`, this endpoint reads the user id from the request body.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "un gran poder conlleva una gran responsabilidad",
  "body": [
    { "account_id": 1, "description": "Efectivo" }
  ]
}
```

`body` is a list of `Account` objects.

**Error responses**

- `404` — user has no accounts. `body: []`.
- `500` — server error. `body: []`.

---

### `POST /api/v1/accounts`

Create an account.

**Auth**: required.

**Request body**

```json
{
  "user_id": 2,
  "account_id": 0,
  "description": "Efectivo"
}
```

`account_id` in the request is a placeholder; the API assigns the real id and returns it in `body`.

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": {
    "account_id": 1,
    "description": "Efectivo"
  }
}
```

**Error responses**

- `400` — validation or DB failure. `body: []`.
- `500` — server error.

---

### `POST /api/v1/movements`

Create a movement (income or expense). The user id is taken from the JWT `sub` claim, not from the request body — any `user_id` in the body is overwritten by the server.

**Auth**: required.

**Request body**

```json
{
  "movement_id": 0,
  "user_id": 0,
  "title": "Compras semana",
  "description": "Compras semana en Plaza Vea",
  "amount": 100.00,
  "accounting_date": "2026-03-31",
  "type": { "type_id": 2, "description": "Gasto" },
  "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
  "account": { "account_id": 1, "description": "Efectivo" },
  "tags": [],
  "submovements": [
    {
      "submovement_id": 0,
      "description": "Shampoo Carimi",
      "amount": 40.00,
      "subcategory": { "category_id": 13, "category_type": true, "description": "Limpieza" },
      "tags": [{ "tag_id": 2, "description": "Carimi" }]
    }
  ]
}
```

Use `type_id: 1` for income, `type_id: 2` for expense. The submovements' `amount` values must sum to the parent movement's `amount`, or the API returns `400`.

**Response (200)**

```json
{
  "code": 200,
  "message": "Movimiento creado correctamente",
  "body": {
    "movement_id": 24,
    "user_id": 2,
    "title": "Compras semana",
    "description": "Compras semana en Plaza Vea",
    "amount": 100.00,
    "accounting_date": "2026-03-31",
    "type": { "type_id": 2, "description": "Gasto" },
    "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
    "account": { "account_id": 1, "description": "Efectivo" },
    "tags": [],
    "submovements": [
      {
        "submovement_id": 1,
        "description": "Shampoo Carimi",
        "amount": 40.00,
        "subcategory": { "category_id": 13, "category_type": true, "description": "Limpieza" },
        "tags": [{ "tag_id": 2, "description": "Carimi" }]
      }
    ]
  }
}
```

**Error responses**

- `400` — data validation failure. `body` is a list of field errors.
- `400` — business validation failure (e.g. submovements sum != amount). `body: []`.
- `500` — server error.

---

### `GET /api/v1/movements`

List movements for the month that contains the given `accounting_date`. The user id is taken from the JWT `sub` claim.

**Auth**: required.

**Request body**

```json
{
  "accounting_date": "2026-03-31"
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "",
  "body": [
    {
      "movement_id": 1,
      "user_id": 2,
      "title": "Compras semana",
      "description": "Compras semana en Plaza Vea",
      "amount": 100.00,
      "accounting_date": "2026-03-15",
      "type": { "type_id": 2, "description": "Gasto" },
      "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
      "account": { "account_id": 1, "description": "Efectivo" },
      "tags": [],
      "submovements": []
    }
  ]
}
```

`body` is a list of `Movement` objects whose `accounting_date` falls in the same month as the request's `accounting_date`. Returns `[]` if no movements exist for that month.

**Error responses**

- `500` — server error. `body: []`.

---

### `PUT /api/v1/movements/:movement_id`

Update a movement. The API soft-deletes the existing movement by `:movement_id`, then inserts a new one with the payload's data and returns the new movement. The returned `movement_id` is **always different** from the path parameter.

**Auth**: required.

**Path parameters**

| Name | Type | Description |
| --- | --- | --- |
| `movement_id` | integer | The id of the movement to replace |

**Request body**

The full movement payload, same shape as `POST /api/v1/movements`:

```json
{
  "movement_id": 0,
  "user_id": 0,
  "title": "Compras semana",
  "description": "Compras semana en Plaza Vea",
  "amount": 120.00,
  "accounting_date": "2026-03-31",
  "type": { "type_id": 2, "description": "Gasto" },
  "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
  "account": { "account_id": 1, "description": "Efectivo" },
  "tags": [],
  "submovements": [
    {
      "submovement_id": 0,
      "description": "Shampoo Carimi",
      "amount": 40.00,
      "subcategory": { "category_id": 13, "category_type": true, "description": "Limpieza" },
      "tags": [{ "tag_id": 2, "description": "Carimi" }]
    }
  ]
}
```

**Response (200)**

```json
{
  "code": 200,
  "message": "Updated Movement",
  "body": {
    "movement_id": 25,
    "user_id": 2,
    "title": "Compras semana",
    "description": "Compras semana en Plaza Vea",
    "amount": 120.00,
    "accounting_date": "2026-03-31",
    "type": { "type_id": 2, "description": "Gasto" },
    "category": { "category_id": 3, "category_type": true, "description": "Supermercado" },
    "account": { "account_id": 1, "description": "Efectivo" },
    "tags": [],
    "submovements": [
      {
        "submovement_id": 1,
        "description": "Shampoo Carimi",
        "amount": 40.00,
        "subcategory": { "category_id": 13, "category_type": true, "description": "Limpieza" },
        "tags": [{ "tag_id": 2, "description": "Carimi" }]
      }
    ]
  }
}
```

**Error responses**

- `400` — data validation failure. `body` is a list of field errors.
- `400` — business validation failure (e.g. submovements sum != amount). `body: []`.
- `404` — the `:movement_id` does not exist. `body: []`.
- `500` — server error.

---

### `DELETE /api/v1/movements/:movement_id`

Soft-delete a movement (sets `active = false` and `deleted_at = now`).

**Auth**: required.

**Path parameters**

| Name | Type | Description |
| --- | --- | --- |
| `movement_id` | integer | The id of the movement to delete |

**Request body**: none.

**Response (200)**

```json
{
  "code": 200,
  "message": "Deleted Movement",
  "body": []
}
```

**Error responses**

- `404` — the `:movement_id` does not exist. `body: []`.
- `500` — server error.

---

### `POST /api/v1/upload_files`

Uploads a CSV file and imports movements into the user's account.

The CSV must contain the following columns in this exact order:

| Tipo | Categoria | Cuenta | Titulo | Monto | Descripcion | Fecha |
|------|-----------|---------|--------|-------|-------------|--------|

Example:

```csv
Tipo,Categoria,Cuenta,Titulo,Monto,Descripcion,Fecha
Gasto,Vehículo,Sueldo,Mantenimiento moto,76.78,Mantenimiento en Yamaha,2026-06-12
Ingreso,Sueldo,BCP,Sueldo Junio,3500.00,,2026-06-30
```

**Auth**: required.

**Content-Type**

```text
multipart/form-data
```

### Response (200)

```json
{
  "code": 200,
  "message": "El archivo se importó correctamente, por favor vuelva a ingresar a la app.",
  "body": []
}
```

### Error responses

#### 404 - Invalid request

No file was sent or the uploaded file is invalid.

```json
{
  "code": 404,
  "message": "Debe enviar un archivo CSV.",
  "body": []
}
```

#### 404 - Validation error

The CSV contains invalid values.

```json
{
  "code": 404,
  "message": "Los datos enviados no tienen el formato requerido",
  "body": [
    {
      "attribute": "Tipo",
      "message": "El tipo \"Compra\" no existe en la base de datos. Solo puedes usar Ingreso, Gasto o Transferencia."
    },
    {
      "attribute": "Categoría",
      "message": "Las siguientes categorías no existen en la base de datos: Viajes, Regalos"
    },
    {
      "attribute": "Cuenta",
      "message": "Las siguientes cuentas no existen en la base de datos: Banco XYZ"
    }
  ]
}
```

#### 401 - Unauthorized

The access token is missing, invalid or expired.

```json
{
  "code": 401,
  "message": "El token a expirado",
  "body": []
}
```

#### 500 - Internal server error

Unexpected server error.

```json
{
  "code": 500,
  "message": "Internal server error.",
  "body": []
}
```