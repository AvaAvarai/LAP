package main

import "core:fmt"

main :: proc() {
    input := "(define x (+ 1 2))";
    tokens := tokenize(input);

    for token in tokens {
        fmt.println("Kind: ", token.kind, ", Value: ", token.value);
    }
}