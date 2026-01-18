# slstatus Configuration

slstatus is a lightweight status monitor for dwm that displays system
information in the dwm status bar (top right).

## Host-Specific Configs

- **config-kelvin.h** - Desktop (no battery indicator)
- **config-watt.h** - Laptop (includes battery indicator)

## Installation

The bootstrap script handles this automatically:

```bash
cd ~/dotfiles/suckless/slstatus
sudo make clean install
```

## What It Displays

### Kelvin (Desktop)
```
Vol: 75% | Net: MyWiFi | Disk: 45% | CPU: 12% | RAM: 8.5G | Temp: 45°C | Sat 18 Jan  10:45
```

### Watt (Laptop)
```
Vol: 75% | Net: MyWiFi | Disk: 45% | CPU: 12% | RAM: 8.5G | Temp: 45°C | Bat: 85% | Sat 18 Jan  10:45
```

## Modules (Left to Right)

1. **Volume** - Current audio volume (via pamixer)
2. **Network** - WiFi ESSID or connection status
3. **Disk** - Disk usage percentage or free space
4. **CPU** - CPU usage percentage
5. **RAM** - RAM used in GB
6. **Temperature** - CPU temperature
7. **Battery** - Battery percentage (watt only)
8. **Date/Time** - Same format as Waybar

## Customizing

Edit the appropriate config file (`config-kelvin.h` or `config-watt.h`),
then recompile:

```bash
cd ~/dotfiles/suckless/slstatus
sudo make clean install
```

The changes will appear after restarting dwm (Mod+Shift+Q and re-login).

## Dependencies

- `pamixer` - Volume control (in packages-debian.txt)
- Thermal zone files in `/sys/class/thermal/`
- WiFi interface (usually `wlan0`)

## Troubleshooting

### WiFi shows "n/a"
Your WiFi interface might not be `wlan0`. Check with:
```bash
ip link
```
Then update the interface name in config-*.h

### Temperature shows "n/a"
Check available thermal zones:
```bash
ls /sys/class/thermal/thermal_zone*/temp
```
Update the path in config-*.h to match your system.

### Volume shows "n/a"
Ensure pamixer is installed:
```bash
sudo apt install pamixer
```
