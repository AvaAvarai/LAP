package main

import "core:fmt"

Token_Kind :: enum {
    Paren_Left,
    Paren_Right,
    Symbol,
    Number,
    String,
}

Token :: struct {
    kind: Token_Kind,
    value: string,
}

is_digit :: proc(c: rune) -> bool {
    return c >= '0' && c <= '9';
}

is_symbol_char :: proc(c: rune) -> bool {
    return !(c == '(' || c == ')' || c == ' ' || c == '\n' || c == '\t');
}

tokenize :: proc(src: string) -> []Token {
    tokens: [dynamic]Token; // Dynamic array for token collection

    i := 0;
    for i < len(src) {
        c := src[i];

        if c == ' ' || c == '\n' || c == '\t' {
            i += 1;
            continue;
        }

        if c == '(' {
            append(&tokens, Token{kind = Token_Kind.Paren_Left, value = "("});
            i += 1;
            continue;
        }

        if c == ')' {
            append(&tokens, Token{kind = Token_Kind.Paren_Right, value = ")"});
            i += 1;
            continue;
        }

        if c == '"' {
            start := i + 1;
            i += 1;
            for i < len(src) && src[i] != '"' {
                i += 1;
            }
            if i < len(src) {
                text := src[start:i];
                append(&tokens, Token{kind = Token_Kind.String, value = text});
                i += 1;
            } else {
                // Unterminated string
                text := src[start:i];
                append(&tokens, Token{kind = Token_Kind.String, value = text});
            }
            continue;
        }

        if is_symbol_char(rune(c)) {
            start := i;
            for i < len(src) && is_symbol_char(rune(src[i])) {
                i += 1;
            }
            text := src[start:i];

            kind := Token_Kind.Symbol;
            if len(text) > 0 && is_digit(rune(text[0])) {
                kind = Token_Kind.Number;
            }

            append(&tokens, Token{kind = kind, value = text});
            continue;
        }

        i += 1;
    }

    return tokens[:]; // Convert to slice
}