---
title: Install
description: How to install TheCube hardware/software.
nav_order: 4
parent: TheCube CORE
---

# Installing TheCube-Core

TheCube-Core can be installed and updated in two ways:

1. **Automatic updates** — handled by the system itself (recommended for most users).
2. **Custom builds** — for developers who want to modify, extend, or debug the Core.

---

## Automatic Updates

By default, TheCube keeps its Core up to date automatically.

-   **Update channel**: stable (default), beta, or dev
-   **Schedule**: background check every 24h (configurable)
-   **Method**:
    -   Downloads a signed image of the new Core
    -   Writes it into the inactive **A/B partition slot**
    -   Verifies signature and checksum
    -   Switches active slot on next reboot

If the new Core fails to boot or crashes repeatedly, the system rolls back to the previous slot automatically.

### Checking update status

From the web UI:

1. Go to **Settings → System → Updates**
2. See current version, channel, and last check time
3. Click **Check for updates** to force a manual check
4. If an update is available, click **Install** and reboot when prompted
5. After reboot, verify the new version is active
6. If something goes wrong, the system will revert to the previous version automatically

### Changing update channel

To switch channels (e.g. from stable to beta):

1. Go to **Settings → System → Updates**
2. Select the desired channel from the dropdown
3. Click **Save** and the system will check for updates on that channel during the next scheduled check

### Disabling automatic updates

While not recommended, you can disable automatic updates:

1. Go to **Settings → System → Updates**
2. Toggle off **Automatic updates**
3. You can still check for and install updates manually

From CLI (developer mode):

```bash
CubeCore-settings-util --status
```

Forcing an update

```bash
CubeCore-settings-util --update
```

Changing channel

```bash
CubeCore-settings-util --set-channel beta
```

Disabling automatic updates

```bash
CubeCore-settings-util --disable-auto-update
```

Enabling automatic updates

```bash
CubeCore-settings-util --enable-auto-update
```

---

## Custom Builds

For developers, you can replace the stock Core with a custom build.
**This section is incomplete.** Please refer to the [GitHub repository](https://github.com/Comapnion-TheCube/core) for build instructions.