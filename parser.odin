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
    token_kind: Token_Kind, // Preserve original token kind
}

// Helper function to create error expressions
make_error_expr :: proc(message: string) -> (Expr, int) {
    fmt.println(message);
    return Expr{kind = Expr_Kind.Atom, value = "ERROR", token_kind = Token_Kind.Symbol}, 0;
}

parse_exprs :: proc(tokens: []Token) -> ([]Expr, int) {
    exprs: [dynamic]Expr;
    i := 0;

    for i < len(tokens) {
        expr, consumed := parse_expr(tokens[i:]);
        append(&exprs, expr);
        i += consumed;
        
        // If we consumed 0 tokens due to an error, advance by 1 to prevent infinite loop
        if consumed == 0 {
            i += 1;
        }
    }

    return exprs[:], i;
}

parse_expr :: proc(tokens: []Token) -> (Expr, int) {
    if len(tokens) == 0 {
        return Expr{kind = Expr_Kind.Atom, value = "EOF", token_kind = Token_Kind.Symbol}, 0;
    }

    token := tokens[0];

    if token.kind == Token_Kind.Paren_Left {
        i := 1;
        children: [dynamic]Expr;

        for i < len(tokens) && tokens[i].kind != Token_Kind.Paren_Right {
            child, consumed := parse_expr(tokens[i:]);
            append(&children, child);
            i += consumed;
            
            // If we consumed 0 tokens due to an error, advance by 1 to prevent infinite loop
            if consumed == 0 {
                i += 1;
            }
        }

        if i >= len(tokens) || tokens[i].kind != Token_Kind.Paren_Right {
            // Consume all remaining tokens to prevent cascading errors
            error_expr, _ := make_error_expr("Error: unmatched '('");
            return error_expr, len(tokens);
        }

        return Expr{kind = Expr_Kind.List, children = children[:], token_kind = Token_Kind.Symbol}, i + 1;
    }

    // Single Atom
    return Expr{kind = Expr_Kind.Atom, value = token.value, token_kind = token.kind}, 1;
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

pretty_print_expr :: proc(expr: Expr) -> string {
    return pretty_print_expr_indented(expr, 0);
}

pretty_print_expr_indented :: proc(expr: Expr, indent: int) -> string {
    switch expr.kind {
    case Expr_Kind.Atom:
        return expr.value;
    case Expr_Kind.List:
        if len(expr.children) == 0 {
            return "()";
        }
        
        // Determine multiline formatting
        should_multiline := should_format_multiline(expr);
        
        if should_multiline {
            parts: [dynamic]string;
            indent_str := strings.repeat("  ", indent);
            child_indent_str := strings.repeat("  ", indent + 1);
            
            append(&parts, "(");
            for child, i in expr.children {
                if i > 0 {
                    append(&parts, "\n");
                    append(&parts, child_indent_str);
                }
                append(&parts, pretty_print_expr_indented(child, indent + 1));
            }
            append(&parts, ")");
            
            return strings.concatenate(parts[:]);
        } else {
            // Single line format
            parts: [dynamic]string;
            for child in expr.children {
                append(&parts, pretty_print_expr_indented(child, indent));
            }
            return strings.concatenate({"(", strings.join(parts[:], " "), ")"});
        }
    case:
        return "ERROR";
    }
}

should_format_multiline :: proc(expr: Expr) -> bool {
    if expr.kind != Expr_Kind.List {
        return false;
    }
    
    // Multiline conditions:
    // 1. Has more than 3 children, or
    // 2. Any child is a list with children, or
    // 3. Total length would be too long
    
    if len(expr.children) > 3 {
        return true;
    }
    
    total_length := 2; // "(" and ")"
    for child in expr.children {
        if child.kind == Expr_Kind.List && len(child.children) > 0 {
            return true;
        }
        total_length += len(child.value) + 1; // +1 for space
    }
    
    return total_length > 80; // Line length threshold
}
