# LAP: Lisp-like Applied Processor

A Lisp interpreter written in Odin that supports arithmetic, functions, lambda expressions, closures, conditionals, **multiline input**, and **bootstrapping capabilities**.

## What LAP Does

LAP takes Lisp-like expressions and evaluates them. It processes code through these steps:

1. **Tokenizes** the input into symbols, numbers, and parentheses
2. **Parses** tokens into an Abstract Syntax Tree (AST)
3. **Evaluates** the AST to produce results

## Features

### Basic Operations

```lisp
; Arithmetic
(+ 1 2)                    ; => 3
(* 3 4)                    ; => 12
(- 10 5)                   ; => 5
(/ 20 4)                   ; => 5

; Variables
(define x 42)
(+ x 8)                    ; => 50
```

### Functions

```lisp
; Define functions
(define (square x) (* x x))
(square 5)                 ; => 25

; Lambda functions
(define double (lambda (x) (+ x x)))
(double 7)                 ; => 14

; Anonymous lambdas
((lambda (x y) (+ x y)) 3 4)  ; => 7
```

### Closures & Higher-Order Functions

```lisp
; Closures and higher-order functions
(define make-adder (lambda (n) (lambda (x) (+ x n))))
(define add5 (make-adder 5))
(add5 3)                   ; => 8
```

### Conditionals

```lisp
; If statements
(if (< 3 5) 42 0)         ; => 42
(if (> 2 8) "yes" "no")   ; => "no"
```

### Comparison Operators

```lisp
(< 3 5)    ; => #t
(> 10 5)   ; => #t
(<= 5 5)   ; => #t
(>= 7 3)   ; => #t
(!= 4 4)   ; => #f
(= 4 4)    ; => #t
```

### Output

```lisp
; Print function
(print 42)                 ; => 42
(print "Hello")            ; => "Hello"
(print #t #f)              ; => #t #f
```

### Multiline Input Support

LAP supports **multiline expressions** - you can split complex expressions across multiple lines:

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

### Bootstrapping Functions

LAP includes core functions that enable **self-hosting** - building more complex functionality in LAP itself:

```lisp
; Read input from stdin (supports multiline)
(read)                     ; => user input as string

; Read single line input
(read-line)                ; => single line as string

; Evaluate strings as LAP code
(eval "(+ 5 3)")           ; => 8

; Load and execute files
(load "examples/basic.lap")

; String operations
(concat "Hello" " " "World") ; => "Hello World"
(str= "test" "test")       ; => #t
(str-len "hello")          ; => 5
(str-ref "hello" 1)        ; => "e"
(str-trim "  hello  ")     ; => "hello"

; Multiple expressions
(begin 1 2 3)              ; => 3

; Local variable bindings
(let ((x 10) (y 20)) (+ x y))  ; => 30
```

### Complex Examples

```lisp
; Recursive factorial
(define factorial (lambda (n) 
  (if (= n 0) 1 (* n (factorial (- n 1))))))
(factorial 5)              ; => 120

; Nested expressions
(+ (* 3 4) (- 10 5))       ; => 17
```

## Running LAP

### Basic Usage

```bash
# Run test suite
odin run .

# Run a specific example file
odin run . -- examples/filename.lap
```

### Interactive REPLs

LAP includes **two REPL implementations**:

#### 1. Odin REPL (Built-in)

```bash
# Start the built-in REPL with multiline support
lap.exe --repl
# or
odin run . -repl
```

Features:

- **Built-in multiline support** - automatically continues reading until parentheses are balanced
- **Clean prompt** - shows `>` for first line, `  ` for continuation
- **Windows-compatible** - handles `\r\n` line endings

#### 2. LAP REPL (Self-hosted)

```bash
# Start the self-hosted REPL written entirely in LAP
lap.exe examples/repl.lap
# or
odin run . -- examples/repl.lap
```

Features:

- **100% written in LAP** - demonstrates bootstrapping capabilities
- **Custom multiline logic** - implements its own parentheses balancing
- **Built-in commands** - `help`, `load`, `quit`
- **Educational** - shows how to build complex functionality in LAP itself

#### REPL Examples

