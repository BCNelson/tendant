package gate

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// RoutineGrantLookup is the seam the Phase-8 autonomy layer uses to check
// whether a (tool, routine fingerprint) carries a live auto-approval grant. It
// mirrors PrincipalLookup so the gate stays pure (no direct DB): production
// backs it with internal/db.LiveGrantExists, tests with an in-memory stub.
type RoutineGrantLookup interface {
	HasLiveGrant(ctx context.Context, toolID uuid.UUID, fingerprint string) (bool, error)
}

// autonomyApprove implements the Phase-8 autonomy layer. It returns approved=
// true ONLY when the tool is in the EXECUTE_AUTO band AND the call's routine
// fingerprint has a live grant. It NEVER denies — it can only auto-approve or
// fall through, so it cannot weaken any other layer. The caller invokes it after
// the floor cleared and after the script's terminal verdicts, in the overseer's
// slot (research R7): floor supremacy (III) and no self-escalation (IV) hold by
// construction (the only score-raising path is the owner mutation).
func (g *DefaultGate) autonomyApprove(ctx context.Context, call *ToolCall, tool *db.Tool) (bool, json.RawMessage, error) {
	if g.Grants == nil {
		return false, nil, nil
	}
	if calibration.Band(tool.TrustScore) != calibration.LevelExecuteAuto {
		return false, nil, nil
	}
	fp := calibration.Fingerprint(tool.GlobalUri, call.Payload)
	live, err := g.Grants.HasLiveGrant(ctx, call.ToolID, fp)
	if err != nil {
		return false, nil, err
	}
	if !live {
		return false, nil, nil
	}
	ctxJSON, _ := json.Marshal(map[string]any{
		"layer":               "autonomy",
		"band":                string(calibration.LevelExecuteAuto),
		"routine_fingerprint": fp,
		"trust_score":         tool.TrustScore,
	})
	return true, ctxJSON, nil
}
