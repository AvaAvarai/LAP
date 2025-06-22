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

- **`read`** - Read a line from stdin
- **`eval`** - Evaluate a string as LAP code
- **`load`** - Load and execute a file
- **`concat`** - Concatenate strings
- **`str=`** - String equality comparison
- **`begin`** - Execute multiple expressions, return last result

## Running Examples

```bash
# Run a specific example
odin run . -- examples/basic.lap

# Run the REPL
odin run . -- examples/repl.lap
```

## REPL Demo

The `repl.lap` file demonstrates bootstrapping by implementing a **fully functional REPL** entirely in LAP. It shows how the core functions can be combined to create interactive functionality.

### Features

- **Interactive expression evaluation** - Type LAP expressions and see results
- **Piped input support** - Process expressions from shell commands
- **Built-in help system** (`help` command)
- **File loading capability** (`load` command)
- **Clean exit** with `quit` command
- **EOF handling** - gracefully exits when input is exhausted

### Usage Examples

```bash
# Interactive mode
odin run . -- examples/repl.lap
> (+ 2 3)
5.000
> (print "Hello, LAP!")
"Hello, LAP!"
0.000
> help
Available commands:
  quit - exit the REPL
  help - show this help
  load <file> - load and execute a file
  Any LAP expression - evaluate it
> quit
Goodbye!

# Piped input mode
echo "(+ 2 3)" | odin run . -- examples/repl.lap
echo '(print "Hello, World!")' | odin run . -- examples/repl.lap
echo "(* 6 7)" | odin run . -- examples/repl.lap
```

### Technical Implementation

The REPL demonstrates several advanced LAP features:

- **Environment chaining** - Proper lexical scoping with parent environment references
- **Dynamic evaluation** - Using `eval` to execute strings as LAP code
- **Input processing** - Handling user input and EOF conditions
- **Control flow** - Conditional logic and recursion for the main loop
- **Error handling** - Graceful handling of invalid expressions

## Features Demonstrated

- **File Input**: Reading and executing LAP programs from files
- **Comments**: Lines starting with `;` are ignored
- **Multi-line expressions**: Support for complex nested expressions
- **Environment management**: Proper variable scoping and closure support
- **Bootstrapping**: Building complex functionality using LAP itself
- **Interactive development**: Full REPL with help and file loading