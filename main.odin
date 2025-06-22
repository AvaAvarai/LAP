package main

import "core:fmt"

main :: proc() {
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

    for test_input, i in test_cases {
        fmt.printf("=== Test Case %d ===\n", i + 1);
        fmt.printf("Input: %s\n", test_input);
        
        tokens := tokenize(test_input);
        fmt.printf("Tokens (%d):\n", len(tokens));
        
        for token, j in tokens {
            fmt.printf("  %d: Kind: %v, Value: '%s'\n", j, token.kind, token.value);
        }
        
        fmt.printf("AST:\n");
        exprs, _ := parse_exprs(tokens);
        for expr in exprs {
            print_expr(expr, 1);
        }
        fmt.printf("Pretty Printed AST:\n");
        for expr in exprs {
            fmt.printf("%s\n", pretty_print_expr(expr));
        }
        
        for expr in exprs {
            val := eval(expr, &env);
            if val.kind == Value_Kind.Number {
                fmt.printf("=> %f\n", val.number);
            }
        }
        fmt.println();
    }
}