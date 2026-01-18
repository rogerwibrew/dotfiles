/* See LICENSE file for copyright and license details. */
/* dwm configuration - minimal setup for Debian Stable */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrains Mono:size=10" };
static const char dmenufont[]       = "JetBrains Mono:size=10";

/* colors - simple dark theme */
static const char col_gray1[]       = "#222222";  /* bar background */
static const char col_gray2[]       = "#444444";  /* inactive border */
static const char col_gray3[]       = "#bbbbbb";  /* inactive text */
static const char col_gray4[]       = "#eeeeee";  /* active text */
static const char col_cyan[]        = "#005577";  /* active border/tag bg */
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging - workspaces */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "Firefox",  NULL,       NULL,       1 << 1,       0,           -1 },
	{ "Chromium", NULL,       NULL,       1 << 1,       0,           -1 },
	{ "Steam",    NULL,       NULL,       1 << 4,       1,           -1 },
};

/* layout(s) - only master/stack and monocle needed */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default: master/stack */
	{ "[M]",      monocle }, /* fullscreen/monocle */
	{ "><>",      NULL },    /* floating - rarely used but keep for edge cases */
};

/* key definitions */
#define MODKEY Mod4Mask  /* Super key */
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "kitty", NULL };

/* custom commands */
static const char *browsercmd[]  = { "flatpak", "run", "org.chromium.Chromium", NULL };
static const char *lockcmd[]     = { "slock", NULL };
static const char *screenshot[]  = { "scrot", "-s", NULL };  /* select area */
static const char *screenshotfull[] = { "scrot", NULL };     /* full screen */

/* volume control */
static const char *volup[]   = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%", NULL };
static const char *voldown[] = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%", NULL };
static const char *volmute[] = { "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle", NULL };

/* brightness control */
static const char *brightup[]   = { "brightnessctl", "set", "+10%", NULL };
static const char *brightdown[] = { "brightnessctl", "set", "10%-", NULL };

static const Key keys[] = {
	/* modifier                     key        function        argument */

	/* Application launchers */
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      spawn,          {.v = browsercmd } },

	/* Window management */
	{ MODKEY,                       XK_w,      killclient,     {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_Return, zoom,           {0} },  /* swap to master */
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_o,      incnmaster,     {.i = -1 } },

	/* Layouts */
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} }, /* tiled */
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} }, /* monocle */
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },

	/* Bar toggle */
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },

	/* Monitor navigation (for multi-monitor) */
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },

	/* View all tags */
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_Tab,    view,           {0} },  /* toggle previous tag */

	/* Workspace/tag keys */
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)

	/* System */
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY|ControlMask,           XK_l,      spawn,          {.v = lockcmd } },

	/* Screenshots */
	{ 0,                            XK_Print,  spawn,          {.v = screenshot } },
	{ ShiftMask,                    XK_Print,  spawn,          {.v = screenshotfull } },

	/* Volume (XF86 keys) */
	{ 0, XF86XK_AudioRaiseVolume,              spawn,          {.v = volup } },
	{ 0, XF86XK_AudioLowerVolume,              spawn,          {.v = voldown } },
	{ 0, XF86XK_AudioMute,                     spawn,          {.v = volmute } },

	/* Brightness (XF86 keys) */
	{ 0, XF86XK_MonBrightnessUp,               spawn,          {.v = brightup } },
	{ 0, XF86XK_MonBrightnessDown,             spawn,          {.v = brightdown } },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
