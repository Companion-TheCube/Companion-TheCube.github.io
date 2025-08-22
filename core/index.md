---
title: TheCube CORE
description: Responsibilities, boundaries, and high-level components.
nav_order: 3
has_children: true
parent: null
permalink: /core/
---

# TheCube CORE

The **CORE** is the heart of TheCube. It is the runtime environment that manages everything from system boot to app communication and security.  
If you think of TheCube as a small operating system, the Core is the layer that:  

- Boots and initializes the system  
- Loads and supervises apps  
- Provides the **event bus** for communication  
- Enforces **permissions and sandboxing**  
- Connects apps to hardware (sensors, display, audio, expansion ports)  
- Handles configuration, logging, and updates  

This section explains how the CORE works and how developers can interact with it.

---

## CORE Responsibilities

- **System Management**  
  - Boot sequence and service orchestration  
  - Configuration management (network, preferences, personalities)  
  - Resource monitoring and performance tuning  

- **App Platform**  
  - App lifecycle (install, start, stop, update, remove)  
  - IPC (HTTP/JSON-RPC) for communication with apps  
  - Event bus for system-wide messaging  

- **Hardware Abstraction**  
  - Unified access to I²C, SPI, UART, CAN, GPIO, NFC, sensors, display, and audio  
  - CORE exposes safe APIs instead of apps touching raw hardware  

- **Security**  
  - Sandboxing apps with systemd + Landlock rules  
  - Permissions for hardware, network, and sensitive data  
  - Logging and audit capabilities  

---

## Subpages

TheCube-CORE is documented across several focused pages:

- [**Install**](/core/install/) — how to build, flash, and update custom CORE images  
- [**Architecture**](/core/architecture/) — block diagrams and conceptual layers  
- [**Boot Sequence**](/core/boot-sequence/) — init order, services, and fast-boot optimizations  
- [**Configuration**](/core/configuration/) — system settings, app manifests, and preferences  
- [**Event Bus**](/core/event-bus/) — how system and apps exchange messages  
- [**Lifecycle**](/core/lifecycle/) — install, start, stop, crash handling, health checks  
- [**Logging**](/core/logging/) — structured logs, spdlog conventions, rotation, debugging  
- [**Performance**](/core/performance/) — tuning for latency, resource use, and responsiveness  
- [**Security**](/core/security/) — sandboxing, capabilities, permissions, threat model  

---

## Next Steps

If you’re new to TheCube internals, start with [Architecture](/core/architecture/) to see how the CORE fits into the bigger picture.  

If you’re building your own system image, jump to [Install](/core/install/) for build and flashing instructions.