---
title: "API: REST"
description: REST API endpoints for hardware I/O and system management.
layout: default
parent: CORE API
---

# API: REST

TheCube CORE exposes REST endpoints over HTTP on localhost (port 55280) or a shared Unix socket. Apps use these endpoints to interact with hardware and system services.

---

## SPI

The SPI API provides handle-based access to SPI devices via the IO Bridge. Apps request a named handle tied to a specific hardware component and use it for all subsequent transfers.

### Authentication & Access

SPI endpoints are **private** — only apps with the appropriate capability grant may call them. All requests require `Content-Type: application/json`.

### `POST /SPI_transfer_txrx`

Perform a full-duplex SPI transfer: send TX data and receive RX data.

**Request body:**

```json
{
    "handle": "accel",
    "tx": "AQAIAAA=",
    "rxLen": 6
}
```

| Field    | Type             | Description                                            |
| -------- | ---------------- | ------------------------------------------------------ |
| `handle` | string           | Registered SPI handle name (e.g., `"accel"`, `"gyro"`) |
| `tx`     | string           | TX data, **base64-encoded** (RFC 4648)                 |
| `rxLen`  | unsigned integer | Expected RX response length in bytes                   |

**Success response (200):**

```json
{
    "ok": true,
    "rx": "AQIDBAUG"
}
```

| Field | Type    | Description                 |
| ----- | ------- | --------------------------- |
| `ok`  | boolean | `true` on success           |
| `rx`  | string  | RX data, **base64-encoded** |

**Error responses:**

| Status | Condition                                                         | Body                            |
| ------ | ----------------------------------------------------------------- | ------------------------------- |
| 400    | Invalid Content-Type, unparseable JSON, or missing/invalid fields | `{"ok": false, "error": "..."}` |
| 500    | SPI transfer failed (handle not found, device error, etc.)        | `{"ok": false, "error": "..."}` |

### SPI Handles

Each SPI handle corresponds to a specific hardware component with specific SPI settings (speed, mode). Handles are registered internally by the system or by privileged services.

| Property | Description                                 |
| -------- | ------------------------------------------- |
| `speed`  | SPI clock speed in Hz                       |
| `mode`   | SPI mode (0–3): CPOL and CPHA configuration |

**SPI Modes:**

| Mode | CPOL | CPHA |
| ---- | ---- | ---- |
| 0    | 0    | 0    |
| 1    | 0    | 1    |
| 2    | 1    | 0    |
| 3    | 1    | 1    |

### SPI Error Codes

The SPI subsystem reports specific error conditions:

| Error                       | Description                                      |
| --------------------------- | ------------------------------------------------ |
| `NOT_INITIALIZED`           | SPI device path not set or initialization failed |
| `HANDLE_NOT_FOUND`          | Requested handle is not registered               |
| `HANDLE_ALREADY_REGISTERED` | Handle name already in use                       |
| `TRANSFER_FAILED`           | SPI transfer operation failed                    |
| `INVALID_HANDLE`            | Handle name contains invalid characters          |
| `INVALID_SPEED`             | Speed must be > 0                                |
| `INVALID_MODE`              | Mode must be 0–3                                 |
| `TIMEOUT`                   | Transfer timed out                               |

### Implementation Note

SPI transfers are routed through the IO Bridge (RP2354) rather than directly to Linux `spidev` device nodes. The CORE translates API requests into `SPIX` endpoint operations on the CubeBridge Protocol. This means downstream SPI transfers are **non-blocking** from the CORE's perspective — the bridge handles the actual clocking while other endpoints remain responsive.

---

## Additional Endpoints (Draft)

The following endpoints are planned or partially implemented:

| Endpoint                                  | Method | Description                                  |
| ----------------------------------------- | ------ | -------------------------------------------- |
| `GET /getCubeSocketPath`                  | GET    | Returns the app's JSON-RPC socket path       |
| `POST /FunctionRegistry-registerFunction` | POST   | Register callable functions                  |
| `POST /events/publish`                    | POST   | Publish events onto the Event Bus            |
| `GET /config/:key`                        | GET    | Read app-scoped configuration                |
| `PUT /config/:key`                        | PUT    | Write app-scoped configuration               |
| `GET /health`                             | GET    | System health status (including bridge link) |

---

## See Also

- [API: Events](/api/events/) — event model and hardware events
- [API: Schemas](/api/schemas/) — payload schemas and CBP frame format
- [SDK: C++](/sdk/cpp/) — C++ API for SPI and other hardware
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge architecture
