---
title: Getting Started
description: What TheCube is, what’s included, and how to use these docs.
nav_order: 2
has_children: true
parent: null
permalink: /getting-started/
---

# Getting Started

Welcome to **TheCube** — a 10 cm desktop companion built to be **open, extensible, and full of personality**.  
This section will help you understand the big picture before you dive into setup or development.

---

## What is TheCube?

At its core, TheCube is a **desktop assistant powered by a Raspberry Pi 5**.  
It combines **hardware, software, and AI** into a modular platform that can:  

- Run **apps** that extend its abilities  
- Provide **local AI assistance** with no required cloud connection  
- Support **expansion ports** and toppers for hardware tinkering  
- Express itself through **characters and personality modes**

TheCube is not just a device — it’s meant to be a **companion on your desk**, blending productivity and playfulness.

---

## TheCube-Core

The **Core** is the system runtime that ties everything together.  
It’s responsible for:  

- Boot and initialization  
- Managing the app lifecycle  
- Routing messages over the event bus  
- Handling security and sandboxing
- Providing APIs for apps to interact with hardware and AI
- Managing user preferences and settings
- Enabling communication with TheCube+ cloud services (if opted in)
- Serving as the foundation for all TheCube functionality

Think of the Core as the **operating system layer** for TheCube.

👉 Learn more in the [TheCube-Core Overview](/core/)

---

## Apps

Apps bring TheCube to life. They can:  

- Add productivity tools (timers, reminders, email summaries)  
- Connect external devices (stream decks, sensors, smart lights)  
- Provide entertainment (games, animations, playful interactions)  

Apps run in a **sandboxed environment** and communicate with the Core through APIs and events.  

👉 Explore the [App Platform Overview](/apps/)

---

## TheCube+

While TheCube works completely offline, **TheCube+** adds optional cloud features:  

- Account management & device syncing  
- Access to larger AI models  
- Cloud storage for history and preferences  
- Usage quotas and subscription tiers  

You can use TheCube standalone, or opt into TheCube+ if you want **extra power and convenience**.  

👉 Details here: [TheCube+ Overview](/thecube-plus/)

---

## Next Steps

Ready to begin? Follow the onboarding path:

1. **[Install](/getting-started/install/)** — set up TheCube hardware & software  
2. **[Quickstart](/getting-started/quickstart/)** — power on and say hello  
3. **[FAQ](/getting-started/faq/)** — answers to common questions  

---

💡 Tip: If you’re a **developer**, you can skip ahead to the [SDK section](/sdk/) and start building your first app right away.