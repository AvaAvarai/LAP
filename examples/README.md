# LAP Examples

This directory contains example programs demonstrating LAP's capabilities.

## Basic Examples

- **`basic.lap`** - Basic arithmetic, functions, conditionals, and comparisons
- **`factorial.lap`** - Recursive factorial function
- **`fibonacci.lap`** - Recursive Fibonacci sequence
- **`lambda_demo.lap`** - Lambda expressions and higher-order functions
- **`comparison_demo.lap`** - All comparison operators
- **`arithmetic_demo.lap`** - Arithmetic operations and precedence
- **`closure_demo.lap`** - Closures and lexical scoping

## Bootstrapping Examples

- **`bootstrap_test.lap`** - Test of bootstrapping functions
- **`repl.lap`** - **Self-hosted REPL implementation** - demonstrates bootstrapping by implementing an interactive environment entirely in LAP

## Bootstrapping Functions

LAP includes core functions that enable bootstrapping - building more complex functionality in LAP itself:

- **`read`** - Read multiline input from stdin (automatically balances parentheses)
- **`read-line`** - Read a single line from stdin (with built-in multiline support)
- **`eval`** - Evaluate a string as LAP code (with persistent environment)
- **`load`** - Load and execute a file
- **`concat`** - Concatenate strings
- **`str=`** - String equality comparison
- **`str-len`** - Get string length
- **`str-ref`** - Get character at index
- **`str-trim`** - Trim whitespace from string
- **`begin`** - Execute multiple expressions, return last result
- **`let`** - Local variable bindings
- **`print`** - Output without newline (for prompts)
- **`println`** - Output with newline (for messages and results)

## Running Examples

```bash
# Run a specific example
odin run . -- examples/basic.lap

# Run the self-hosted REPL
odin run . -- examples/repl.lap

# Use the built-in REPL
lap.exe --repl
```

## REPL Implementations

LAP includes **two REPL implementations**:

### 1. Built-in REPL (Odin)

```bash
lap.exe --repl
# or
odin run . --repl
```

**Features:**

- **Built-in multiline support** - automatically continues reading until parentheses are balanced
- **Clean prompt** - shows `>` for first line, `  ` for continuation
- **Windows-compatible** - handles `\r\n` line endings
- **Fast and efficient** - written in Odin

**Example:**

```bash
lap.exe --repl
> (define (fib n)
    (if (<= n 1)
        n
        (+ (fib (- n 1)) (fib (- n 2)))))
#<lambda>
> (fib 10)
55
```

### 2. Self-hosted REPL (LAP)

```bash
lap.exe examples/repl.lap
# or
odin run . -- examples/repl.lap
```

**Features:**

- **100% written in LAP** - demonstrates bootstrapping capabilities
- **Persistent environment** - function definitions persist between expressions
- **Clean prompt** - `> ` without unwanted newlines
- **Proper multiline support** - handles complex nested expressions
- **Educational** - shows how to build complex functionality in LAP itself

**Example:**

```bash
lap.exe examples/repl.lap
=== LAP REPL (multiline) ===
Type expressions to evaluate
Type 'quit' to exit
Type 'help' for help
> (define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))
Expression evaluated successfully
> (factorial 10)
3628800
> quit
Goodbye!
```

## Multiline Input Support

Both REPLs support **multiline expressions** - you can split complex expressions across multiple lines:

```lisp
; Complex multiline function definition
(define (complex-function x y z)
  (if (> x 0)
    (+ (* x y)
       (/ z 2)
       (- y x))
    (* x y z)))

; Nested conditional with multiple operations
(define test-nested
  (lambda (a b c)
    (if (> a b)
      (if (> b c)
        (+ a b c)
        (* a b c))
      (if (= a b)
        (+ a b)
        (- a b)))))
```

## Recent Fixes and Improvements

### Parser Improvements
- **Fixed infinite loop prevention** - parser now properly handles unmatched parentheses
- **Better error recovery** - continues parsing after encountering errors
- **Robust token consumption** - prevents cascading parse errors

### Evaluator Enhancements
- **Persistent eval environment** - `eval` function now maintains state between calls
- **Enhanced read-line** - built-in multiline support with continuation prompts
- **Output control** - separate `print` and `println` functions for better formatting

### REPL Improvements
- **Clean prompt display** - no unwanted newlines after prompts
- **Proper multiline handling** - complex expressions work correctly
- **Persistent function definitions** - functions defined in one expression are available in subsequent expressions

## Features Demonstrated

- **File Input**: Reading and executing LAP programs from files
- **Comments**: Lines starting with `;` are ignored
- **Multi-line expressions**: Support for complex nested expressions
- **Environment management**: Proper variable scoping and closure support
- **Bootstrapping**: Building complex functionality using LAP itself
- **Interactive development**: Full REPL with persistent environment
- **String manipulation**: Character-by-character string processing
- **Local bindings**: `let` expressions for temporary variable scoping
- **Output formatting**: Controlled newline behavior with `print` and `println`