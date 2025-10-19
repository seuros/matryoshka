# Ruby → Rust Syntax Translation Guide

**Learn 40% of Rust by comparing it to Ruby you already know.**

---

## Philosophy

Rust and Ruby share more than you think:
- Expression-based (last line returns)
- Pattern matching (case/match)
- Iterators (map, filter, reduce)
- Closures (blocks/lambdas)

**The differences:**
- Rust requires types
- Rust enforces ownership
- Rust checks at compile-time

**This guide:** Side-by-side comparisons to minimize learning curve.

---

## Variables

### Declaration

**Ruby:**
```ruby
x = 42
name = "Alice"
```

**Rust:**
```rust
let x = 42;
let name = "Alice";
```

**Changes:**
- Add `let` keyword
- Add semicolons `;`

---

### Mutability

**Ruby** (always mutable):
```ruby
x = 10
x = 20  # ✅ works
```

**Rust** (immutable by default):
```rust
let x = 10;
x = 20;  // ❌ error: cannot assign twice to immutable variable

let mut x = 10;
x = 20;  // ✅ works
```

**Key insight:** Rust assumes immutability. Opt-in with `mut`.

---

### Type Annotations

**Ruby** (optional, for documentation):
```ruby
def add(a, b)
  a + b
end
```

**Rust** (required):
```rust
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

**Common types:**
| Ruby | Rust | Notes |
|------|------|-------|
| `Integer` | `i32`, `i64`, `u32`, `u64` | Sized integers |
| `Float` | `f32`, `f64` | 32/64-bit floats |
| `String` | `String`, `&str` | Owned vs borrowed |
| `true`/`false` | `true`/`false` | Same! |
| `nil` | `Option::None` | Explicit nullability |

---

## Functions

### Basic Function

**Ruby:**
```ruby
def greet(name)
  "Hello, #{name}!"
end
```

**Rust:**
```rust
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```

**Changes:**
- `fn` instead of `def`
- Type annotations required (`: &str`, `-> String`)
- `format!()` instead of string interpolation

---

### Implicit Return

**Ruby:**
```ruby
def add(a, b)
  a + b  # implicit return
end
```

**Rust:**
```rust
fn add(a: i32, b: i32) -> i32 {
    a + b  // implicit return (no semicolon!)
}
```

**Critical:** No semicolon on last expression = return value

**Wrong:**
```rust
fn add(a: i32, b: i32) -> i32 {
    a + b;  // ❌ semicolon makes it a statement, returns ()
}
```

**Right:**
```rust
fn add(a: i32, b: i32) -> i32 {
    a + b  // ✅ expression, returns i32
}
```

---

### Multiple Returns

**Ruby:**
```ruby
def parse(input)
  return nil if input.empty?
  input.to_i
end
```

**Rust:**
```rust
fn parse(input: &str) -> Option<i32> {
    if input.is_empty() {
        return None;
    }
    Some(input.parse().unwrap())
}
```

**Note:** Rust uses `Option<T>` instead of `nil`

---

## Methods (on Classes/Structs)

### Ruby Class

**Ruby:**
```ruby
class Person
  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet
    "Hi, I'm #{@name}"
  end

  def is_adult?
    @age >= 18
  end
end

person = Person.new("Alice", 25)
person.greet  # => "Hi, I'm Alice"
```

---

### Rust Struct + impl

**Rust:**
```rust
struct Person {
    name: String,
    age: u32,
}

impl Person {
    fn new(name: String, age: u32) -> Self {
        Self { name, age }
    }

    fn greet(&self) -> String {
        format!("Hi, I'm {}", self.name)
    }

    fn is_adult(&self) -> bool {
        self.age >= 18
    }
}

let person = Person::new("Alice".to_string(), 25);
person.greet();  // => "Hi, I'm Alice"
```

**Changes:**
- `struct` defines data (like Ruby's `attr_accessor`)
- `impl` block defines methods
- `&self` = borrowed self (like Ruby's implicit `self`)
- `Self` = the type itself (like Ruby's `self.class`)
- `::` for associated functions (like Ruby's `self.method`)

---

## Control Flow

### If/Else

**Ruby:**
```ruby
if score >= 90
  "A"
elsif score >= 80
  "B"
else
  "C"
