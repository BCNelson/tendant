// Package router implements the agent routing logic: deterministic eligibility
// pruning (boolean expression grammar over Findings.Structured) followed by an
// LLM pick among survivors. The human is always an eligible candidate,
// synthesized by the router rather than stored as an agent_configs row.
package router
