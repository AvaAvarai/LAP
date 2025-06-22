# LAP: Lisp-like Applied Processor

A Lisp interpreter written in Odin that supports arithmetic, functions, lambda expressions, conditionals, and more.

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

```bash
odin run .
```

This runs the test suite showing tokenization, parsing, and evaluation for each example.

## Example Programs

A collection of example LAP programs is available in the [`examples/`](examples/) folder. These cover:

- Arithmetic and expressions
- Function and lambda usage
- Recursion (factorial, Fibonacci)
- Comparison and conditionals
- Output formatting

To run an example program:

```bash
odin run . -- examples/filename.lap
```

See [`examples/README.md`](examples/README.md) for details on each demo.

## Project Files

- `main.odin` - Test cases and main program
- `tokenizer.odin` - Breaks input into tokens
- `parser.odin` - Builds AST from tokens
- `evaluator.odin` - Evaluates AST and manages environment
- `examples/` - Example LAP programs and demos

## License

MIT License - see [LICENSE](LICENSE) for details
