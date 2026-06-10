package agent

import (
	"context"
	"errors"
	"strings"
	"testing"
)

type stubMatcher struct {
	matches []CategoryMatch
	err     error
	gotK    int
}

func (s *stubMatcher) TopCategories(_ context.Context, _ string, k int) ([]CategoryMatch, error) {
	s.gotK = k
	return s.matches, s.err
}

func countLines(s, prefix string) int {
	n := 0
	for _, line := range strings.Split(s, "\n") {
		if strings.HasPrefix(line, prefix) {
			n++
		}
	}
	return n
}

// When a Matcher returns hits, only those top-K categories are injected.
func TestAppendTaxonomy_MatcherNarrows(t *testing.T) {
	m := &stubMatcher{matches: []CategoryMatch{
		{Key: "communication/email", Label: "Email"},
		{Key: "engineering", Label: "Engineering"},
	}}
	r := &Runner{Matcher: m, TriageTopK: 2} // nil Queries: proves the full path isn't used
	out := r.appendTaxonomy(context.Background(), "BASE", "reply to the email from bob")

	if !strings.Contains(out, "[TASK_CATEGORIES]") {
		t.Fatalf("missing taxonomy header:\n%s", out)
	}
	if !strings.Contains(out, "communication/email") || !strings.Contains(out, "engineering") {
		t.Fatalf("missing matched keys:\n%s", out)
	}
	if got := countLines(out, "- "); got != 2 {
		t.Fatalf("expected 2 category lines, got %d:\n%s", got, out)
	}
	if m.gotK != 2 {
		t.Fatalf("expected k=2 passed to matcher, got %d", m.gotK)
	}
}

// TriageTopK<=0 defaults to 10.
func TestAppendTaxonomy_DefaultK(t *testing.T) {
	m := &stubMatcher{matches: []CategoryMatch{{Key: "x"}}}
	r := &Runner{Matcher: m} // TriageTopK unset
	_ = r.appendTaxonomy(context.Background(), "BASE", "text")
	if m.gotK != 10 {
		t.Fatalf("expected default k=10, got %d", m.gotK)
	}
}

// A matcher error falls through; with nil Queries the prompt is returned as-is.
func TestAppendTaxonomy_MatcherErrorFallsBack(t *testing.T) {
	r := &Runner{Matcher: &stubMatcher{err: errors.New("embed down")}}
	out := r.appendTaxonomy(context.Background(), "BASE", "text")
	if out != "BASE" {
		t.Fatalf("expected unmodified prompt on matcher error + nil Queries, got:\n%s", out)
	}
}

// No matcher + nil Queries ⇒ unmodified prompt (best-effort).
func TestAppendTaxonomy_NoMatcherNoQueries(t *testing.T) {
	r := &Runner{}
	if out := r.appendTaxonomy(context.Background(), "BASE", "text"); out != "BASE" {
		t.Fatalf("expected unmodified prompt, got:\n%s", out)
	}
}
