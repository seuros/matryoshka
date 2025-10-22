use magnus::{function, Error, Ruby};
use matryoshka_demo_core;

/// Count prime numbers up to and including `limit`
/// Rust FFI wrapper for Ruby
fn count_primes_native(limit: i64) -> i64 {
    if limit < 0 {
        return 0;
    }

    let result = matryoshka_demo_core::count_primes(limit as usize);
    result as i64
}

/// Find the nth prime number (1-indexed)
/// Rust FFI wrapper for Ruby
fn nth_prime_native(n: i64) -> Option<i64> {
    if n <= 0 {
        return None;
    }

    matryoshka_demo_core::nth_prime(n as usize).map(|p| p as i64)
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("MatryoshkaDemoNative")?;

    module.define_module_function("count_primes", function!(count_primes_native, 1))?;
    module.define_module_function("nth_prime", function!(nth_prime_native, 1))?;

    Ok(())
}
