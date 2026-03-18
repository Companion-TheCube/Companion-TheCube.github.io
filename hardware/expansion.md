---
title: "Hardware: Expansion & IO Bridge"
description: IO Bridge architecture, CubeBridge Protocol, and expansion interfaces.
layout: default
parent: Hardware
---

# Hardware: Expansion & IO Bridge

TheCube's expansion system is built around the **IO Bridge** — a dedicated **RP2354**-based coprocessor connected to the Raspberry Pi via SPI. The bridge provides developer-facing I/O without tying expansion traffic to the Pi's native peripherals.

---

## Why an IO Bridge?

The Raspberry Pi's own buses are already allocated to critical internal functions:

- **Pi I2C** is reserved for internal devices (NFC, touchscreen).
- **Pi UART** is reserved for internal hardware (mmWave presence sensor).
- **Some Pi GPIO** is used directly by the system where architecturally appropriate.

The bridge solves two problems:

1. It exposes developer-facing interfaces — SPI, I2C, UART, GPIO, and PIO-backed custom protocols — without conflicting with system peripherals.
2. It **rate-isolates** expansion traffic so a slow external peripheral cannot stall the rest of the system.

For example, if the CORE had to talk directly to a slow external SPI target, the bus transaction would block the Pi-side path for the full transfer. By pushing that work into the RP2354, the CORE keeps a single fast uplink to the bridge while the bridge clocks each downstream bus at whatever rate the peripheral requires.

---

## Architecture

### Topology

```
CORE (Pi 5, SPI master)  ──►  IO Bridge (RP2354, SPI slave)  ──►  Expansion ports
                                     ├── Developer SPI (SPIX)
                                     ├── I2C
                                     ├── UART
                                     ├── GPIO
                                     ├── PIO (custom protocols)
                                     └── CAN (reserved, optional)
```

The CORE always talks to the bridge at a fixed, fast SPI rate negotiated at startup. The bridge translates requests into per-port operations on downstream buses.

### Actors

| Actor                | Description                                               |
| -------------------- | --------------------------------------------------------- |
| **CORE**             | Raspberry Pi running Companion                            |
| **BRIDGE**           | RP2354 coprocessor managing downstream expansion I/O      |
| **Expansion Device** | Any developer-attached peripheral on bridge-managed ports |

---

## Host-to-Bridge Link

| Property         | Value                                                                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Transport        | SPI, Mode 0                                                                                                                              |
| Roles            | CORE = master, BRIDGE = slave                                                                                                            |
| Required signals | `SCK`, `MOSI`, `MISO`, `CS`                                                                                                              |
| Sideband signals | `BRIDGE_IRQ` (bridge → core event doorbell), `BRIDGE_RDY` (bridge ready after reset/boot), `BRIDGE_RST` (optional host-controlled reset) |

The exact SPI clock rate is advertised by the bridge during the handshake. The CORE may adjust the clock at runtime within the advertised range.

Since SPI is master-clocked, the CORE must actively clock event data out of the bridge. When `BRIDGE_IRQ` is asserted, the CORE performs a **drain cycle** — sending NOP frames and receiving event frames. Events can also piggyback on the RX direction of any normal transaction.

---

## Exposed Interfaces

### GPIO

Configure pin mode (input/output/alt), pull-up/down, drive strength, read/write, bulk snapshot, and per-pin interrupt configuration (edge, debounce, rate-limit). Events deliver pin state with microsecond timestamps, optionally batched.

### I2C

Multiple logical ports (hardware or PIO-backed). Supports 7-bit and optional 10-bit addressing, write/read/combined transfers, repeated start, explicit timeouts, and clear status reporting for NACK, arbitration loss, timeout, and bus-stuck conditions. Configurable clock: 100 kHz / 400 kHz / 1 MHz.

### SPI Proxy (SPIX)

A bridge-managed developer SPI — completely separate from the CORE↔BRIDGE uplink SPI. You can open a device profile with a specific mode, bit width, clock rate, CS polarity, and setup/hold timing. Full-duplex or asymmetric TX/RX transfers are supported. A slow SPIX transaction runs entirely on the bridge side and does not stall unrelated bridge traffic; completion is delivered asynchronously.

### UART

Open with baud rate, parity, stop bits, flow control, and optional inversion. The bridge maintains per-port ring buffers. You can write bytes, pull bytes on demand, or subscribe to RX watermark events for push delivery. Status events report overrun, framing errors, break, and modem-control changes.

### PIO (Programmable I/O)

