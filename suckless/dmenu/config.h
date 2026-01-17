/* See LICENSE file for copyright and license details. */
/* dmenu configuration - minimal setup matching dwm colors */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"JetBrains Mono:size=10"
};
static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */

/* colors - match dwm */
static const char col_gray1[]  = "#222222";  /* background */
static const char col_gray3[]  = "#bbbbbb";  /* foreground */
static const char col_gray4[]  = "#eeeeee";  /* selected foreground */
static const char col_cyan[]   = "#005577";  /* selected background */

static const char *colors[SchemeLast][2] = {
	/*                  fg          bg       */
	[SchemeNorm]    = { col_gray3,  col_gray1 },
	[SchemeSel]     = { col_gray4,  col_cyan  },
	[SchemeOut]     = { "#000000",  "#00ffff" },
};

/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " gy/telegh"
 */
static const char worddelimiters[] = " ";
