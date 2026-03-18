---
title: "API: Events"
description: Hardware and system events surfaced through the Event Bus.
layout: default
parent: CORE API
---

# API: Events

The CORE Event Bus carries system events, app events, and **hardware events from the IO Bridge**. This page documents the hardware event types that originate from the bridge and are delivered to apps through the standard Event Bus subscription model.

---

## IO Bridge Event Model

The IO Bridge generates unsolicited events and delivers them to the CORE via the CubeBridge Protocol (CBP). The CORE translates these into Event Bus envelopes that apps can subscribe to.

Events from the bridge are:

- **Timestamped** — microsecond-resolution bridge-side timestamps
- **Routable** — tagged with endpoint and port for precise filtering
- **Batchable** — multiple events can be coalesced into a single message when several are pending
- **Priority-aware** — fault/safety events use the `PRIO` flag for immediate delivery

### Event Drain

Since the CORE↔BRIDGE link is SPI (master-clocked), the CORE must actively drain events from the bridge. When `BRIDGE_IRQ` is asserted, the CORE performs a drain cycle. Events can also piggyback on the RX direction of normal traffic.

---

## Hardware Event Types

### GPIO Events

| Event      | Payload                 | Description                                                             |
| ---------- | ----------------------- | ----------------------------------------------------------------------- |
| `EVT:GPIO` | `pin`, `state`, `ts_us` | Pin interrupt fired. Batched when multiple pins trigger simultaneously. |

Subscribe via `IRQ_CFG` on the GPIO endpoint. Events respect per-pin debounce and rate-limit settings.

### UART Events

| Event             | Payload                          | Description                                                     |
| ----------------- | -------------------------------- | --------------------------------------------------------------- |
| `EVT:UART_RX`     | `port`, `count`, `data`, `ts_us` | RX buffer crossed the watermark threshold                       |
| `EVT:UART_STATUS` | `port`, status flags             | Overrun, framing error, break, CTS change, or other line status |

Subscribe via `UART.SUBSCRIBE_RX` or `UART.SET_WM`. The bridge keeps ring buffers per UART port; watermarks control the tradeoff between latency and overhead.

### I2C Events

| Event          | Payload         | Description                                                         |
| -------------- | --------------- | ------------------------------------------------------------------- |
| `EVT:I2C_DONE` | `txn`, `status` | Asynchronous I2C transaction completed (used for queued operations) |

Status includes OK, NACK, arbitration lost, timeout, and bus-stuck conditions.

### SPI Proxy Events

| Event           | Payload             | Description                               |
| --------------- | ------------------- | ----------------------------------------- |
| `EVT:SPIX_DONE` | `status`, `rx_data` | Non-blocking SPI proxy transfer completed |

Since SPIX transfers run at the downstream device's clock rate (which may be slow), completions are delivered asynchronously rather than blocking the host link.

### PIO Events

| Event             | Payload                    | Description                           |
| ----------------- | -------------------------- | ------------------------------------- |
| `EVT:PIO_IRQ`     | `pio_idx`, `mask`, `ts_us` | PIO interrupt flag asserted           |
| `EVT:PIO_FIFO_WM` | `pio_idx`, `sm_id`         | PIO FIFO watermark reached (optional) |

### CAN Events (Reserved)

| Event         | Payload    | Description            |
| ------------- | ---------- | ---------------------- |
| `EVT:CAN_RX`  | frame data | CAN frame received     |
| `EVT:CAN_ERR` | error type | Bus-off, error passive |
| `EVT:CAN_TXC` | `txn`      | CAN transmit complete  |

### System Events

| Event             | Payload                  | Description                            |
| ----------------- | ------------------------ | -------------------------------------- |
| `EVT:FLOW`        | endpoint, credits        | Flow-control credit replenishment      |
| `EVT:FAULT`       | class, code, value, `ts` | Brownout, overtemperature, flash error |
| `EVT:WDT_WARN`    | —                        | Watchdog timeout imminent              |
| `EVT:BOOT_REASON` | reason code              | Why the bridge last rebooted           |

---

## Event TLV Format

Bridge events use a compact TLV (type-length-value) format within the CBP event payload:

```
[ type(u8) | len(u8) | ts_us(u32 or u48) | payload... ]
```

Multiple TLVs can be packed into a single EVT frame. The bridge coalesces events until at least one EVT frame is drained (keeping `BRIDGE_IRQ` asserted until then).

---

## Event Bus Integration

Hardware events from the bridge are translated into standard Event Bus envelopes:

```json
{
    "topic": "hardware.gpio.interrupt",
    "ts": 1732212345,
    "source": "core.io_bridge",
    "priority": "normal",
    "payload": { "pin": 5, "state": 1, "ts_us": 12345678 }
}
```

Apps subscribe to hardware event topics using the standard Event Bus subscription API. Fault and safety events (`EVT:FAULT`, `EVT:WDT_WARN`) are delivered at high priority.

---

## See Also

- [Event Bus](/core/event-bus/) — subscription patterns and QoS
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge architecture
- [API: Schemas](/api/schemas/) — CBP frame and event schemas
- [Hardware: GPIO](/hardware/gpio/) — GPIO interrupt configuration