end
```

**Rust:**
```rust
if score >= 90 {
    "A"
} else if score >= 80 {
    "B"
} else {
    "C"
}
```

**Changes:**
- Curly braces `{}` instead of `end`
- `elsif` → `else if`
- Expression-based (can assign result)

**Rust expression example:**
```rust
let grade = if score >= 90 { "A" } else { "B" };
```

---

### Case/Match

**Ruby:**
```ruby
case status
when :success
  handle_success
when :error
  handle_error
else
  handle_unknown
end
```

**Rust:**
```rust
match status {
    Status::Success => handle_success(),
    Status::Error => handle_error(),
    _ => handle_unknown(),
}
```

**Changes:**
- `match` instead of `case`
- `=>` for branches (Ruby uses this in hashes!)
- `_` wildcard instead of `else`
- Must be exhaustive (compiler checks all cases)

---

### Loops

**Ruby:**
```ruby
(1..5).each do |i|
  puts i
end
```

**Rust:**
```rust
for i in 1..=5 {
    println!("{}", i);
}
```

**Changes:**
- `for` instead of `.each`
- `1..=5` inclusive range (Ruby: `1..5` exclusive, `1...5` inclusive)
- `println!()` instead of `puts`

---

**Ruby while:**
```ruby
while running
  process_item
end
```

**Rust while:**
```rust
while running {
    process_item();
}
```

**Same structure!**

---

## Collections

### Arrays/Vectors

**Ruby:**
```ruby
numbers = [1, 2, 3, 4, 5]
numbers.push(6)
numbers.map { |n| n * 2 }
numbers.select { |n| n > 3 }
```

**Rust:**
```rust
let mut numbers = vec![1, 2, 3, 4, 5];
numbers.push(6);
numbers.iter().map(|n| n * 2).collect();
numbers.iter().filter(|n| **n > 3).collect();
```

**Changes:**
- `vec![]` macro for vector
- `.iter()` before chaining methods
- `.collect()` to materialize result
- `|n|` closures (like Ruby blocks)

---

### Hashes/HashMaps

**Ruby:**
```ruby
config = { port: 8080, host: "localhost" }
config[:port]  # => 8080
config[:host] = "0.0.0.0"
```

**Rust:**
```rust
use std::collections::HashMap;

let mut config = HashMap::new();
config.insert("port", 8080);
config.insert("host", "localhost");

config.get("port");  // => Some(&8080)
config.insert("host", "0.0.0.0");
```

**Changes:**
- Must import `HashMap`
- `.insert()` to add
- `.get()` returns `Option<&V>` (no key = `None`)

---

## Error Handling

### Exceptions

**Ruby:**
```ruby
def parse(input)
  raise ArgumentError, "Empty input" if input.empty?
  Integer(input)
rescue ArgumentError => e
  puts "Error: #{e.message}"
  nil
end
```

**Rust:**
```rust
fn parse(input: &str) -> Result<i32, String> {
    if input.is_empty() {
        return Err("Empty input".to_string());
    }
    input.parse().map_err(|e| e.to_string())
}

match parse("42") {
    Ok(value) => println!("Parsed: {}", value),
    Err(e) => println!("Error: {}", e),
}
```

**Changes:**
- `Result<T, E>` instead of exceptions
- `Err()` instead of `raise`
- `match` to handle both cases
- No automatic propagation (use `?` operator)

---

### The `?` Operator

**Ruby:**
```ruby
def process
  data = parse(input)
  transformed = transform(data)
  save(transformed)
end
```

**Rust:**
```rust
fn process() -> Result<(), String> {
    let data = parse(input)?;         // If Err, return early
    let transformed = transform(data)?;
    save(transformed)?;
    Ok(())
}
```

**`?` operator:** If `Err`, return immediately. If `Ok`, unwrap value.

---

## Nil/Option

### Handling Nil

**Ruby:**
```ruby
def get_name(user)
  user&.name || "Unknown"
end
```

**Rust:**
```rust
fn get_name(user: Option<&User>) -> String {
    user.and_then(|u| Some(u.name.clone()))
        .unwrap_or_else(|| "Unknown".to_string())
}

// Or more idiomatically:
fn get_name(user: Option<&User>) -> String {
    match user {
        Some(u) => u.name.clone(),
        None => "Unknown".to_string(),
    }
}
```

**`Option<T>`:**
- `Some(value)` = has value
- `None` = no value (like `nil`)

---

## Blocks/Closures

**Ruby:**
```ruby
[1, 2, 3].map { |n| n * 2 }

[1, 2, 3].map do |n|
  result = n * 2
  result + 1
