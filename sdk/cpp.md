---
title: "SDK: C++"
description: C++ API for hardware I/O, including SPI, I2C, UART, and GPIO.
layout: default
parent: SDKs
---

# SDK: C++

The CORE provides C++ classes for interacting with hardware I/O. These classes abstract the IO Bridge and expose a clean handle-based API.

---

## SPI

The `SPI` class (`src/hardware/io_bridge/spi.h`) manages SPI communication through registered handles. Each handle represents a connection to a specific hardware component with fixed SPI settings.

### Include

```cpp
#include <spi.h>
```

### Class: `SPI`

#### `registerHandle(handle, speed, mode)`

Register a named SPI handle with specific settings.

```cpp
std::expected<int, SPIError> registerHandle(
    const std::string& handle,
    int speed,
    int mode
);
```

| Parameter | Type          | Description                                       |
| --------- | ------------- | ------------------------------------------------- |
| `handle`  | `std::string` | Unique name for this connection (e.g., `"accel"`) |
| `speed`   | `int`         | SPI clock speed in Hz (must be > 0)               |
| `mode`    | `int`         | SPI mode 0–3                                      |

Returns `0` on success, or an `SPIError` on failure.

#### `transferTxRx(handle, txData, rxLen)`

Send data and receive a response over SPI.

```cpp
std::optional<base64String> transferTxRx(
    const std::string& handle,
    const base64String& txData,
    size_t rxLen
);
```

| Parameter | Type           | Description                          |
| --------- | -------------- | ------------------------------------ |
| `handle`  | `std::string`  | Registered handle name               |
| `txData`  | `base64String` | TX data, base64-encoded              |
| `rxLen`   | `size_t`       | Expected RX response length in bytes |

Returns the RX data as a base64-encoded string, or `std::nullopt` on failure.

#### `transferTx(handle, txData)`

Send data over SPI without expecting a response.

```cpp
std::optional<base64String> transferTx(
    const std::string& handle,
    const std::string& txData
);
```

#### `getSettings(handle)`

Get the current settings for a registered handle.

```cpp
nlohmann::json getSettings(const std::string& handle);
```

Returns a JSON object with `speed` and `mode` fields.

#### `getRegisteredHandles()`

List all registered SPI handles.

```cpp
std::vector<std::string> getRegisteredHandles();
```

#### `setSpiDevicePath(path)`

Set the SPI device path (e.g., `/dev/spidev0.0`).

```cpp
bool setSpiDevicePath(const std::string& path);
```

### SPI Modes

```cpp
enum class SPIMode {
    MODE_0 = 0,  // CPOL=0, CPHA=0
    MODE_1 = 1,  // CPOL=0, CPHA=1
    MODE_2 = 2,  // CPOL=1, CPHA=0
    MODE_3 = 3   // CPOL=1, CPHA=1
};
```

### Error Handling

SPI operations return `std::expected<T, SPIError>` or `std::optional<T>`:

| Error                       | Meaning                            |
| --------------------------- | ---------------------------------- |
| `NOT_INITIALIZED`           | Device path not set or init failed |
| `HANDLE_NOT_FOUND`          | Handle name not registered         |
| `HANDLE_ALREADY_REGISTERED` | Handle name already in use         |
| `TRANSFER_FAILED`           | SPI transfer operation failed      |
| `INVALID_HANDLE`            | Invalid characters in handle name  |
| `INVALID_SPEED`             | Speed ≤ 0                          |
| `INVALID_MODE`              | Mode not in 0–3                    |
| `TIMEOUT`                   | Transfer timed out                 |

### Thread Safety

All public SPI methods are **thread-safe** — they acquire an internal mutex before accessing shared state. Multiple threads can safely call transfer operations concurrently.

### IO Bridge Integration

SPI transfers are routed through the IO Bridge (RP2354) using the `SPIX` endpoint of the CubeBridge Protocol. The bridge executes the downstream SPI transaction at the configured clock rate while the CORE remains free to service other endpoints. Completion is delivered asynchronously.

---

## I2C, UART, GPIO (Planned)

The following C++ classes follow the same handle-based pattern as SPI but are not yet implemented:

| Class  | Header   | IO Bridge Endpoint |
| ------ | -------- | ------------------ |
| `I2C`  | `i2c.h`  | `0x20` (I2C)       |
| `UART` | `uart.h` | `0x22` (UART)      |
| `GPIO` | `gpio.h` | `0x10` (GPIO)      |

These will provide similar registration, transfer, and event subscription interfaces once bridge firmware support is complete.

---

## See Also

- [API: REST](/api/rest/) — HTTP API for SPI transfers
- [API: Schemas](/api/schemas/) — CBP protocol and endpoint schemas
- [Hardware: Expansion & IO Bridge](/hardware/expansion/) — bridge architecture
