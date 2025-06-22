package main

import "core:fmt"
import "core:strings"

Expr_Kind :: enum {
    Atom,
    List,
}

Expr :: struct {
    kind: Expr_Kind,
    value: string,        // for Atom
    children: []Expr,     // for List
}

parse_exprs :: proc(tokens: []Token) -> ([]Expr, int) {
    exprs: [dynamic]Expr;
    i := 0;

    for i < len(tokens) {
        expr, consumed := parse_expr(tokens[i:]);
        append(&exprs, expr);
        i += consumed;
    }

    return exprs[:], i;
}

parse_expr :: proc(tokens: []Token) -> (Expr, int) {
    if len(tokens) == 0 {
        return Expr{kind = Expr_Kind.Atom, value = "EOF"}, 0;
    }

    token := tokens[0];

    if token.kind == Token_Kind.Paren_Left {
        i := 1;
        children: [dynamic]Expr;

        for i < len(tokens) && tokens[i].kind != Token_Kind.Paren_Right {
            child, consumed := parse_expr(tokens[i:]);
            append(&children, child);
            i += consumed;
        }

        if i >= len(tokens) || tokens[i].kind != Token_Kind.Paren_Right {
            fmt.println("Error: unmatched '('");
            return Expr{kind = Expr_Kind.Atom, value = "ERROR"}, len(tokens);
        }

        return Expr{kind = Expr_Kind.List, children = children[:]}, i + 1;
    }

    // Single Atom
    return Expr{kind = Expr_Kind.Atom, value = token.value}, 1;
}

print_expr :: proc(expr: Expr, indent: int) {
    pad := strings.repeat("  ", indent);

    if expr.kind == Expr_Kind.Atom {
        fmt.printf("%sAtom: %s\n", pad, expr.value);
    } else {
        fmt.printf("%sList:\n", pad);
        for child in expr.children {
            print_expr(child, indent + 1);
        }
    }
}
