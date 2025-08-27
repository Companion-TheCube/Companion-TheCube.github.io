---
title: Expansion‑Port Manager
description: "Expansion‑Port Manager: comprehensive plan (DRAFT)"
layout: default
parent: TheCube CORE
---


# **RP2354 Expansion‑Port Manager — Comprehensive Plan (DRAFT)**

Below is the full, implementation‑ready plan for the RP2354‑based “expansion port manager” that bridges a high‑speed host SPI link to developer‑facing SPI/I²C/UART ports, supports robust A/B updates, and clean recovery. This design is tuned to the RP2354’s strengths (internal 2 MB flash‑in‑package, dual‑CS XIP/QMI, PIO, DMA, security/OTP) and to various constraints (host connected only by SPI; NFC/touch using the SoC’s own I²C; mmWave on UART).

---

## **1\) High‑level goals & constraints**

-   **Primary role:** act as a deterministic, low‑latency bridge between a **high‑speed host SPI** and developer ports (configurable‑rate **SPI**, **I²C**, **UART**, etc), with **rate isolation** so a slow dev device never stalls host traffic.

-   **Robust updates:** internal **A/B loader** (in RP2354 internal flash) plus **A/B main program** in external QSPI on **CS1**, with signed images and rollback protection; recoverable via **BOOTSEL** (USB/UART).

-   **Future‑proof IO:** leverage **PIO** to add/extend protocols (custom SPI, single‑wire UART variants, odd clocks, ws2812, CAN bus, etc.). RP2354 provides **12 PIO state machines**.

---

## **2\) Hardware partitioning (RP2354 pins & busses)**

-   **Host link:** dedicate **SPI0** to the host. Use 4‑wire SPI (SCK/MOSI/MISO/CS) \+ a **IRQ/GPIO** for “doorbell”/flow‑control. Drive via DMA.

-   **Developer ports:**

    -   **I²C:** expose 2 ports using the RP2354 I²C controllers for rock‑solid timing; optionally add a **PIO‑I²C** instance for corner cases. The chip has **two I²C controllers**.

    -   **UART:** at least one HW UART exposed, with an optional **PIO‑UART** to enable extra channels when needed. The chip has **two UARTs**.

    -   **Configurable‑rate SPI for devs:** implement with **PIO SPI** so its SCK is independent of the host link. The datasheet’s PIO examples include **duplex SPI** and **UART TX/RX** recipes to start from.

-   **Electrical notes:**

    -   **3.3 V IO; 5 V behavior:** GPIOs are **5 V‑tolerant when powered** (inputs) and **3.3 V‑failsafe when unpowered**; outputs still source 3.3 V—level‑shift if a dev module requires 5 V logic‑high.

    -   I²C pull‑ups on the board; series resistors (22–47 Ω) on fast SPI lines; ESD diodes on all external pins.

-   **XIP / flash topology:**

    -   RP2354 variants include **internal flash‑in‑package**—use this for the **loader A/B**.

    -   QMI supports **two XIP devices with independent CS** and **banked configuration** (different opcodes/clock per device). Use **CS1** for an external **16 MB** “program flash” (A/B).

    -   The QMI provides **address translation windows**—handy for mapping **multiple OTA slots** cleanly.

---

## **3\) Boot & update architecture**

### **3.1 Boot path**

1. **Boot ROM** initializes a baseline XIP/QMI and enters flash image; you may later retune the QSPI clock **on the fly** (safe even when executing from XIP).

2. Early in startup, run an **XIP setup function** from **SRAM** (≤256 B) to finalize opcodes/drive strength, etc. The SDK’s `PICO_EMBED_XIP_SETUP=1` helps here.

### **3.2 Loader layout (internal flash, A/B)**

-   **Partitions:** `loader_a` / `loader_b` (+ small cfg/manifest). At power‑on the ROM loads the signed image which in turn picks the active loader partition based on a **boot control block** and a **rollback counter**. (ROM supports **boot signing** with OTP key hash and **rollback version** checks.)

-   **Job of the loader:** provide the **host‑SPI update service**, choose & jump to the correct **external program slot** (see below), and offer **recovery UI/flags**.

### **3.3 Program layout (external flash on CS1, A/B)**

-   **Partitions:** `prog_a` / `prog_b` (+ per‑slot manifest with version/size/hash/signature).

