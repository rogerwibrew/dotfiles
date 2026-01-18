/* See LICENSE file for copyright and license details. */
/* slstatus config for KELVIN (desktop - no battery) */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*
 * Desktop layout (kelvin):
 * Vol: 75% | Net: MyWiFi | Disk: 45% | CPU: 12% | RAM: 8.5G | Temp: 45°C | Sat 18 Jan  10:45
 *
 * No battery indicator (desktop)
 */
static const struct arg args[] = {
	/* function format          argument */
	{ run_command, "Vol: %s%% | ", "pamixer --get-volume" },
	{ wifi_essid,  "Net: %s | ",   "wlan0" },
	{ disk_perc,   "Disk: %s%% | ", "/home" },
	{ cpu_perc,    "CPU: %s%% | ",  NULL },
	{ ram_used,    "RAM: %s | ",    NULL },
	{ temp,        "Temp: %s°C | ", "/sys/class/thermal/thermal_zone2/temp" },
	{ datetime,    "%s",            "%a %d %b  %H:%M" },
};
