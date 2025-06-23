package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    if len(os.args) > 1 {
        if os.args[1] == "--repl" {
            // Interactive REPL mode
            run_repl();
        } else {
            // File input mode
            filename := os.args[1];
            run_file(filename);
        }
    } else {
        // Test cases mode (existing behavior)
        run_test_cases();
    }
}

run_file :: proc(filename: string) {
    data, ok := os.read_entire_file(filename);
    if !ok {
        fmt.printf("Error: Could not read file '%s'\n", filename);
        return;
    }
    defer delete(data);
    
    content := string(data);
    
    // Remove comments and blank lines
    lines := strings.split_lines(content);
    code_lines: [dynamic]string;
    for line in lines {
        trimmed := strings.trim_space(line);
        if len(trimmed) == 0 || trimmed[0] == ';' {
            continue;
        }
        append(&code_lines, trimmed);
    }
    code := strings.join(code_lines[:], " "); // Join with space to allow multi-line expressions

    global_env := make_global_env();
    file_env := Env{table = make(map[string]Value), parent = &global_env};
    
    tokens := tokenize(code);
    exprs, _ := parse_exprs(tokens);
    
    for expr in exprs {
        _ = eval(expr, &file_env);
    }
}

run_test_cases :: proc() {
    // Test cases organized by functionality
    test_cases := []string{
        // Basic arithmetic and expressions
        "(+ (* 3 4) (- 10 5))",
        "42",
        
        // Variable definitions
        "(define x (+ 1 2))",
        "(define result (+ 5 3))",
        
        // Function definitions
        "(define (square x) (* x x))",
        
        // Lambda expressions
        "((lambda (x) (* x x)) 5)",
        "(define double (lambda (x) (+ x x)))",
        "(double 7)",
        "(define add (lambda (x y) (+ x y)))",
        "(add 3 4)",
        
        // Complex recursive function
        "(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))",
        
        // Print function tests
        "(print 42)",
        "(print (+ 1 2 3))",
        "(print #t #f)",
        "(print result)",
        
        // Comparison operators (one test each)
        "(print (< 3 5))",
        "(print (> 10 5))",
        "(print (<= 5 5))",
        "(print (>= 7 3))",
        "(print (!= 4 4))",
        "(print (= 4 4))",
        
        // Conditional logic
        "(if (< 3 5) (print \"3 is less than 5\") (print \"error\"))",
        "(if (> 2 8) (print \"error\") (print \"2 is not greater than 8\"))",
    };

    env := make_global_env();

    for test_input in test_cases {
        tokens := tokenize(test_input);
        exprs, _ := parse_exprs(tokens);
        
        for expr in exprs {
            _ = eval(expr, &env);
        }
    }
}

run_repl :: proc() {
    fmt.println("LAP REPL - Type expressions or (exit) to quit");
    fmt.println("Multiline input is supported - continue typing until parentheses are balanced");
    
    global_env := make_global_env();
    
    for {
        // Use the read function from the evaluator
        read_result := read_multiline_input();
        if len(read_result) == 0 {
            continue;
        }
        
        // Check for exit command
        if strings.trim_space(read_result) == "(exit)" {
            fmt.println("Goodbye!");
            break;
        }
        
        // Tokenize and parse
        tokens := tokenize(read_result);
        if len(tokens) == 0 {
            continue;
        }
        
        exprs, _ := parse_exprs(tokens);
        if len(exprs) == 0 {
            continue;
        }
        
        // Evaluate each expression
        for expr in exprs {
            result := eval(expr, &global_env);
            // Don't print the result if it's just a number 0 (likely from print statements)
            if result.kind != Value_Kind.Number || result.number != 0 {
                // Print the result
                print_proc([]Value{result});
            }
        }
    }
}