-   Use QMI **address translation** to map each slot into a fixed runtime address range; this keeps vector locations stable.

### **3.4 Update flow (host connected only by SPI)**

1. Host sends a signed image to the **inactive slot** (loader or program).

2. Loader writes via **QMI direct‑mode FIFO** or XIP‑safe routines, verifying hash/signature.

3. Loader updates the **boot control block** (and optional **OTP rollback value**) and reboots; a **watchdog** confirm sequence flips active/inactive after first clean boot, else roll back.

### **3.5 Recovery**

-   **BOOTSEL**: pull **QSPI CSn low** at reset to force BOOTSEL; use **SD1** to select **USB** (drag‑and‑drop MSD/PICOBOOT) vs **UART** bootloader. Add a **4.7 kΩ** pulldown pad path so you can assert it externally.

---

## **4\) Firmware architecture**

### **4.1 RTOS and cores**

-   **Core 0 (real‑time):** Host‑SPI service, ring‑buffer/DMA engine, command router, flash writer, watchdog, safety.

-   **Core 1 (IO services):** Dev‑bus workers (PIO‑SPI, I²C, UART), protocol state machines, timing.  
     Use bus‑priority and banked SRAM to keep determinism under load. (Crossbar supports per‑manager priority; zero‑wait SRAM guarantees latency for high‑priority tasks.)

### **4.2 Host link (SPI0)**

-   **Physical:** SPI @ 12–40 MHz (tune for your cable/EMI). Optional **IRQ** line signals “new TX/RX”.

-   **Framing:** 4‑byte header `{channel, flags, length}` \+ payload \+ **CRC‑16**; **credit‑based flow control** to multiplex channels (SPI_CFG, I2C_TX, I2C_RX, UARTx_TX, UARTx_RX, FLASH, LOG, CTRL).

-   **DMA:** double‑buffered RX/TX; large SRAM rings for lossless UART bridging; back‑pressure via credits.

### **4.3 Dev‑bus services (rate‑isolated)**

-   **Configurable‑rate SPI (PIO):**

    -   Dedicated **PIO SM** generates SCK, CPOL/CPHA, CS, and samples MISO with an elastic FIFO.

    -   **Per‑transaction clock** (e.g., 50 kHz…20 MHz) so slow devices do **not** stall other channels; jobs queue in a **work scheduler** with per‑bus mutexes and timeouts.

    -   Reference the PIO **Duplex SPI** example for core loops and side‑set‑driven CS.

-   **I²C (HW \+ optional PIO):** use HW I²C for standard traffic; fall back to **PIO‑I²C** for unusual stretch/clocking cases. The SoC provides **2 I²C controllers**.

-   **UART (HW \+ PIO):** one or two hardware UART endpoints plus optional PIO‑UARTs for more ports. PIO **UART TX/RX** examples exist.

-   **Line settings:** per‑endpoint config structs (SPI mode/Hz/word‑size; I²C Hz/pull‑ups; UART baud/format/flow). Persist to a small settings page in internal flash.

### **4.4 Flash/XIP care‑abouts**

-   You may **rewind/tune QSPI clocks at runtime**; swap opcodes per CS thanks to QMI’s **banked config**.

-   Run any XIP re‑entry tweaks from **SRAM** (≤256 B) per the recommended **XIP setup function** pattern.

---

## **5\) Image signing, versioning & rollback**

-   **Signing:** enable **boot signing enforced by mask ROM**, store **key fingerprint in OTP**. Loader verifies program images similarly.

-   **Rollback protection:** maintain a **monotonic rollback version** (OTP \+ manifest). Images must be **properly signed** and have **rollback version ≥ OTP** to be accepted.

-   **A/B policy:** write inactive, verify, mark pending, reboot, confirm (WDT clears pending). On failure, auto‑rollback.

---

## **6\) Developer‑facing protocol (host ↔ RP2354)**

**Control plane**

-   `ENUMERATE`, `SETUP_PORT(type, params)`, `OPEN/LOSE`, `SET_SPI_CLOCK`, `I2C_SCAN`, `GPIO_MODE`, `GET_STATS`, `SYS_INFO`, `FW_UPDATE`, `REBOOT`, `ENTER_BOOTSEL` (if a GPIO can assert CSn‑low externally).

