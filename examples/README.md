# LAP Examples

This folder contains demo programs showcasing different features of the LAP interpreter.

## Demo Programs

### `basic.lap`

Basic introduction to LAP features including:

- Variable definitions
- Function definitions
- Lambda expressions
- Conditional logic
- Comparison operators
- Complex expressions

### `fibonacci.lap`

Demonstrates recursion and conditional logic:

- Recursive function definition
- Base case handling
- Fibonacci sequence calculation

### `factorial.lap`

Shows recursive factorial calculation:

- Recursive function with base case
- Mathematical factorial computation

### `lambda_demo.lap`

Advanced lambda expression examples:

- Anonymous function application
- Function definition using lambda
- Higher-order functions (functions that return functions)
- Nested lambda expressions

### `comparison_demo.lap`

Comprehensive comparison operator examples:

- All comparison operators (`=`, `!=`, `<`, `>`, `<=`, `>=`)
- Boolean logic
- Conditional statements with comparisons

### `arithmetic_demo.lap`

Arithmetic operations showcase:

- Basic arithmetic (`+`, `-`, `*`)
- Complex expressions
- Order of operations
- Negative numbers
- Multiple argument operations

## Running Examples

To run any example, use:

```bash
odin run . -- examples/filename.lap
```

For example:

```bash
odin run . -- examples/fibonacci.lap
odin run . -- examples/lambda_demo.lap
```

## Features Demonstrated

- **File Input**: Reading and executing LAP programs from files
- **Comments**: Lines starting with `;` are ignored
- **Function Definitions**: Both `(define (name params) body)` and `(define name (lambda (params) body))` syntax
- **Lambda Expressions**: Anonymous functions and closures
- **Recursion**: Self-referential function calls
- **Conditional Logic**: `if` statements with boolean expressions
- **Arithmetic**: All basic arithmetic operations
- **Comparison**: All comparison operators returning boolean values
- **Print Function**: Output formatting for all value types 