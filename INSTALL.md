# Auto-run on Linux Boot <sub>(Without Login)</sub>

[Korean](INSTALL.ko.md)

- To automatically run a program immediately after Linux boots, regardless of login, it must be registered as a **systemd system service**.

<br />

---

## 1. Why Other Methods Do Not Work

| Method                | Login Required | Auto Run on Boot |
| --------------------- | -------------- | ---------------- |
| nohup, disown         | Required       | Not possible     |
| systemd --user        | Required (linger needed) | Limited |
| systemd system service| Not required   | Yes              |

- `nohup`, `tmux`, and `screen` require a terminal or login session.
- `systemd --user` depends on a user session.
- Only **systemd system services** can run automatically at boot without login.

<br />

---

## 2. Standard Setup Method

### 2.1. Create a systemd system service (root)

- Create the service file:
   - `sudo vim /etc/systemd/system/hello-core.service`

- `system/hello-core.service` file:
```ini
[Unit]
Description=hello daemon (core dump enabled)
After=network.target

[Service]
Type=simple
# Executable path
WorkingDirectory=/home/jaytwo/workspace
ExecStart=/home/jaytwo/workspace/hello  # Must have +x permission for the user below

Restart=always          # Always restart regardless of exit reason
# Restart=on-failure    # Restart only on abnormal termination
RestartSec=60           # Restart delay (seconds)
# StartLimitIntervalSec=60 StartLimitBurst=5  # Prevent infinite restart loops

LimitCORE=infinity      # Unlimited core dump size

User=jaytwo             # Linux user
Group=jaytwo            # Group (optional, check via groups or id)

[Install]
WantedBy=multi-user.target  # Normal server state (no GUI required)
```

- When `Restart=on-failure` triggers:
   - Process exits with non-zero exit code
   - Terminated by a signal (SIGSEGV, SIGABRT, etc.)
   - Watchdog timeout occurs
   - Killed by OOM (Out-Of-Memory) killer

<br />

---

### 2.2. Register and Start the Service (root, once)

```bash
sudo systemctl daemon-reload
sudo systemctl enable hello-core.service
sudo systemctl start hello-core.service
```

- `sudo systemctl daemon-reload`: Reload service files into memory
- `sudo systemctl enable hello-core.service`: Enable auto-start at boot
- `sudo systemctl start hello-core.service`: Start the service (use `stop` to stop)

<br />

- Check status:

```bash
systemctl status hello-core.service
```

<br />

- View logs:

```bash
journalctl -u hello-core.service -f
```

<br />

---

## 3. Requirements for Core Dump Generation

1. Kernel configuration:

   ```bash
   cat /proc/sys/kernel/core_pattern
   ```

   Example: `core.%e.%p.%t`

2. Write permission in the execution directory  
   `/home/jaytwo/workspace`

3. Core size limit removed  
   `LimitCORE=infinity` in systemd service

<br />

---

## 4. Overall Flow Summary

```
Linux boot
 → kernel
 → systemd (PID 1)
     → hello-core.service starts
         → core dump generated on crash
```

Login, bash, or SSH are not required.

<br />

---

## 5. Summary

To run a program automatically after boot without login,  
registering it as a **systemd system service** is the only correct and standard approach.