end
```

**Rust:**
```rust
vec![1, 2, 3].iter().map(|n| n * 2).collect()

vec![1, 2, 3].iter().map(|n| {
    let result = n * 2;
    result + 1
}).collect()
```

**Changes:**
- `|n|` instead of `|n|` (same!)
- Curly braces for multi-line
- No `do...end` syntax

---

## Strings

### String Literals

**Ruby:**
```ruby
name = "Alice"
greeting = "Hello, #{name}!"
```

**Rust:**
```rust
let name = "Alice";
let greeting = format!("Hello, {}!", name);
```

**Changes:**
- `format!()` macro for interpolation
- `{}` placeholders

---

### String Slicing

**Ruby:**
```ruby
text = "Hello, World!"
text[0..4]   # => "Hello"
text[7..-1]  # => "World!"
```

**Rust:**
```rust
let text = "Hello, World!";
&text[0..5]   // => "Hello"
&text[7..]    // => "World!"
```

**Changes:**
- `&text[range]` = string slice (`&str`)
- Ranges are byte indices (not character indices!)

---

## Ownership (The New Part)

### Ruby (No Ownership Concept)

**Ruby:**
```ruby
name = "Alice"
other = name
puts name  # ✅ still works
puts other # ✅ still works
```

---

### Rust (Ownership Rules)

**Rust:**
```rust
let name = String::from("Alice");
let other = name;
println!("{}", name);   // ❌ error: value moved to `other`
println!("{}", other);  // ✅ works
```

**Ownership rules:**
1. Each value has ONE owner
2. When owner goes out of scope, value is dropped
3. Move = transfer ownership

---

### Borrowing (The Solution)

**Rust:**
```rust
let name = String::from("Alice");
let other = &name;  // Borrow (don't take ownership)
println!("{}", name);   // ✅ still works
println!("{}", other);  // ✅ still works
```

**Borrowing:**
- `&` = immutable borrow (read-only)
- `&mut` = mutable borrow (read-write)
- Multiple `&` OR one `&mut` (not both)

---

## Math Operations

**Ruby:**
```ruby
result = base * (multiplier ** exponent)
capped = [result, max].min
```

**Rust:**
```rust
let result = base * multiplier.powi(exponent);
let capped = result.min(max);
```

**Changes:**
- `**` → `.powi()` (integer exponent) or `.powf()` (float)
- `[a, b].min` → `a.min(b)`

**Everything else identical!** (`+`, `-`, `*`, `/`, `%`)

---

## Common Patterns

### Map/Filter/Reduce

**Ruby:**
```ruby
numbers = [1, 2, 3, 4, 5]
doubled = numbers.map { |n| n * 2 }
evens = numbers.select { |n| n.even? }
sum = numbers.reduce(0) { |acc, n| acc + n }
```

**Rust:**
```rust
let numbers = vec![1, 2, 3, 4, 5];
let doubled: Vec<_> = numbers.iter().map(|n| n * 2).collect();
let evens: Vec<_> = numbers.iter().filter(|n| *n % 2 == 0).collect();
let sum: i32 = numbers.iter().fold(0, |acc, n| acc + n);
```

**Changes:**
- `.iter()` before chaining
- `.collect()` to get Vec back
- `fold` instead of `reduce`
- Must dereference: `*n`

---

### Find/Detect

**Ruby:**
```ruby
numbers.find { |n| n > 10 }  # => first match or nil
```

**Rust:**
```rust
numbers.iter().find(|n| **n > 10)  // => Option<&i32>
```

---

### Any/All

**Ruby:**
```ruby
numbers.any? { |n| n > 10 }
numbers.all? { |n| n > 0 }
```

**Rust:**
```rust
numbers.iter().any(|n| *n > 10)
numbers.iter().all(|n| *n > 0)
```

**Same methods!**

---

## What You DON'T Need Yet

For basic Matryoshka porting, you can **skip**:

- ❌ Lifetimes (`'a`, `'static`)
- ❌ Advanced traits (`Fn`, `Iterator` custom)
- ❌ Unsafe code (`unsafe {}`)
- ❌ Macros (except `println!`, `format!`, `vec!`)
- ❌ Async/await (unless using async pattern)

**Start simple:** Variables, functions, structs, basic control flow.

---

## Learning Path

### Day 1: Read Side-by-Side

1. Find a Ruby method in your gem
2. Read the Rust port next to it
3. Identify patterns:
   - `let` = variable
   - `fn` = function
   - `&self` = method on struct
   - `match` = case statement

---

### Day 2: Make Small Changes

1. Tweak a calculation in Rust
2. Change a variable name
3. Add a `println!()` for debugging
4. Run tests to verify

---

### Day 3: Port a Simple Function

1. Choose a pure function (no side effects)
2. Port Ruby → Rust
3. Write Rust test (same as Ruby test)
4. Compare outputs

---

### Week 1: Port 3-4 Methods

After porting 3-4 methods, you'll understand:
- ✅ 40% of Rust syntax
- ✅ Basic types and functions
- ✅ Pattern matching
- ✅ Ownership basics

---

## Quick Reference

| Concept | Ruby | Rust |
|---------|------|------|
| Variable | `x = 10` | `let x = 10;` |
| Mutable | (always) | `let mut x = 10;` |
| Function | `def name(x)` | `fn name(x: i32)` |
| Method | `def name` | `fn name(&self)` |
| Return | `value` | `value` (no `;`) |
| If | `if...elsif...else...end` | `if...else if...else` |
| Case | `case...when...else...end` | `match...=>..._` |
| Loop | `(1..5).each { }` | `for i in 1..=5 { }` |
| Array | `[1, 2, 3]` | `vec![1, 2, 3]` |
| Hash | `{a: 1}` | `HashMap::new()` |
| String | `"text"` | `"text"` or `String` |
| Interpolation | `"#{var}"` | `format!("{}", var)` |
| Nil | `nil` | `Option::None` |
| Exception | `raise` | `Err()` |
| Closure | `{ |x| x + 1 }` | `|x| x + 1` |
| Map | `.map { }` | `.iter().map().collect()` |
| Filter | `.select { }` | `.iter().filter().collect()` |
| Reduce | `.reduce { }` | `.iter().fold()` |

---

## Example: Side-by-Side Translation

### Ruby

```ruby
class RetryPolicy
  def initialize(max_attempts:, base_delay:, multiplier:)
    @max_attempts = max_attempts
    @base_delay = base_delay
    @multiplier = multiplier
  end

  def calculate_delay(attempt)
    return 0 if attempt >= @max_attempts

    base = @base_delay * (@multiplier ** (attempt - 1))
    base * (1 + rand)
  end

  def should_retry?(attempt)
    attempt < @max_attempts
  end
