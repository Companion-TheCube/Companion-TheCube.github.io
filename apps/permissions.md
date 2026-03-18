---
title: Permissions
description: App capabilities, sandboxing, and hardware access control.
layout: default
parent: App Development
---

# Permissions

Apps run in a sandboxed environment and must declare the capabilities they need in their app manifest. The CORE enforces these at runtime.

---

## Capability Model

Each app declares a set of capabilities. Only granted capabilities are accessible at runtime. Attempting to use an ungrated capability results in a permission error.

### Available Capabilities

| Capability | Description                                                |
| ---------- | ---------------------------------------------------------- |
| `display`  | Access to screen rendering (characters, scenes, toasts)    |
| `audio`    | Microphone input and speaker output                        |
| `sensors`  | Read from onboard sensors (mmWave presence, etc.)          |
| `bridges`  | Access to IO Bridge interfaces (SPI, I2C, UART, GPIO, PIO) |
| `network`  | Outbound network access                                    |
| `storage`  | File storage (scoped to app directory)                     |
| `nfc`      | NFC reader access                                          |

### Bridge I/O Access

The `bridges` capability controls whether an app can interact with the IO Bridge expansion interfaces. When granted, the app can:

- Perform SPI transfers via registered handles
- Read/write GPIO pins (bridge-managed, not direct Pi GPIO)
- Open and use UART and I2C ports
- Subscribe to hardware events (GPIO interrupts, UART RX, etc.)

Apps **never** gain direct access to Linux device nodes (`/dev/spidev*`, `/dev/i2c-*`, etc.). All hardware I/O is mediated through the CORE's abstraction layer and the CubeBridge Protocol.

---

## Sandboxing

- **systemd unit templates** — each app runs as `cube-app-<name>.service` with restricted permissions.
- **Landlock profiles** — restrict filesystem, network, and device access at the kernel level.
- **No raw bus access** — apps cannot open `/dev/` nodes unless explicitly granted via capabilities.
- **Resource budgets** — CPU, memory, and I/O limits are enforced per app.

---

## Manifest Declaration

Capabilities are declared in the app manifest:

```json
{
    "app": "com.example.sensor-reader",
    "permissions": ["bridges", "network"],
    "...": "..."
}
```

The CORE validates permissions at install time and enforces them at runtime.

---

## See Also

- [App Model](/apps/app-model/) — app lifecycle and structure
- [Architecture](/core/architecture/) — capabilities in the system context
- [Security](/core/security/) — sandboxing and audit details
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge interfaces available to apps
