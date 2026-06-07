package model

import (
	"encoding/base64"
	"fmt"
	"io"

	"github.com/99designs/gqlgen/graphql"
)

// Bytes is the custom GraphQL `Bytes` scalar: a base64-encoded string carrying
// raw bytes (used for WASM module uploads/downloads). It mirrors the JSON
// scalar pattern — a hand-written marshaler bound via gqlgen.yml.
type Bytes []byte

// MarshalGQL writes the bytes as a base64 JSON string.
func (b Bytes) MarshalGQL(w io.Writer) {
	graphql.MarshalString(base64.StdEncoding.EncodeToString(b)).MarshalGQL(w)
}

// UnmarshalGQL decodes a base64 string into the byte slice. A non-string or
// invalid base64 input is an error (surfaced as a GraphQL input error).
func (b *Bytes) UnmarshalGQL(v interface{}) error {
	s, ok := v.(string)
	if !ok {
		return fmt.Errorf("Bytes must be a base64-encoded string, got %T", v)
	}
	data, err := base64.StdEncoding.DecodeString(s)
	if err != nil {
		return fmt.Errorf("Bytes: invalid base64: %w", err)
	}
	*b = data
	return nil
}
