package gatescript

import (
	"context"

	"github.com/tetratelabs/wazero"
	"github.com/tetratelabs/wazero/api"
)

// hostfunc.go builds the shared "tendant" host module (instantiated once per
// runtime). Each shim reads the per-call *HostCallbacks from context and
// marshals memory per the v1 ABI (contracts/abi.md). Read functions that return
// data allocate a fresh guest region via the guest's tendant_alloc export and
// return a packed (ptr<<32|len) i64; functions returning a scalar/void do not.
//
// A host-callback error or a missing grant traps the script via panic; wazero
// surfaces the panic as the evaluate() call error, and the runner converts it
// to fail_closed_host_error (the trace + HostError context survive on the
// per-call HostCallbacks).

// hostTrap is the panic sentinel used to trap the guest on a host-side failure.
type hostTrap struct{ reason string }

func (r *WazeroRunner) instantiateHostModule(ctx context.Context) error {
	b := r.runtime.NewHostModuleBuilder(HostModule)

	// call.get() -> i64 (packed ptr/len)
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module) uint64 {
		hc := mustHC(ctx, "call.get")
		requireGrant(hc, "call.args", "call", "get")
		return writeToGuest(ctx, mod, hc.CallJSON)
	}).Export("call.get")

	// contacts.isKnown(addr_ptr i32, addr_len i32) -> i32
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module, addrPtr, addrLen uint32) uint32 {
		hc := mustHC(ctx, "contacts.isKnown")
		requireGrant(hc, "contacts", "contacts", "isKnown")
		addr := readGuestString(mod, addrPtr, addrLen)
		known, err := hc.ContactKnown(ctx, addr)
		if err != nil {
			hc.recordHostError("contacts", "isKnown", sqlState(err))
			panic(hostTrap{"contacts.isKnown"})
		}
		if known {
			return 1
		}
		return 0
	}).Export("contacts.isKnown")

	// calendar.query(ws_ptr, ws_len, we_ptr, we_len) -> i64
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module, wsPtr, wsLen, wePtr, weLen uint32) uint64 {
		hc := mustHC(ctx, "calendar.query")
		requireGrant(hc, "calendar", "calendar", "query")
		start := readGuestString(mod, wsPtr, wsLen)
		end := readGuestString(mod, wePtr, weLen)
		data, err := hc.Calendar(ctx, start, end)
		if err != nil {
			hc.recordHostError("calendar", "query", sqlState(err))
			panic(hostTrap{"calendar.query"})
		}
		return writeToGuest(ctx, mod, data)
	}).Export("calendar.query")

	// task.context(key_ptr, key_len) -> i64 (empty ptr/len when unset)
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module, keyPtr, keyLen uint32) uint64 {
		hc := mustHC(ctx, "task.context")
		requireGrant(hc, "task.context", "task", "context")
		key := readGuestString(mod, keyPtr, keyLen)
		data, ok, err := hc.TaskContext(ctx, key)
		if err != nil {
			hc.recordHostError("task", "context", sqlState(err))
			panic(hostTrap{"task.context"})
		}
		if !ok {
			return 0
		}
		return writeToGuest(ctx, mod, data)
	}).Export("task.context")

	// owner.rule(key_ptr, key_len) -> i64 (empty ptr/len when unset)
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module, keyPtr, keyLen uint32) uint64 {
		hc := mustHC(ctx, "owner.rule")
		requireGrant(hc, "owner.rule", "owner", "rule")
		key := readGuestString(mod, keyPtr, keyLen)
		data, ok, err := hc.OwnerRule(ctx, key)
		if err != nil {
			hc.recordHostError("owner", "rule", sqlState(err))
			panic(hostTrap{"owner.rule"})
		}
		if !ok {
			return 0
		}
		return writeToGuest(ctx, mod, data)
	}).Export("owner.rule")

	// log(msg_ptr, msg_len) -> () — always available, no grant required.
	b.NewFunctionBuilder().WithFunc(func(ctx context.Context, mod api.Module, msgPtr, msgLen uint32) {
		hc := hostCallbacksFrom(ctx)
		if hc == nil || hc.trace == nil {
			return
		}
		hc.trace.append(readGuestString(mod, msgPtr, msgLen))
	}).Export("log")

	_, err := b.Instantiate(ctx)
	return err
}

// mustHC fetches the per-call callbacks or traps if absent (a programming error
// — the Service always attaches them).
func mustHC(ctx context.Context, fn string) *HostCallbacks {
	hc := hostCallbacksFrom(ctx)
	if hc == nil {
		panic(hostTrap{fn + ": no host callbacks"})
	}
	return hc
}

// requireGrant is defense-in-depth: even though static validation rejects
// undeclared imports at upload, a host function whose capability the manifest
// did not grant traps at runtime.
func requireGrant(hc *HostCallbacks, capability, module, name string) {
	if !hc.Grants[capability] {
		hc.recordHostError(module, name, "")
		panic(hostTrap{module + "." + name + ": capability not granted"})
	}
}

// writeToGuest allocates a guest region via tendant_alloc, writes data into it,
// and returns the packed (ptr<<32|len). An empty payload returns 0 (the guest
// reads this as "no value"). A failed alloc/write traps.
func writeToGuest(ctx context.Context, mod api.Module, data []byte) uint64 {
	if len(data) == 0 {
		return 0
	}
	alloc := mod.ExportedFunction("tendant_alloc")
	if alloc == nil {
		panic(hostTrap{"guest missing tendant_alloc export"})
	}
	res, err := alloc.Call(ctx, uint64(len(data)))
	if err != nil || len(res) != 1 {
		panic(hostTrap{"tendant_alloc failed"})
	}
	ptr := uint32(res[0])
	if !mod.Memory().Write(ptr, data) {
		panic(hostTrap{"guest memory write out of bounds"})
	}
	return (uint64(ptr) << 32) | uint64(len(data))
}

func readGuestString(mod api.Module, ptr, length uint32) string {
	if length == 0 {
		return ""
	}
	buf, ok := mod.Memory().Read(ptr, length)
	if !ok {
		return ""
	}
	return string(buf)
}

// ensure the builder type is referenced (keeps wazero import honest if the
// host module is ever refactored to a no-arg form).
var _ = wazero.NewRuntimeConfig
