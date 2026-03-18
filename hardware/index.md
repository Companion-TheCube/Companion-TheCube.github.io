---
title: Hardware
description: Specs, sensors, GPIO, IO Bridge, and expansion.
nav_order: 5
has_children: true
parent: null
permalink: /hardware/
---

# Hardware

TheCube is built around a **Raspberry Pi 5** with a custom board that includes a display, sensors, and an **IO Bridge** expansion coprocessor.

## Key Components

- **Raspberry Pi 5** — main SoC running TheCube-Core
- **720×720 LCD** — MIPI/DSI display
- **Speakers + Microphones** — audio I/O
- **mmWave Presence Sensor** — connected via Pi UART
- **NFC Reader** — connected via Pi I2C
- **IO Bridge (RP2354)** — expansion coprocessor connected via SPI, providing developer-facing GPIO, I2C, SPI, UART, PIO, and future CAN interfaces

## Subpages

- [**Specs**](/hardware/specs/) — full hardware specifications
- [**Sensors**](/hardware/sensors/) — onboard sensors
- [**GPIO**](/hardware/gpio/) — direct Pi GPIO and bridge GPIO
- [**Expansion & IO Bridge**](/hardware/expansion/) — IO Bridge architecture, CubeBridge Protocol, and expansion interfaces
- [**Compliance**](/hardware/compliance/) — regulatory information
- [**Disassembly**](/hardware/disassembly/) — opening and modifying your Cube
