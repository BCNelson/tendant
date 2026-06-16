// Package slogx defines tendant's custom slog extensions: a TRACE level below
// DEBUG for high-volume diagnostic output (e.g. raw LLM request/response
// bodies) that must stay off by default and only be enabled when actively
// debugging.
package slogx

import "log/slog"

// LevelTrace sits one step below slog.LevelDebug (-4). Records emitted at this
// level appear only when the handler threshold is set to "trace".
const LevelTrace = slog.Level(-8)

// ReplaceAttr names custom levels in handler output. slog renders an unknown
// level as "DEBUG-4" by default; this maps LevelTrace to "TRACE". Pass it as
// slog.HandlerOptions.ReplaceAttr.
func ReplaceAttr(_ []string, a slog.Attr) slog.Attr {
	if a.Key == slog.LevelKey {
		if lvl, ok := a.Value.Any().(slog.Level); ok && lvl == LevelTrace {
			a.Value = slog.StringValue("TRACE")
		}
	}
	return a
}