```bash
# Built-in REPL
lap.exe --repl
> (define (fib n)
    (if (<= n 1)
        n
        (+ (fib (- n 1)) (fib (- n 2)))))
#<lambda>
> (fib 10)
55

# Self-hosted REPL
lap.exe examples/repl.lap
lap> (define x 42)
lap> (print x)
42
lap> help
Available commands:
  quit - exit the REPL
  help - show this help
  load <file> - load and execute a file
  Any LAP expression - evaluate it
lap> quit
Goodbye!
```

## Building LAP

### Prerequisites

Before building LAP, ensure you have the [Odin compiler](https://odin-lang.org/docs/install/) installed on your system.

### Building to Binary

The simplest way to build LAP is:

```bash
odin build .
```

This will produce `lap.exe` on Windows, or `lap` on Linux/macOS, in the current directory.

To customize the output name or build for other platforms, see below:

```bash
# Build debug version
odin build . -out:lap

# Build optimized release version
odin build . -out:lap -opt:3

# Build for specific platform
odin build . -out:lap -target:windows_amd64
odin build . -out:lap -target:linux_amd64
odin build . -out:lap -target:darwin_amd64
```

### Using the Binary

Once built, you can use the `lap` executable directly:

```bash
# Run test suite
./lap

# Run a specific example file
./lap examples/factorial.lap

# Start the built-in REPL
./lap --repl

# Start the self-hosted REPL
./lap examples/repl.lap

# Process input from pipe
echo "(+ 2 3)" | ./lap examples/repl.lap
```

### Build Options

Additional build options for customization:

```bash
# Build with debug symbols
odin build . -out:lap -debug

# Build with specific optimization level (0-3)
odin build . -out:lap -opt:2

# Build with custom output name
odin build . -out:my-lap-interpreter

# Build with additional compiler flags
odin build . -out:lap -extra-linker-flags:"-static"
```

### Cross-Compilation

LAP can be cross-compiled for different platforms:

```bash
# Build for Windows from Linux/macOS
odin build . -out:lap.exe -target:windows_amd64

# Build for Linux from Windows
odin build . -out:lap -target:linux_amd64

# Build for macOS from Linux
odin build . -out:lap -target:darwin_amd64
```

## Example Programs

A collection of example LAP programs is available in the [`examples/`](examples/) folder. These cover:

### Basic Examples

- **`basic.lap`** - Arithmetic, functions, conditionals, and comparisons
- **`factorial.lap`** - Recursive factorial function
- **`fibonacci.lap`** - Recursive Fibonacci sequence
- **`lambda_demo.lap`** - Lambda expressions and higher-order functions
- **`comparison_demo.lap`** - All comparison operators
- **`arithmetic_demo.lap`** - Arithmetic operations and precedence
- **`closure_demo.lap`** - Closures and lexical scoping

### Bootstrapping Examples

- **`bootstrap_test.lap`** - Test of bootstrapping functions
- **`repl.lap`** - **Self-hosted REPL implementation** - demonstrates bootstrapping by implementing an interactive environment entirely in LAP

See [`examples/README.md`](examples/README.md) for detailed descriptions of each example.

## Bootstrapping & Self-Hosting

LAP is designed with **bootstrapping** in mind - the ability to build more complex functionality using the language itself. The core bootstrapping functions enable:

- **Self-hosted REPL**: Interactive development environment written in LAP
- **Code generation**: Create and evaluate LAP code dynamically
- **File processing**: Load and execute LAP programs
- **String manipulation**: Build and process code as strings
- **Extensibility**: Add new language features in LAP itself

This foundation makes LAP suitable for:

- Language experimentation
- Self-modifying code
- Metaprogramming
- Educational language implementation

## Technical Implementation

### Environment Management

- **Lexical scoping** with proper closure support
- **Environment chaining** for variable lookup
- **Proper parent environment references** (not deep copying)

### Input Processing

- **Windows-compatible** line ending handling (`\r\n`)
- **Comment filtering** (lines starting with `;`)
- **Blank line removal** for clean execution
- **Multiline input support** with automatic parentheses balancing

### Error Handling

- **Graceful error reporting** for unbound symbols
- **Robust parsing** with proper tokenization
- **Clean exit** on EOF or quit commands

## Project Files

- `main.odin` - Main program entry point and test runner
- `tokenizer.odin` - Breaks input into tokens
- `parser.odin` - Builds AST from tokens
- `evaluator.odin` - Evaluates AST and manages environment
- `examples/` - Example LAP programs and demos

## License

MIT License - see [LICENSE](LICENSE) for details
