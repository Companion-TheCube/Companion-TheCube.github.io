---
title: "API: Schemas"
description: CubeBridge Protocol frame format, endpoint headers, and payload schemas.
layout: default
parent: CORE API
nav_order: 8
has_children: true
---

# API Schemas

This page documents the wire-level structures used by the **CubeBridge Protocol (CBP) v0.1** — the binary protocol between the CORE and the IO Bridge.

---

## CBP Frame Format

All integers are **little-endian**. Every frame starts with a fixed header:

```
+-----------+------+--------+-------+---------+------+-----+-----+--------+--------+
| Sync(2)   | Ver  | HdrLen | Flags | MsgType | EPID | Seq | Ack | Length | HdrCRC |
| 0xA5 0x5A |  u8  |   u8   |  u8   |   u8    |  u8  |  u8 |  u8 |  u16   |   u8   |
+-----------+------+--------+-------+---------+------+-----+-----+--------+--------+
| Payload (Length bytes)                                                             |
+-----------------------------------------------------------------------------------+
| CRC32 (payload, IEEE 802.3 — present only when Length > 0)                        |
+-----------------------------------------------------------------------------------+
```

### Header Fields

| Field     | Size    | Description                                                            |
| --------- | ------- | ---------------------------------------------------------------------- |
| `Sync`    | 2 bytes | Fixed frame marker: `0xA5, 0x5A`                                       |
| `Ver`     | 1 byte  | Protocol version (currently `1`)                                       |
| `HdrLen`  | 1 byte  | Header size in bytes from `Ver` to `HdrCRC` inclusive (default `0x10`) |
| `Flags`   | 1 byte  | Bitfield (see below)                                                   |
| `MsgType` | 1 byte  | `0`=NOP, `1`=REQ, `2`=RSP, `3`=EVT, `4`=ACK (explicit, rare)           |
| `EPID`    | 1 byte  | Virtual endpoint ID (see endpoint map)                                 |
| `Seq`     | 1 byte  | Sender sequence number (0–15 recommended window)                       |
| `Ack`     | 1 byte  | Last good sequence received from peer                                  |
| `Length`  | 2 bytes | Payload length (0 to MTU)                                              |
| `HdrCRC`  | 1 byte  | CRC-8 over `Ver` through `Length` (polynomial `0x07`)                  |

### Flags Bitfield

| Bit | Name       | Description                             |
| --- | ---------- | --------------------------------------- |
| 0   | `FRAG`     | This frame is a fragment                |
| 1   | `LAST`     | Last fragment in message                |
| 2   | `PRIO`     | High priority (safety/fault events)     |
| 3   | `ENCRYPT`  | Reserved for future encrypted transport |
| 4   | `ACK_ONLY` | Header-only ack/keepalive (no payload)  |

### MTU

Negotiated during handshake. Defaults:

| Transport       | Default MTU |
| --------------- | ----------- |
| SPI             | 512 bytes   |
| UART (fallback) | 256 bytes   |
| I2C (fallback)  | 128 bytes   |

---

## C Structure (Reference)

```c
#pragma pack(push, 1)
typedef struct {
    uint16_t sync;     // 0x5AA5
    uint8_t  ver;      // 1
    uint8_t  hdr_len;  // 0x10
    uint8_t  flags;    // FRAG/LAST/PRIO/ENCRYPT/ACK_ONLY
    uint8_t  type;     // 0=NOP, 1=REQ, 2=RSP, 3=EVT
    uint8_t  epid;     // endpoint id
    uint8_t  seq;      // 0..15
    uint8_t  ack;      // last received seq
    uint16_t len;      // payload length
    uint8_t  hdr_crc;  // CRC-8 over ver..len
} cbp_hdr_t;
#pragma pack(pop)
```

---

## Endpoint Map

