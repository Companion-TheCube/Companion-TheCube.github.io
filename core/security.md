---
title: Security
description: Permissions, sandboxing, encryption, and auditing.
parent: TheCube CORE
---

# Security

## App Permission Model

- App capabilities are declared in the app manifest and enforced at runtime.
- systemd unit templates + Landlock profiles restrict filesystem, network, and device access.
- Apps **cannot** access raw hardware buses — all I/O goes through CORE APIs.
- Privileged operations (audio capture, sensor access, network, bridge I/O) require explicit capability grants.

---

## Data at Rest and in Transit

- Secrets are stored via the kernel keyring or a file-based vault — never in logs.
- Telemetry is opt-in with redaction rules enforced at the source.

---

## IO Bridge Safety & Security

The IO Bridge enforces its own layer of safety and security policy:

### Safety Policy

- **Reserved pins and ports** are blocked by firmware policy — developer code cannot reconfigure system-critical I/O.
- All lengths, counts, rates, and pin ranges are validated before touching hardware.
- Timeouts are enforced on all external bus transactions (I2C, SPI, UART).
- **Safe mode** activates automatically after repeated framing or integrity failures on the CORE↔BRIDGE link (lowers SPI frequency, drops to single outstanding frame, signals `EVT:FAULT{FRAMING_STORM}`).
- Pin ownership is tracked across GPIO, hardware peripherals, and PIO — preventing conflicts.

### Firmware Integrity

- **Signed firmware images** are strongly recommended. Slot metadata includes version, size, digest, and rollback counter.
- The bridge refuses activation of obviously invalid or downgraded images.
- The bridge checks `min_loader_ver` before accepting a firmware slot activation.
- A/B firmware slots with automatic rollback protect against failed updates.

### Future Security Hooks

The protocol reserves space for encryption and authentication, designed for future activation without breaking existing deployments:

- **Encrypted transport** — `Flags.ENCRYPT` bit reserved in the CBP frame header.
- **Authenticated key exchange** — `MGMT.KEYX` (X25519) → ChaCha20-Poly1305 framing for payload encryption.
- **Trust anchors** — OTP-stored key fingerprints or public keys for image signing (ECDSA over manifest + image hash).

---

## Audit Logs

- Structured logs (JSON) per service under `/var/log/thecube/` with rotation.
- Debug flags and dynamic log levels via configuration.
- Bridge-side diagnostics (link stats, CRC error counts, per-endpoint queue fill, latency histograms) accessible via `MGMT.GET_STATS`.

---

## See Also

- [Architecture](/core/architecture/) — capabilities and sandboxing overview
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge firmware security model
- [Logging](/core/logging/) — structured logging conventions
