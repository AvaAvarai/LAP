# LAP: Lisp-like Applied Processor

A self-hosting Lisp dialect written in Odin, designed to bootstrap itself.

## Pipeline Overview

[Source code string]  
      ↓  
🧱 1. **Tokenizer (Lexer)** – breaks raw input into tokens  
      ↓  
🌲 2. **Parser** – builds nested AST (usually as lists)  
      ↓  
⚙️ 3. **Evaluator (Interpreter)** – evaluates AST in an environment  
      ↓  
🧠 4. **Environment** – holds symbol definitions, user functions, variables

## AST Visualization

LAP includes built-in tools for visualizing the Abstract Syntax Tree (AST) at different stages of processing. The parser provides two main printing functions:

### Tree Structure Printing

The `print_expr` function displays the AST as a hierarchical tree structure:

```lisp
; Input: (+ (* 3 4) (- 10 5))
; AST Output:
List:
  Atom: +
  List:
    Atom: *
    Atom: 3
    Atom: 4
  List:
    Atom: -
    Atom: 10
    Atom: 5
```

This format shows:

- **List nodes** with their children indented
- **Atom nodes** with their values
- Clear hierarchical structure with indentation

### Pretty-Printed AST

The `pretty_print_expr` function reconstructs the original Lisp syntax from the AST:

```lisp
; Input: (define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))
; Pretty Printed Output:
(define
  factorial
  (lambda
    (n)
    (if
      (= n 0)
      1
      (*
        n
        (factorial
          (- n 1))))))
```

**Features:**

- **Automatic formatting**: Chooses between single-line and multi-line based on complexity
- **Smart indentation**: Nested expressions are properly indented
- **Readable output**: Maintains the original Lisp syntax structure
- **Length detection**: Automatically breaks long expressions across multiple lines

### Multi-line Formatting Rules

The pretty printer automatically formats expressions on multiple lines when:

- Expression has more than 3 children
- Any child is a list with children
- Total length would exceed 80 characters

**Example of automatic formatting:**

```lisp
; Short expression (single line)
(+ 1 2)
; => (+ 1 2)

; Long expression (multi-line)
(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))
; => (define
;      factorial
;      (lambda
;        (n)
;        (if
;          (= n 0)
;          1
;          (*
;            n
;            (factorial
;              (- n 1))))))
```

### Usage in Development

These printing functions are automatically used when running the main program:

```bash
odin run .
```

The output shows:

1. **Input**: The original Lisp expression
2. **Tokens**: Lexical analysis results
3. **AST**: Tree structure visualization
4. **Pretty Printed AST**: Reconstructed syntax
5. **Evaluation**: Final result

This makes LAP an excellent tool for learning about compiler construction and AST representation.

## Examples

LAP supports a subset of Lisp-like expressions. Here are working examples:

### Basic Arithmetic

```lisp
; Simple addition
(+ 1 2)
; => 3.000

; Nested expressions
(+ (* 3 4) (- 10 5))
; => 17.000

; Number literals
42
; => 42.000
```

### Variable Definitions

```lisp
; Define a variable
(define x (+ 1 2))
; => 3.000

; Use the variable in expressions
(+ x 5)
; => 8.000
```

### Built-in Functions

LAP currently supports these built-in functions:

- `+` - Addition (variable arity)
- `*` - Multiplication (variable arity)  
- `-` - Subtraction (variable arity)
- `=` - Equality comparison (binary)

### Function Definitions (Basic)

```lisp
; Define a function with parameters
(define (square x) (* x x))
; => 0.000 (definition stored)

; Call the function
(square 5)
; => 25.000
```

### Conditional Logic

```lisp
; Simple if statement
(if (= 5 5) 42 0)
; => 42.000

; With variables
(define x 10)
(if (= x 10) "yes" "no")
; => 0.000 (strings not fully supported yet)
```

### Complex Expressions

```lisp
; Multiple operations
(define result (+ (* 2 3) (- 10 4)))
; => 12.000

; Nested conditionals
(if (= (+ 1 1) 2) 
    (* 3 4) 
    (+ 5 6))
; => 12.000
```

### Error Handling

```lisp
; Unbound symbols return 0 with error message
hello
; Unbound symbol: hello
; => 0.000

; Invalid function calls
(not_a_function 1 2 3)
; Head of list is not a function: not_a_function
; => 0.000
```

## Current Limitations

- **Lambda functions**: Not yet implemented
- **Strings**: Limited support
- **Lists**: Basic support for storing expressions
- **Recursion**: Not yet supported for user-defined functions
- **Closures**: Not implemented

## Running Examples

To run the examples:

```bash
odin run .
```

This will execute the test cases in `main.odin` and show the tokenization, parsing, and evaluation steps for each example.

### License

This project is available opensource under the MIT License see [LICENSE](LICENSE) for full details
