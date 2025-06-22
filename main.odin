package main

import "core:fmt"

main :: proc() {
    // Test cases for tokenizer
    test_cases := []string{
        "(define x (+ 1 2))",
        "(+ (* 3 4) (- 10 5))",
        "(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))",
        "42",
        "hello",
        "(define (square x) (* x x))",
    };

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
        fmt.println();
    }
}