
# Wheelhouse API — v1

Base URL: `http://localhost:3000/api/v1`

The Wheelhouse API provides JSON documents for the shop's public service price list and its private accounting operations.

All API responses use JSON. The API does not use browser sessions or CSRF tokens.

## 1. Routes

| Method | Path | Bearer token | Status codes |
|---|---|---|---|
| GET | `/api/v1/services` | No | 200 |
| GET | `/api/v1/services/:id` | No | 200, 404 |
| POST | `/api/v1/services` | Yes | 201, 400, 401, 422 |
| GET | `/api/v1/repairs` | Yes | 200, 400, 401 |
| GET | `/api/v1/repairs/:id` | Yes | 200, 401, 404 |

## 2. Authentication

Private endpoints require an HTTP Bearer token in the `Authorization` header:

`Authorization: Bearer YOUR_API_TOKEN`

The token is stored in Rails encrypted credentials, not in the source code.

Public endpoints:
- `GET /api/v1/services`
- `GET /api/v1/services/:id`

Protected endpoints:
- `POST /api/v1/services`
- `GET /api/v1/repairs`
- `GET /api/v1/repairs/:id`

Requests without a valid token receive HTTP 401.

## 3. Service document

A service has the following JSON representation:

```json
{
  "id": 129,
  "name": "Bottom bracket service",
  "price": "22000.00",
  "charged_repairs_count": 1
}
```

Fields:

- `id`: Unique service identifier.
- `name`: Service name.
- `price`: Current price as a decimal string.
- `charged_repairs_count`: Number of repair lines that have charged this service.

The `charged_repairs_count` field is calculated from associated repair services. It is not a column of the services table.

### GET /api/v1/services

Returns HTTP 200 with an array of service documents, ordered using the `Service.by_name` scope.

Example:

```json
[
  {
    "id": 129,
    "name": "Bottom bracket service",
    "price": "22000.00",
    "charged_repairs_count": 1
  },
  {
    "id": 130,
    "name": "Brake adjustment",
    "price": "15000.00",
    "charged_repairs_count": 3
  }
]
```

If there are no services, the response is an empty array:

```json
[]
```

### GET /api/v1/services/:id

Returns HTTP 200 with one service document.

If the service does not exist, returns HTTP 404.

### POST /api/v1/services

Creates a service using a JSON request body:

```json
{
  "service": {
    "name": "Brake adjustment",
    "current_price": "15000.00"
  }
}
```

Only `name` and `current_price` are permitted.

On success:
- HTTP 201 Created.
- Response body uses the same service document shape.
- The `Location` header contains the new service's API URL.

On failure:
- HTTP 400 if the service attributes are missing or unusable.
- HTTP 401 if the token is missing or invalid.
- HTTP 422 if model validations fail.

## 4. Repair document

A repair has the following JSON representation:

```json
{
  "id": 42,
  "state": "completed",
  "received_on": "2026-10-10",
  "promised_on": "2026-10-15",
  "handed_back_on": "2026-10-14",
  "bike": {
    "brand": "Trek",
    "model": "Marlin 5",
    "serial_number": "TRK-12345"
  },
  "customer": {
    "name": "Example Customer"
  },
  "lines": [
    {
      "service": "Bottom bracket service",
      "charged_price": "22000.00"
    }
  ],
  "total": "22000.00",
  "overdue": false,
  "customer_answer": "approved"
}
```

The dates use ISO 8601 format (`YYYY-MM-DD`). A missing hand-back date is represented by JSON `null`.

The `lines` array contains the services charged for that repair, using their historical charged prices rather than their current catalog prices.

The `total` field is calculated by adding the charged prices of the repair lines.

The `overdue` field indicates whether the repair is overdue according to the application's repair lifecycle.

The `customer_answer` field uses the customer decision defined by the Repair model.

### GET /api/v1/repairs

Requires a Bearer token.

Returns HTTP 200 with an array of repair documents, ordered using the `Repair.by_newest_first` scope.

Example collection:

```json
[
  {
    "id": 42,
    "state": "completed",
    "received_on": "2026-10-10",
    "promised_on": "2026-10-15",
    "handed_back_on": "2026-10-14",
    "bike": {
      "brand": "Trek",
      "model": "Marlin 5",
      "serial_number": "TRK-12345"
    },
    "customer": {
      "name": "Example Customer"
    },
    "lines": [
      {
        "service": "Bottom bracket service",
        "charged_price": "22000.00"
      }
    ],
    "total": "22000.00",
    "overdue": false,
    "customer_answer": "approved"
  }
]
```

An empty collection is represented by `[]`.

### Filter by state

The collection supports filtering:

`GET /api/v1/repairs?state=completed`

Valid states are taken from the Repair model's enum.

An invalid state returns HTTP 400 and lists the available states.

### GET /api/v1/repairs/:id

Requires a Bearer token.

Returns HTTP 200 with one repair document, or HTTP 404 if the repair does not exist.

## 5. Error format

Every API error uses a JSON object containing one key, `errors`, whose value is an array of strings.

Example:

```json
{
  "errors": [
    "Record not found"
  ]
}
```

Status codes:

- `400 Bad Request`: Missing or unusable service attributes, or an invalid repair state.
- `401 Unauthorized`: Missing or invalid Bearer token.
- `404 Not Found`: Requested record does not exist.
- `422 Unprocessable Content`: Model validation failed.

Validation errors use the model's validation messages.

## 6. Design decisions

### Money representation

Prices are represented as decimal strings with two fractional digits.

Example: `"22000.00"`

This representation avoids introducing floating-point rounding errors when transferring monetary values.

The same representation is used for:
- Service prices.
- Repair line charged prices.
- Repair totals.

Clients can convert these strings into an appropriate numeric representation for calculations and format them as currency for display.

### Data privacy

The repair document contains the information needed by the accounting program: dates, repair state, bike identification, customer name, charged service lines, total, overdue state and customer decision.

The following information is intentionally excluded:

- Customer phone numbers.
- Mechanic identifiers.
- Database foreign keys.
- Diagnosis text.
- Intake photographs.

These fields are not necessary for accounting and should not be exposed through this API.

### Query efficiency

The service collection calculates charged repair counts using a grouped database query.

The repair collection preloads bikes, customers, repair lines and associated services.

This prevents N+1 queries: the number of database queries remains independent of the number of returned records.

### CORS

Cross-origin browser access is restricted to:

- `https://julf3r.github.io`
- `http://localhost:5500`

Only public GET service endpoints are exposed through CORS.

Private endpoints are not opened to other browser origins.

Requests without an Origin header, such as requests made with curl, are not restricted by CORS.

## 7. Example requests

Public service list:

```bash
curl http://localhost:3000/api/v1/services
```

Public service detail:

```bash
curl http://localhost:3000/api/v1/services/129
```

Authenticated repairs:

```bash
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  http://localhost:3000/api/v1/repairs
```

Filtered repairs:

```bash
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  "http://localhost:3000/api/v1/repairs?state=completed"
```

Create a service:

```bash
curl -X POST http://localhost:3000/api/v1/services \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"service":{"name":"Brake adjustment","current_price":"15000.00"}}'
```

