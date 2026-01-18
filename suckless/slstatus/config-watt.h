/* See LICENSE file for copyright and license details. */
/* slstatus config for WATT (laptop - with battery) */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*
 * Laptop layout (watt):
 * Vol: 75% | Net: MyWiFi | Disk: 45% | CPU: 12% | RAM: 8.5G | Temp: 45°C | Bat: 85% | Sat 18 Jan  10:45
 *
 * Includes battery indicator
 */
static const struct arg args[] = {
	/* function format          argument */
	{ run_command,    "Vol: %s%% | ",  "pamixer --get-volume" },
	{ wifi_essid,     "Net: %s | ",    "wlan0" },
	{ disk_free,      "Disk: %s | ",   "/" },
	{ cpu_perc,       "CPU: %s%% | ",  NULL },
	{ ram_used,       "RAM: %s | ",    NULL },
	{ temp,           "Temp: %s°C | ", "/sys/class/thermal/thermal_zone0/temp" },
	{ battery_perc,   "Bat: %s%% | ",  "BAT0" },
	{ datetime,       "%s",            "%a %d %b  %H:%M" },
};