**Data plane**

-   **SPI:** queue read/write jobs; response carries status and payload.

-   **I²C:** compose TxRx sequences with repeated starts; explicit **timeouts** and **stretch** flags.

-   **UART:** open a **stream channel**; RX is push, TX is credit‑based to avoid overruns.

**Safety & introspection**

-   Per‑port **timeouts/limits**; global **watchdog**; monotonic **counters** for errors, NACKs, CRC fails; optional **trace ring** in SRAM.

---

## **7\) Bring‑up & test plan**

1. **Silicon sanity:** clocks/PLLs; USB BOOTSEL verified over **12 MHz XOSC** (or program the OTP PLL/XOSC if non‑12 MHz).

2. **XIP:** confirm internal flash boots; validate **XIP setup** path and **QMI** CS0/CS1 opcodes/clocks.

3. **Host SPI loopback:** DMA, rings, CRC, IRQ.

4. **PIO‑SPI timing:** sweep SCK 50 kHz→20 MHz, verify no host stalls while dev SPI runs slow.

5. **I²C:** 100/400/1 MHz Fmp; scan, stress with clock‑stretch devs.

6. **UART:** 9.6 k→3 Mbaud with RX overrun tests.

7. **Updater:** write to inactive slots, power‑pull during erase/program, ensure **rollback** works.

8. **Security:** sign/verify; reject unsigned/old‑version images.

9. **Long‑haul soak:** mixed traffic on all ports \+ periodic flash writes.

---

## **8\) Project structure (Pico SDK)**

-   `boot/` minimal pre‑init, XIP setup (`PICO_EMBED_XIP_SETUP=1`).

-   `loader/` (internal flash A/B): host‑SPI updater, manifest manager, slot chooser, recovery.

-   `program/` (external CS1 A/B): bridging services, schedulers, HAL for SPI/I²C/UART, PIO programs.

-   `common/` CRC, msg framing, logging, monotonic counters.

-   `secure/` key handling, image verifier, OTP helpers.

-   `tests/` HIL scripts; fuzzers for framing.

---

## **9\) Does this align with RP2354 capabilities?**

Yes—this design is explicitly built on:

-   **Internal 2 MB flash‑in‑package** for the loader.

-   **QMI/XIP** with **two chip selects**, **banked configs**, per‑CS **SCK** (changeable even while XIP is running), and **address translation** for multi‑slot images.

-   **PIO** examples for SPI/UART to implement flexible dev‑bus timing.

-   **BOOTSEL** USB/UART for last‑ditch recovery, selectable via CSn/SD1.

-   **Secure boot/OTP** and **rollback** features for safe OTA.

---

## **10\) Next steps (practical)**

1. **Define manifests** (`.json` or TLV) for loader/program: {slot, version, rollback, algo, hash, sig, size}.

2. **Prototype host link** on a NUC/PI with a simple Python tool (spidev) to exercise ENUMERATE/LOG.

3. **Stand up PIO‑SPI** with a rate‑sweep demo to validate rate isolation.

4. **Lay out flash maps** (internal A/B; external A/B) and the **QMI translation windows** you’ll use.

# Dynamic loading of PIO programs

You can stream a PIO program over SPI and load/run it at runtime. Practically, you’ll just need a tiny “PIO manager” in your RP2354 firmware that:

-   accepts a program blob from the host (over your SPI link),

-   allocates instruction-memory space in one of the PIO blocks,

-   relocates the program to the chosen offset (so jumps/wrap points are correct),

-   configures a state machine (pins, sideset, clock div, FIFO join, shift config),

-   and then starts the SM(s).

Here’s the shape of it and the gotchas to watch for.

# **What “dynamic” means on RP235x PIO**

-   PIO programs always execute from the PIO’s internal instruction memory. Loading “on the fly” means you copy opcodes into that memory at runtime (it’s fast).

-   You can keep multiple programs resident (space permitting) and start/stop SMs that point to different regions.

-   If you need to replace/patch a program, stop the SMs that use those instructions, write the new opcodes, then re‑init the SM(s).

# **Minimal runtime loader design**

