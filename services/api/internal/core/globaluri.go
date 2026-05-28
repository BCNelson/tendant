// Package core hosts domain helpers that don't fit cleanly in the DB or HTTP
// layers — globalUri formatters and the idempotent owner-Principal seed.
package core

import "github.com/google/uuid"

// Owner is the canonical globalUri of the single owner Principal. The seed
// path upserts a Principal with this URI on every boot.
const OwnerPrincipalURI = "local://principal/owner"

// TaskURI formats the federation-shaped globalUri for a Task id (Principle VIII).
func TaskURI(id uuid.UUID) string {
	return "local://task/" + id.String()
}

// PrincipalURI formats the federation-shaped globalUri for a Principal id.
func PrincipalURI(id uuid.UUID) string {
	return "local://principal/" + id.String()
}
