// abi.ts — the pointer/length marshalling for the Tendant gate-script ABI v1.
// See contracts/abi.md. The guest exports memory + tendant_alloc/tendant_dealloc
// + evaluate()->i64 (packed ptr<<32|len). The host writes inputs into guest
// memory via tendant_alloc; the guest reads them and frees via tendant_dealloc.
//
// `heap` and `memory` are AssemblyScript global builtins — no import needed.

// tendant_alloc/tendant_dealloc are the host-callable memory-management exports.
// They use AssemblyScript's heap allocator directly so the host can place inputs
// (call.get JSON, etc.) into linear memory.
export function tendant_alloc(size: u32): u32 {
  return <u32>heap.alloc(size);
}

export function tendant_dealloc(ptr: u32, _size: u32): void {
  heap.free(<usize>ptr);
}

// pack combines a (ptr,len) into the i64 the host reads.
// @ts-ignore: u64 shift is valid in AssemblyScript
export function pack(ptr: u32, len: u32): u64 {
  return ((<u64>ptr) << 32) | (<u64>len);
}

// writeString UTF-8-encodes s into a fresh guest allocation and returns the
// packed (ptr,len). An empty string returns 0 (the ABI's "no value").
export function writeString(s: string): u64 {
  const buf = String.UTF8.encode(s);
  const len = <u32>buf.byteLength;
  if (len == 0) return 0;
  const ptr = tendant_alloc(len);
  memory.copy(<usize>ptr, changetype<usize>(buf), len);
  return pack(ptr, len);
}

// readString reads a UTF-8 string from a host-provided (ptr,len).
export function readString(ptr: u32, len: u32): string {
  if (len == 0) return "";
  return String.UTF8.decodeUnsafe(<usize>ptr, len);
}

// unpackPtr / unpackLen split a packed host return value.
export function unpackPtr(packed: u64): u32 { return <u32>(packed >> 32); }
export function unpackLen(packed: u64): u32 { return <u32>(packed & 0xffffffff); }