1. **Wire protocol (host → RP2354 over SPI)**  
    Define a simple header \+ payload, e.g.:

    - `magic`, `version`

    - `pio_index` (0/1), desired `sm_mask`

    - `pin_base`, `pin_count`, `sideset_bits`, `in_pins`, `out_pins`

    - `clk_div` (fixed‑point), `instr_count`

    - `reloc_table_count` \+ entries (optional—see “Relocation” below)

    - `wrap_target` and `wrap`

    - `program bytes[]` (16‑bit PIO opcodes)

    - CRC32

2. **Program storage \+ integrity**

    - Receive into a RAM buffer, CRC check, then proceed.

    - Optional: keep a small cache of the last N programs if you expect reuse.

3. **Instruction-memory allocation**

    - Treat PIO IMEM like a tiny heap (per PIO). On RP2040 it’s 32 instructions per PIO; RP235x is in the same ballpark. Manage it as fixed‑size blocks or a simple first‑fit allocator.

    - Ensure the region you pick doesn’t overlap any currently running program. If it does, stop those SMs first (or reject).

4. **Relocation**

    - The assembler normally emits code assuming `origin 0`. When you place at `offset k`, all _absolute_ instruction addresses (e.g., `JMP label`, `SET PINDIRS`, etc.) referencing instruction addresses must be adjusted by `+k`.

    - If you use the Pico SDK’s `pio_add_program_at_offset()`, it will relocate using the metadata compiled by `pioasm`. If you’re sending raw opcodes from a PC tool, either:

        - also send the `wrap_target`, `wrap`, and relocation fixups in your header, or

        - do the relocation host‑side (generate at the actual offset you want), or

        - implement the same fixups device‑side (add `k` to any instruction with an address field).

    - After writing opcodes to IMEM, program `PIOx->SM[y].EXECCTRL.WRAP/WRAP_TOP` (or via SDK helpers).

5. **State machine bring‑up**

    - Claim one or more SMs (`sm_mask`) that are idle.

    - Use a config template (SDK: `pio_sm_config c = pio_get_default_sm_config();`), then set:

        - wrap/target to your `wrap` values

        - `clkdiv`

        - IN/OUT shift config

        - sideset count/opt enable

        - pin mapping (set pins before enabling the SM)

    - Load any needed initial data via TX FIFO (or DMA), then `pio_sm_set_enabled(pio, sm, true)`.

6. **Concurrency rules**

    - You can load IMEM while other SMs (pointing to _other_ addresses) keep running.

    - **Stop** any SMs whose program region you are about to overwrite.

    - Guard with a mutex/critical section—your SPI IRQ handler and the PIO manager should not interleave writes.

# **Safety \+ robustness**

-   **Pin reservations:** keep a pin ownership map so a downloaded PIO program can’t hijack pins you’ve reserved for NFC/touch/mmWave.

-   **Watchdog \+ rollback:** if a downloaded program is meant to “take over” a port and then signal alive, keep a watchdog so a bad program can’t brick your expansion services. On timeout, unload/disable it and revert to a safe default.

-   **Resource caps:** limit instruction count, sideset width, and which SMs/pins a program can touch. Reject if outside policy.

-   **Versioning:** store a `program_id` and `version` so the host can ask “is X already resident?” to avoid reloading.

# **Host-side tooling**

-   Easiest path: compile PIO source with `pioasm` on your build machine, ship the generated metadata (program bytes \+ wrap \+ reloc info) over SPI. Then your device uses SDK‑like relocation.

-   For a _super simple_ protocol, pre‑bake programs at fixed offsets (A/B “slots” in IMEM) and only allow updates that fit those slots—no allocator or relocation needed. Downside: less flexible.

# **Alternatives to consider**

-   **Multiple resident variants:** If you have “slow SPI” vs “fast SPI” variants (e.g., for a developer choosing a slow peripheral), keep both programs resident and switch SM configs/pointers instead of reloading.

-   **PIO as service library:** For common buses (I²C, UART, 1‑Wire, WS2812), keep well‑tested cores permanently resident and expose parameters (pins, frequency) via control registers/FIFOs so most users never need to ship custom PIO.

# **TL;DR**

-   Yes, you can dynamically load PIO programs at runtime from data sent over SPI.

-   You’ll implement a small loader: receive → (optionally) relocate → write IMEM → configure SM → run.

-   Mind instruction-memory allocation, relocation, pin/security policy, and stopping any SMs that point at a region you’re rewriting.
