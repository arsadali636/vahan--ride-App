# Send OTP

Endpoint for requesting a one-time password (OTP). Used by registration, login
and password reset flows before the phone is verified.

- Base URL: `http://65.1.134.1`
- Method: `POST`
- Path: `/api/v1/auth/send-otp/`
- Content-Type: `application/json`
- Auth: none (public endpoint)

## Request Body

Schema: `OTPRequest` (FastAPI) — both fields required.

```json
{
  "phone": "9876543210",
  "purpose": "REGISTER"
}
```

| Field     | Type   | Required | Validation                          | Values                              |
|-----------|--------|----------|-------------------------------------|-------------------------------------|
| `phone`   | string | yes      | Indian mobile pattern `^[6-9]\d{9}$` | 10-digit starting with 6-9         |
| `purpose` | string | yes      | `^(LOGIN\|REGISTER\|RESET_PASSWORD)$` | `LOGIN`, `REGISTER`, `RESET_PASSWORD` |

## Success Response

`200 OK`

```json
{
  "success": true,
  "message": "OTP generated (SMS disabled in dev mode)",
  "expires_in": 300,
  "otp": "335345"
}
```

| Field        | Type    | Notes                                                    |
|--------------|---------|----------------------------------------------------------|
| `success`    | boolean | always `true` on 200                                     |
| `message`    | string  | server-facing message                                     |
| `expires_in` | integer | OTP validity window in seconds (300 = 5 minutes)         |
| `otp`        | string  | **dev-only** — present while SMS is disabled; absent/`null` when SMS is enabled in production |

## Error Responses

| Status | Meaning                              | Body                                                          |
|--------|--------------------------------------|---------------------------------------------------------------|
| 422    | Validation error (e.g. bad phone)    | FastAPI `{detail: [{loc, msg, type}]}`                        |
| 429    | Too many OTP requests (if enabled)   | Backend detail string                                         |
| 5xx    | Server error                         | Backend detail string                                         |

## Notes

- Never store or display `otp` on the login/registration screens — it is a dev
  convenience only and must not be relied upon in production.
- `expires_in` is the countdown the verify-OTP screen should honor.
- The `otp` field must be modelled as nullable in the Dart model.
- Purpose enum must match the API strings exactly:
  `LOGIN`, `REGISTER`, `RESET_PASSWORD`.
