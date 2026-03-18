---
title: "Hardware: Specs"
description: Hardware specifications for TheCube.
layout: default
parent: Hardware
---

# Hardware: Specs

## System-on-Chip

| Component | Specification          |
| --------- | ---------------------- |
| Main SoC  | Raspberry Pi 5         |
| Display   | 720×720 LCD (MIPI/DSI) |
| Audio     | Speakers + Microphones |
| Presence  | mmWave sensor (UART)   |
| NFC       | NFC reader (I2C)       |

---

## IO Bridge

The IO Bridge is a dedicated expansion coprocessor that provides developer-facing I/O.

| Component        | Specification                                               |
| ---------------- | ----------------------------------------------------------- |
| MCU              | RP2354                                                      |
| Host link        | SPI Mode 0 (CORE = master, BRIDGE = slave)                  |
| Required signals | `SCK`, `MOSI`, `MISO`, `CS`                                 |
| Sideband signals | `BRIDGE_IRQ`, `BRIDGE_RDY`, `BRIDGE_RST` (optional)         |
| Logic domain     | 3.3 V                                                       |
| Firmware update  | A/B slots over SPI (no USB/UART required for field updates) |
| Protocol         | CubeBridge Protocol (CBP) v0.1                              |

### Expansion Interfaces

| Interface        | Details                                                                                             |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| GPIO             | Configurable I/O with interrupt support, debounce, and bulk snapshot                                |
| I2C              | Multiple logical ports; 100 kHz / 400 kHz / 1 MHz; 7-bit and optional 10-bit addressing             |
| SPI Proxy (SPIX) | Independent developer SPI at configurable speed and mode (separate from host uplink)                |
| UART             | Configurable baud, parity, flow control; ring-buffered with watermark events                        |
| PIO              | Runtime-loadable programs for custom protocols (soft UART, single-wire, timing-critical interfaces) |
| CAN / CAN-FD     | Reserved in protocol; physical transceiver TBD per hardware revision                                |

### Electrical

| Parameter         | Value                                                           |
| ----------------- | --------------------------------------------------------------- |
| Main logic level  | 3.3 V                                                           |
| 5 V tolerance     | Only where explicitly supported by board design — not universal |
| ESD protection    | On external expansion headers                                   |
| I2C pull-ups      | On the bridge board                                             |
| Level shifting    | Dedicated shifters required for 5 V logic-high signaling        |
| Fast signal lines | Series damping resistors where signal integrity requires        |

---

## Reserved Pi Buses

These native Raspberry Pi buses are allocated to internal system functions and are **not available** for developer expansion:

| Bus            | Reserved For                                       |
| -------------- | -------------------------------------------------- |
| Pi I2C         | NFC, touchscreen                                   |
| Pi UART        | mmWave presence sensor                             |
| Pi SPI         | IO Bridge uplink                                   |
| Select Pi GPIO | Bridge sideband signals, system-internal functions |

All developer expansion I/O should go through the IO Bridge. See [Hardware: Expansion & IO Bridge](/hardware/expansion/) for details.

---

## See Also

- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — IO Bridge architecture and protocol
- [Hardware: GPIO](/hardware/gpio/) — GPIO pin details
- [Hardware: Sensors](/hardware/sensors/) — onboard sensors
