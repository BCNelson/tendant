package auth

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
)

func TestRequireOwner(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name      string
		principal *Principal // nil means "no principal attached"
		wantErr   bool
	}{
		{name: "user kind succeeds", principal: &Principal{ID: uuid.New(), Kind: "user"}, wantErr: false},
		{name: "bot kind denied", principal: &Principal{ID: uuid.New(), Kind: "bot"}, wantErr: true},
		{name: "service kind denied", principal: &Principal{ID: uuid.New(), Kind: "service"}, wantErr: true},
		{name: "empty kind denied", principal: &Principal{ID: uuid.New(), Kind: ""}, wantErr: true},
		{name: "no principal attached", principal: nil, wantErr: true},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			ctx := context.Background()
			if tc.principal != nil {
				ctx = WithPrincipal(ctx, tc.principal)
			}
			got, err := RequireOwner(ctx)
			if tc.wantErr {
				if !errors.Is(err, ErrPermissionDenied) {
					t.Fatalf("want ErrPermissionDenied, got err=%v got=%v", err, got)
				}
				if got != nil {
					t.Fatalf("want nil principal on deny, got %+v", got)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got == nil || got.Kind != "user" {
				t.Fatalf("want user principal, got %+v", got)
			}
		})
	}
}