end

policy = RetryPolicy.new(max_attempts: 5, base_delay: 0.1, multiplier: 2.0)
delay = policy.calculate_delay(3)
```

---

### Rust

```rust
struct RetryPolicy {
    max_attempts: u8,
    base_delay: f64,
    multiplier: f64,
}

impl RetryPolicy {
    fn new(max_attempts: u8, base_delay: f64, multiplier: f64) -> Self {
        Self {
            max_attempts,
            base_delay,
            multiplier,
        }
    }

    fn calculate_delay(&self, attempt: u8, random: f64) -> f64 {
        if attempt >= self.max_attempts {
            return 0.0;
        }

        let base = self.base_delay * self.multiplier.powi((attempt - 1) as i32);
        base * (1.0 + random)
    }

    fn should_retry(&self, attempt: u8) -> bool {
        attempt < self.max_attempts
    }
}

let policy = RetryPolicy::new(5, 0.1, 2.0);
let delay = policy.calculate_delay(3, rand::random());
```

---

### What Changed?

1. **Types added:** `u8`, `f64`, `-> Self`, `-> f64`, `-> bool`
2. **`self` → `&self`:** Borrowed, not moved
3. **`@var` → `self.var`:** Access struct fields
4. **`def initialize` → `fn new`:** Constructor pattern
5. **`rand` → `rand::random()`:** Explicit RNG
6. **`**` → `.powi()`:** Power function
7. **`.new(k: v)` → `.new(v)`:** Positional args (or use builder)

**Everything else:** Same logic, same flow, same algorithm.

---

## Next Steps

1. **Read PHILOSOPHY.md** → Understand the "why"
2. **Pick a pattern:**
   - FFI Hybrid → [FFI_HYBRID.md](FFI_HYBRID.md)
   - Mirror API → [MIRROR_API.md](MIRROR_API.md)
3. **Port one method** from Ruby to Rust
4. **Compare outputs** (same inputs, same results)
5. **Repeat** for 3-4 methods

**After 3-4 methods:** You'll read Rust confidently.
**After one gem:** You'll write Rust idiomatically.

**Welcome to Rust, Ruby developer.**