PIO is a first-class feature. You can load custom PIO programs into the RP2354's PIO blocks at runtime, configure state machines, start/stop execution, and access FIFOs. This enables custom SPI variants, soft UARTs, single-wire buses, and specialized accessory protocols — all without changing the host link or external API shape.

Safety rules:

- PIO programs may not use pins reserved for system functions.
- Pin ownership is tracked across GPIO, hardware peripherals, and PIO.
- Resource limits (instruction count, SM count, pin windows) are enforced by firmware policy.

### CAN / CAN-FD (Reserved)

Protocol space is allocated for CAN at endpoint `0x23`. The first hardware revision may or may not expose a physical CAN transceiver, but the protocol and firmware are designed to support it.

---

## Electrical

| Parameter      | Value                                                              |
| -------------- | ------------------------------------------------------------------ |
| Logic domain   | 3.3 V                                                              |
| 5 V tolerance  | Only where explicitly supported by hardware design — not universal |
| ESD protection | Required on external headers                                       |
| I2C pull-ups   | On the bridge board                                                |
| Level shifting | Dedicated shifters required for true 5 V logic-high signaling      |

---

## Firmware Update

The bridge supports **A/B slot** firmware updates entirely over the CORE-to-bridge SPI link:

1. Query flash layout and slot status.
2. Erase the inactive slot.
3. Write image chunks with CRC32 verification.
4. Verify the full image digest.
5. Set the active slot and reboot.
6. The CORE confirms "boot good" after successful startup.

If the new firmware fails to boot, the bridge automatically rolls back to the previous slot.

Slot manifests include version, build ID, timestamp, min loader version, image CRC32, length, and rollback counter. The bridge refuses activation if the minimum loader version is not met.

---

## Session Bring-Up

The handshake sequence between CORE and bridge at boot:

1. Hardware reset or power-up.
2. CORE waits for `BRIDGE_RDY` to assert.
3. CORE sends `HELLO` (desired MTU, window size, supported endpoints, max SPI Hz).
4. BRIDGE responds with `HELLO_RSP` (allowed SPI Hz range, actual MTU, window, per-endpoint queue depths, silicon ID, firmware version, capabilities bitmask).
5. Optional `TIME_SYNC`.
6. CORE switches SPI clock to agreed rate and enters normal operation.

---

## CubeBridge Protocol (CBP) Overview

All CORE↔BRIDGE communication uses the **CubeBridge Protocol (CBP) v0.1**, a multiplexed, reliable byte-stream protocol that runs over SPI (primary), with UART and I2C fallbacks for rescue/maintenance.

Key properties:

- **One transport, many virtual endpoints** — each interface (GPIO, I2C, SPIX, UART, PIO, etc.) is a logical endpoint.
- **Request/response + events** — synchronous commands plus unsolicited async events.
- **Per-endpoint flow control** — credit-based to prevent one slow endpoint from starving others.
- **Sliding window reliability** — sequence/ack with retransmission.
- **Fragmentation** — large payloads (firmware images, PIO programs) are chunked at the negotiated MTU.

See [API: Schemas](/api/schemas/) for the CBP frame format and endpoint header structures.

---

## Rate Isolation

Rate isolation is the core architectural requirement. Examples:

- A developer SPI target running at 125 kHz must not prevent GPIO events or UART RX from being reported.
- An I2C device that stretches the clock must not block unrelated UART activity.
- A bursty UART stream must not starve management traffic or make firmware updates impossible.

The bridge achieves this through per-endpoint work queues, DMA-backed buffering, credit-based flow control, and asynchronous completion events.

---

## Why RP2354?

The RP2354 provides:

- Dedicated hardware SPI, I2C, and UART blocks for common traffic
- **PIO** for custom or timing-sensitive interfaces
- **DMA** for high-throughput, low-jitter data movement
- **Dual-core** execution — one core for host link service, one for downstream bus work
- XIP and flash features for robust A/B update and recovery

A single software-defined MCU gives the project one uniform I/O surface rather than a collection of fixed-function bridge chips.

---

## See Also

- [Hardware: GPIO](/hardware/gpio/) — pin maps and direct Pi GPIO vs. bridge GPIO
- [Hardware: Specs](/hardware/specs/) — full hardware specifications
- [Architecture](/core/architecture/) — how the IO Bridge integrates with the CORE
- [Boot Sequence](/core/boot-sequence/) — system-level init including bridge handshake
- [API: Schemas](/api/schemas/) — CBP frame format and endpoint schemas
- [API: Events](/api/events/) — hardware events surfaced through the Event Bus
