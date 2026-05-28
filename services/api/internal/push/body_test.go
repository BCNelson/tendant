package push_test

import (
	"reflect"
	"testing"

	"github.com/bcnelson/tendant/services/api/internal/push"
)

// TestPushBodyHasExactlyTwoFields enforces FR-015 / SC-003 structurally: the
// only fields the providers can ever marshal are DeepLinkID and GenericTitle.
// Adding a third field — e.g. "Description" — breaks this test.
func TestPushBodyHasExactlyTwoFields(t *testing.T) {
	t.Parallel()
	typ := reflect.TypeOf(push.PushBody{})

	if typ.NumField() != 2 {
		t.Fatalf("PushBody must have exactly 2 fields; got %d", typ.NumField())
	}
	got := map[string]bool{}
	for i := 0; i < typ.NumField(); i++ {
		got[typ.Field(i).Name] = true
	}
	for _, want := range []string{"DeepLinkID", "GenericTitle"} {
		if !got[want] {
			t.Fatalf("PushBody must have field %s; have %v", want, got)
		}
	}
}
