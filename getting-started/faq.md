---
title: FAQ
description: Common questions about TheCube, apps, and TheCube+.
nav_order: 5
parent: Getting Started
---

-   TOC
    {:toc}

---

# Frequently Asked Questions

Here are answers to some of the most common questions about **Companion, TheCube**.  
If you don’t see your question here, check the [Community Portal](/community/) for more help.

---

## General

### ❓ Does TheCube require the cloud?

No. TheCube works fully **offline** — speech recognition, apps, and notifications all run locally.  
The optional **TheCube+** service adds cloud features like account sync, larger AI models, and remote access.

---

### ❓ What is TheCube+?

**TheCube+** is our optional subscription service. It provides:

-   Account login and device linking
-   Extended AI models and cloud interactions
-   Usage quotas and tiered pricing
-   Optional self-host support for advanced users

👉 See [TheCube+ Overview](/thecube-plus/) for details.

---

### ❓ How do I reset my Cube?

For a full factory reset:
1. On the touchscreen, go to **Settings → System → Factory Reset**.
2. Confirm the reset. This will erase all data and settings. TheCube will reboot a few times during the process.

For a soft reset (reboot without losing data):
Either:
- On the touchscreen, go to **Settings → System → Reboot**.

OR

- Just unplug TheCube, wait 10 seconds, then plug it back in.

---

## Setup & Networking

### ❓ I can’t find `thecube.local`. What do I do?

Some networks don’t support `.local` addressing.

-   Try the direct **IP address** shown on the touchscreen or in the mobile app.
-   Or use your router’s device list to find TheCube by hostname.

---

### ❓ Can I use Ethernet instead of Wi-Fi?

Yes, but it requires either a USB to Ethernet adapter or the official Ethernet add-on module. See [Hardware Overview](/hardware/specs/) for details.

---

### ❓ How do I change Wi-Fi after setup?

Go to **Settings → Connections → Network** on the web UI (http://thecube.local) or touchscreen.  
Alternatively, reset onboarding by holding the power button for 10 seconds.

---

## Apps & Features

### ❓ How do I install new apps?

You can install apps from the **official catalog** or sideload them locally:

-   Open the **Apps** section in the web UI, the mobile app, or on the touchscreen.
-   Choose from available apps or upload a `.cubeapp` package.

👉 See [Installing Apps](/apps/install/) for details.

---

### ❓ Does TheCube listen to me all the time?

No. TheCube only listens for its wake word (“Hey Cube”) when **voice activation is enabled**.  
You can turn voice activation off at any time from the settings menu (but why would you want to? 😉 ).

---

### ❓ What built-in apps are included?

By default, TheCube comes with:

-   Timer & Alarms
-   Calendar & Reminders
-   Weather & News
-   Notes & Flashcards
-   Fun interactions (jokes, desk banter, personality quirks)
-   Healthy reminders (drink water, stretch)

👉 See [Built-in Apps](/apps/built-in/) for a full list.

---

## Hardware

### ❓ Can I open or mod my Cube?

Yes! TheCube is designed for tinkerers. Disassembly guides are provided in the [Hardware Section](/hardware/). Keep in mind that while TheCube was designed to be open up and tinkered with, doing so may void your warranty. A-McD Technology (TheCube's creator) is not responsible for any damage caused by opening or modifying your Cube.

---

### ❓ What expansion options are available?

TheCube exposes ports for **I²C, SPI, UART, CAN, and GPIO**, plus support for toppers and add-on modules.  
👉 See [Hardware Overview](/hardware/specs/) for details.

---

## Troubleshooting

### ❓ TheCube doesn't appear to be on. I just get a blank screen.

Try a few things:

-   Ensure the power supply is connected and plugged in. If so, unplug it and plug it back in.
-   Be sure to use the official power supply that came with TheCube or one that meets the required specifications (USB-C PD 45W or higher).
-   Check to see if the status LED on the back is on. If it is, compare the color to the [LED Status Guide](/hardware/led-status/) to see if it indicates an error.
-   If the LED is off, try a different power outlet or cable.

If these steps don't work, you can try asking for help from the [Community](/community/) or opening a [support request](/community/support/).

### ❓ My first voice command doesn’t work.

Make sure:

-   TheCube is ready. You should see the selected character on the screen and hear the startup chime.
-   Voice activation is enabled
-   You said “Hey Cube” before your command

Try speaking clearly and closer to the microphone on top of the device.

---

## Still Stuck?

-   Visit the [Community Forum](/community/) for help.
-   Check [Changelog](/changelog/) for recent fixes.
-   File a support request if you believe your Cube is defective.
