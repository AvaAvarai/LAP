# LAP: Lisp-like Applied Processor

A Lisp interpreter written in Odin that supports arithmetic, functions, lambda expressions, closures, conditionals, and **bootstrapping capabilities**.

## What LAP Does

LAP takes Lisp-like expressions and evaluates them. It processes code through these steps:

1. **Tokenizes** the input into symbols, numbers, and parentheses
2. **Parses** tokens into an Abstract Syntax Tree (AST)
3. **Evaluates** the AST to produce results

## Features

### Basic Operations

```lisp
; Arithmetic
(+ 1 2)                    ; => 3.000
(* 3 4)                    ; => 12.000
(- 10 5)                   ; => 5.000

; Variables
(define x 42)
(+ x 8)                    ; => 50.000
```

### Functions

```lisp
; Define functions
(define (square x) (* x x))
(square 5)                 ; => 25.000

; Lambda functions
(define double (lambda (x) (+ x x)))
(double 7)                 ; => 14.000

; Anonymous lambdas
((lambda (x y) (+ x y)) 3 4)  ; => 7.000
```

### Closures & Higher-Order Functions

```lisp
; Closures and higher-order functions
(define make-adder (lambda (n) (lambda (x) (+ x n))))
(define add5 (make-adder 5))
(add5 3)                   ; => 8.000
```

### Conditionals

```lisp
; If statements
(if (< 3 5) 42 0)         ; => 42.000
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
(print 42)                 ; => 42.000
(print "Hello")            ; => "Hello"
(print #t #f)              ; => #t #f
```

### Bootstrapping Functions

LAP includes core functions that enable **self-hosting** - building more complex functionality in LAP itself:

```lisp
; Read input from stdin
(read)                     ; => user input as string

; Evaluate strings as LAP code
(eval "(+ 5 3)")           ; => 8.000

; Load and execute files
(load "examples/basic.lap")

; String operations
(concat "Hello" " " "World") ; => "Hello World"
(str= "test" "test")       ; => #t

; Multiple expressions
(begin 1 2 3)              ; => 3.000
```

### Complex Examples

```lisp
; Recursive factorial
(define factorial (lambda (n) 
  (if (= n 0) 1 (* n (factorial (- n 1))))))
(factorial 5)              ; => 120.000

; Nested expressions
(+ (* 3 4) (- 10 5))       ; => 17.000
```

## Running LAP

### Basic Usage

```bash
# Run test suite
odin run .

# Run a specific example file
odin run . -- examples/filename.lap
```

### Interactive REPL

LAP includes a **self-hosted REPL** written entirely in LAP:

```bash
# Start the interactive REPL
odin run . -- examples/repl.lap
```

The REPL supports:

- **Interactive expression evaluation** - Type LAP expressions and see results
- **Piped input** - Process expressions from shell commands
- **Built-in help system** (`help`)
- **File loading** (`load`)
- **Clean exit** (`quit`)

#### REPL Examples

```bash
# Interactive mode
odin run . -- examples/repl.lap
> (+ 2 3)
5.000
> (print "Hello, LAP!")
"Hello, LAP!"
0.000
> quit
Goodbye!

# Piped input mode
echo "(+ 2 3)" | odin run . -- examples/repl.lap
echo '(print "Hello, World!")' | odin run . -- examples/repl.lap
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
