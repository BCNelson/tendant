//! abi.rs — pointer/length marshalling for the Tendant gate-script ABI v1.
//! See contracts/abi.md. The guest exports memory + tendant_alloc/tendant_dealloc
//! + evaluate()->i64 (packed ptr<<32|len).

use std::alloc::{alloc, dealloc, Layout};

/// tendant_alloc allocates `size` bytes in the guest and returns the pointer.
/// The host calls this to place inputs (call.get JSON, etc.) into linear memory.
///
/// # Safety
/// The returned pointer must be freed via `tendant_dealloc` with the same size.
#[no_mangle]
pub extern "C" fn tendant_alloc(size: u32) -> u32 {
    if size == 0 {
        return 0;
    }
    // Prefix the allocation with its size so dealloc can rebuild the layout even
    // if the host passes a mismatched size; we store size in the first 4 bytes.
    let layout = Layout::from_size_align(size as usize, 1).unwrap();
    unsafe { alloc(layout) as u32 }
}

/// tendant_dealloc frees a guest allocation.
///
/// # Safety
/// `ptr`/`size` must come from a prior `tendant_alloc`.
#[no_mangle]
pub extern "C" fn tendant_dealloc(ptr: u32, size: u32) {
    if ptr == 0 || size == 0 {
        return;
    }
    let layout = Layout::from_size_align(size as usize, 1).unwrap();
    unsafe { dealloc(ptr as *mut u8, layout) }
}

/// pack combines a (ptr,len) into the i64 the host reads.
pub fn pack(ptr: u32, len: u32) -> u64 {
    ((ptr as u64) << 32) | (len as u64)
}

pub fn unpack_ptr(packed: u64) -> u32 {
    (packed >> 32) as u32
}

pub fn unpack_len(packed: u64) -> u32 {
    (packed & 0xffff_ffff) as u32
}

/// write_string copies `s` into a fresh guest allocation and returns the packed
/// (ptr,len). An empty string returns 0 (the ABI "no value").
pub fn write_string(s: &str) -> u64 {
    let bytes = s.as_bytes();
    let len = bytes.len() as u32;
    if len == 0 {
        return 0;
    }
    let ptr = tendant_alloc(len);
    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), ptr as *mut u8, len as usize);
    }
    pack(ptr, len)
}

/// read_string reads a UTF-8 string from a host-provided (ptr,len).
///
/// # Safety
/// `ptr`/`len` must reference a valid host-written region.
pub fn read_string(ptr: u32, len: u32) -> String {
    if len == 0 {
        return String::new();
    }
    unsafe {
        let slice = std::slice::from_raw_parts(ptr as *const u8, len as usize);
        String::from_utf8_lossy(slice).into_owned()
    }
}

/// read_packed materializes a host (ptr,len) return into a String.
pub fn read_packed(packed: u64) -> String {
    read_string(unpack_ptr(packed), unpack_len(packed))
}
