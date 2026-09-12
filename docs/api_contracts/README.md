# API Contract Reference

Captured endpoint contracts verified against the running backend
(`http://65.1.134.1/api/docs`, OpenAPI 3.1).

## OpenAPI specification (source of truth)

[`openapi.json`](./openapi.json) is the full machine-readable spec (50 paths,
34 schemas) dumped from `/api/openapi.json`. Use it to implement any endpoint:

- **Request bodies** → `components.schemas.<X>` (JSON schema field names, types,
  patterns, required flags, defaults, enums).
- **Query/path parameters** → each operation's `parameters` array.
- **Responses** → each operation's `responses` (note: most response bodies are
  declared as empty `{}` — capture the real shape with curl as shown below and
  store it here as a `.md` file).
- **Auth** → `securitySchemes.HTTPBearer` (Bearer token). Endpoints marked
  `HTTPBearer` in their `security` need the session access token (attached
  automatically by the `AuthInterceptor`).

## Captured endpoint contracts

Verify a captured contract against the Swagger docs before implementing/updating
code. Capture the real response shape with:

```sh
curl -X POST 'http://65.1.134.1/api/v1/auth/send-otp/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"phone": "9876543210", "purpose": "REGISTER"}'
```

- [auth/send-otp.md](./auth/send_otp.md) — `POST /api/v1/auth/send-otp/`

## How to add a contract

1. `curl` the endpoint (request url, body, params, and real response).
2. Create `docs/api_contracts/<module>/<endpoint>.md` recording url, method,
   request body, query/path params, success response, and error cases.
3. Link it in this README.