| EPID   | Name   | Description                                  |
| ------ | ------ | -------------------------------------------- |
| `0x00` | `MGMT` | Management, hello, stats, logs, time sync    |
| `0x01` | `FWUP` | Firmware update and slot management          |
| `0x02` | `PIO`  | PIO program load and state machine control   |
| `0x10` | `GPIO` | Pin mode, read/write, IRQ config, snapshots  |
| `0x20` | `I2C`  | I2C transfers and configuration              |
| `0x21` | `SPIX` | Developer SPI proxy (independent downstream) |
| `0x22` | `UART` | UART config and byte streams                 |
| `0x23` | `CAN`  | CAN / CAN-FD (reserved)                      |
| `0x30` | `INT`  | Consolidated async event bucket              |
| `0xFE` | `DBG`  | Diagnostics, loopback                        |
| `0xFF` | `CTRL` | Reset, sleep, watchdog, safe-mode            |

---

## Endpoint Header

Every endpoint payload begins with a common mini-header:

```c
struct EPHeader {
    uint8_t  op;    // operation code (enum per endpoint)
    uint8_t  port;  // physical instance (e.g., I2C0=0, UART2=2); 0xFF = N/A
    uint16_t txn;   // transaction ID for multi-fragment correlation
};
```

This keeps per-endpoint parsing regular across all bridge interfaces.

---

## Error Status

Every response payload begins with a common status structure:

```c
struct Status {
    int16_t  code;    // 0 = OK, negative = error
    uint16_t detail;  // endpoint-specific subcode
};
```

### Common Status Codes

| Code | Name      | Description             |
| ---- | --------- | ----------------------- |
| 0    | `OK`      | Success                 |
| -1   | `TIMEOUT` | Operation timed out     |
| -2   | `BUSY`    | Endpoint busy           |
| -3   | `NACK`    | I2C NACK                |
| -4   | `PARAM`   | Invalid parameter       |
| -5   | `CRC`     | CRC mismatch            |
| -6   | `PERM`    | Permission denied       |
| -7   | `UNSUP`   | Unsupported operation   |
| -8   | `NO_MEM`  | Out of memory/resources |
| -9   | `IO_ERR`  | I/O error               |
| -10  | `STATE`   | Invalid state           |

---

## Endpoint Operation Enums (Reference)

```c
enum I2C_OP  { I2C_CFG=0x01, I2C_XFER=0x02 };
enum SPIX_OP { SPIX_OPEN=0x01, SPIX_XFER=0x02, SPIX_CLOSE=0x03, SPIX_CFG=0x04 };
enum UART_OP { UART_OPEN=0x01, UART_WRITE=0x02, UART_READ=0x03, UART_SET_WM=0x04, UART_CLOSE=0x05 };
enum PIO_OP  { PIO_LOAD_PROG=0x01, PIO_SM_CFG=0x02, PIO_SM_START=0x03, PIO_SM_STOP=0x04, PIO_PUSH=0x05, PIO_PULL=0x06 };
enum FW_OP   { FW_QUERY=0x01, FW_ERASE=0x02, FW_WRITE=0x03, FW_VERIFY=0x04, FW_SET_ACTIVE=0x05, FW_COMMIT=0x06, FW_REBOOT=0x07 };
```

---

## Reliability & Flow Control

- **Sliding window**: up to W outstanding frames (W negotiated, default 4)
- **Piggyback ACK**: the `Ack` field in every frame acknowledges the last good `Seq` from peer
- **Retransmission**: on timeout, unacked frames are retransmitted
- **Per-endpoint credits**: bridge advertises RX credits per endpoint in `HELLO_RSP`; the CORE must not exceed them; credits are replenished via `EVT:FLOW` or piggybacked in normal events
- **Fragmentation**: payloads larger than MTU are split across frames with `FRAG` set; the last fragment has `LAST` set; reassembly is tied to endpoint transaction IDs

---

## Event TLV Format

```
[ type(u8) | len(u8) | ts_us(u32 or u48) | payload... ]
```

Multiple event TLVs can be packed into a single EVT frame payload.

---

## See Also

- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — protocol overview and endpoint details
- [API: Events](/api/events/) — event types and Event Bus integration
- [API: REST](/api/rest/) — HTTP API for SPI and other operations
