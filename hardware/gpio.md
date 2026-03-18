---
title: "Hardware: GPIO"
description: GPIO access — direct Pi GPIO and IO Bridge GPIO.
layout: default
parent: Hardware
---

# Hardware: GPIO

TheCube exposes GPIO through **two paths**: direct Raspberry Pi GPIO and bridge-managed GPIO via the IO Bridge (RP2354). The path used depends on the function.

---

## Direct Pi GPIO

Some GPIO pins on the Raspberry Pi are used directly by the main system for functions where that is the correct architectural choice. These pins are **not available** to apps or expansion devices.

Reserved Pi GPIO includes pins allocated to:

- Internal SPI link to the IO Bridge (`SCK`, `MOSI`, `MISO`, `CS`)
- Bridge sideband signals (`BRIDGE_IRQ`, `BRIDGE_RDY`, `BRIDGE_RST`)
- Other internal system functions (display, audio, etc.)

Apps **cannot** access Pi GPIO directly. All GPIO exposed to apps goes through the IO Bridge or the CORE's hardware abstraction APIs.

---

## Bridge GPIO

The IO Bridge exposes its own GPIO pins on the RP2354 for developer use through the expansion headers. These pins are managed by bridge firmware and accessed via the CubeBridge Protocol (CBP) at endpoint `0x10` (`GPIO`).

### Capabilities

| Feature            | Details                                                    |
| ------------------ | ---------------------------------------------------------- |
| Pin modes          | Input, Output, Alternate function                          |
| Pull configuration | Pull-up, pull-down, none                                   |
| Drive strength     | Configurable                                               |
| Read / Write       | Individual pin or masked bulk                              |
| Bulk snapshot      | Read all pins as a bitmap with timestamp                   |
| Interrupt support  | Rising edge, falling edge, both edges, level-triggered     |
| Debounce           | Configurable per-pin                                       |
| Rate limiting      | Event rate limit per-pin to avoid flooding                 |
| Event batching     | Multiple pin events can be coalesced into a single message |

### Operations

| Operation  | Description                                           |
| ---------- | ----------------------------------------------------- |
| `CFG`      | Configure pin mode, pull, and drive strength          |
| `WRITE`    | Write to pins using mask and value                    |
| `READ`     | Read pins using mask                                  |
| `IRQ_CFG`  | Configure interrupt edge, debounce, and rate limiting |
| `SNAPSHOT` | Return all pin states as a bitmap with timestamp      |

### Events

GPIO interrupts are delivered as `EVT:GPIO` events containing:

- Pin number
- Pin state (high/low)
- Timestamp (microseconds)

Events can be batched when multiple interrupts are pending, reducing overhead on the host link.

---

## Pin Ownership and Safety

The bridge firmware enforces strict pin ownership:

- Pins reserved for system functions (SPI uplink, internal buses) are **blocked** and cannot be configured by developer code.
- Pin ownership is tracked across GPIO, hardware peripherals, and PIO — a pin claimed by one subsystem cannot be reassigned without explicitly releasing it first.
- Invalid pin numbers and out-of-range configurations are rejected by the bridge.

---

## See Also

- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — full IO Bridge architecture
- [API: Events](/api/events/) — how GPIO events propagate to apps
- [Architecture](/core/architecture/) — hardware abstraction layer
