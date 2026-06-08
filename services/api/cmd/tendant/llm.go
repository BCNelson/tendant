package main

import (
	"log/slog"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/llm"
)

// buildLLMRegistry constructs the named-connection registry from the
// file-defined [[llm_connections]] entries. Credential fields arrive already
// resolved — config.Load expands any ${env:...}/${file:...} interpolation — so
// they pass straight through. A connection that fails to build is logged and
// skipped; a missing overseer connection later fails closed to LogProvider.
func buildLLMRegistry(cfg *config.Config) *llm.Registry {
	reg := llm.NewRegistry()
	for _, def := range cfg.LLMConnections {
		conn := llm.Connection{
			Name:            def.Name,
			Provider:        def.Provider,
			BaseURL:         def.BaseURL,
			Model:           def.Model,
			APIKey:          def.APIKey,
			Region:          def.Region,
			AccessKeyID:     def.AccessKeyID,
			SecretAccessKey: def.SecretAccessKey,
			SessionToken:    def.SessionToken,
		}
		if err := reg.Register(conn); err != nil {
			slog.Error("llm: skipping connection", "name", def.Name, "err", err)
			continue
		}
		slog.Info("llm.connection registered", "name", def.Name, "provider", def.Provider, "model", def.Model)
	}
	return reg
}
