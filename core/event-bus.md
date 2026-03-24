---
title: Event Bus
description: System events, topics, and subscription patterns for apps.
parent: TheCube CORE
---

# Event Bus

The Event Bus is the backbone for system → app and app → system messaging within TheCube-Core.

---

## Topics

Events are organized by topic. Examples:

| Topic pattern             | Source    | Description                                      |
| ------------------------- | --------- | ------------------------------------------------ |
| `system.presence`         | Core      | mmWave presence state changes                    |
| `system.network`          | Core      | Network connectivity changes                     |
| `system.power`            | Core      | Power/battery events                             |
| `hardware.gpio.interrupt` | IO Bridge | GPIO pin interrupt events                        |
| `hardware.uart.rx`        | IO Bridge | UART RX watermark events                         |
| `hardware.uart.status`    | IO Bridge | UART line status changes                         |
| `hardware.i2c.done`       | IO Bridge | I2C async transaction completions                |
| `hardware.spix.done`      | IO Bridge | SPI proxy transfer completions                   |
| `hardware.pio.irq`        | IO Bridge | PIO interrupt events                             |
| `hardware.fault`          | IO Bridge | Hardware fault (brownout, overtemp, flash error) |
| `hardware.boot_reason`    | IO Bridge | Bridge reboot reason                             |
| `ui.toast`                | Apps/Core | Toast notification requests                      |
| `ui.banner`               | Apps/Core | Banner notification requests                     |
| `audio.wake`              | Core      | Wakeword detected                                |
| `audio.stt.partial`       | Core      | Partial transcript from remote transcription     |
| `audio.stt.final`         | Core      | Final transcript from remote transcription       |
| `app.<id>.event.*`        | Apps      | App-namespaced events                            |

## Envelope Format

```json
{
    "topic": "system.presence",
    "ts": 1732212345,
    "source": "core",
    "priority": "normal",
    "payload": { "state": "present", "confidence": 0.94 }
}
```

## QoS & Backpressure

- In-process pub/sub with **bounded queues** per subscriber.
- Backpressure drops low-priority events first (configurable per subscriber).
- High-priority events (`PRIO` flag from IO Bridge, fault events) are never dropped unless the queue is completely exhausted.
- Apps declare topic filters at registration; Core enforces quotas on subscription count and message rate.

## Hardware Events

IO Bridge events are translated from the CubeBridge Protocol’s TLV format into standard Event Bus envelopes by the CORE. See [API: Events](/api/events/) for the complete list of hardware event types and their payloads.

---

## See Also

- [API: Events](/api/events/) — hardware and system event types
- [Architecture](/core/architecture/) — Event Bus in the system context
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge event delivery model
