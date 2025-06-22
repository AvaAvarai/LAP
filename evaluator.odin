package main

import "core:fmt"
import "core:strconv"

Value_Kind :: enum {
    Number,
    Proc,
    List,
    Bool,
}

Value :: struct {
    kind: Value_Kind,
    number: f64,
    procedure: proc(args: []Value) -> Value,
    list: []Value,
    boolean: bool,
}

Env :: map[string]Value

eval :: proc(expr: Expr, env: ^Env) -> Value {
    switch expr.kind {
    case Expr_Kind.Atom:
        // Try to parse number
        n, ok := strconv.parse_f64(expr.value);
        if ok {
            return Value{kind = Value_Kind.Number, number = n};
        }

        // Handle boolean literals
        if expr.value == "#t" || expr.value == "true" {
            return Value{kind = Value_Kind.Bool, boolean = true};
        }
        if expr.value == "#f" || expr.value == "false" {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }

        // Otherwise: symbol lookup
        if val, exists := env[expr.value]; exists {
            return val;
        } else {
            fmt.printf("Unbound symbol: %s\n", expr.value);
            return Value{kind = Value_Kind.Number, number = 0};
        }

    case Expr_Kind.List:
        if len(expr.children) == 0 {
            return Value{kind = Value_Kind.List};
        }

        head := expr.children[0];
        args := expr.children[1:];

        // Special form: define
        if head.kind == Expr_Kind.Atom && head.value == "define" {
            if len(args) != 2 {
                fmt.println("Invalid define syntax: need exactly 2 arguments");
                return Value{kind = Value_Kind.Number, number = 0};
            }
            
            // Handle (define name value) syntax
            if args[0].kind == Expr_Kind.Atom {
                name := args[0].value;
                val := eval(args[1], env);
                env[name] = val;
                return val;
            }
            
            // Handle (define (name params) body) syntax
            if args[0].kind == Expr_Kind.List && len(args[0].children) > 0 {
                name := args[0].children[0].value;
                // For now, just store the body as a list - proper lambda implementation would be more complex
                body_values: [dynamic]Value;
                for arg in args[1:] {
                    append(&body_values, eval(arg, env));
                }
                env[name] = Value{kind = Value_Kind.List, list = body_values[:]};
                return Value{kind = Value_Kind.Number, number = 0};
            }
            
            fmt.println("Invalid define syntax");
            return Value{kind = Value_Kind.Number, number = 0};
        }

        // Special form: if
        if head.kind == Expr_Kind.Atom && head.value == "if" {
            if len(args) != 3 {
                fmt.println("Invalid if syntax: need condition, then, else");
                return Value{kind = Value_Kind.Number, number = 0};
            }
            
            condition := eval(args[0], env);
            if is_truthy(condition) {
                return eval(args[1], env);
            } else {
                return eval(args[2], env);
            }
        }

        // Evaluate head to get function
        fn_val := eval(head, env);
        if fn_val.kind != Value_Kind.Proc {
            fmt.printf("Head of list is not a function: %v\n", head.value);
            return Value{kind = Value_Kind.Number, number = 0};
        }

        // Evaluate arguments
        evaled_args: [dynamic]Value;
        for arg in args {
            append(&evaled_args, eval(arg, env));
        }

        return fn_val.procedure(evaled_args[:]);
    }
    
    return Value{kind = Value_Kind.Number, number = 0};
}

is_truthy :: proc(val: Value) -> bool {
    switch val.kind {
    case Value_Kind.Bool:
        return val.boolean;
    case Value_Kind.Number:
        return val.number != 0;
    case Value_Kind.List:
        return len(val.list) > 0;
    case Value_Kind.Proc:
        return true; // Procedures are always truthy
    case:
        return false;
    }
}

make_global_env :: proc() -> Env {
    env := make(Env);

    add_proc :: proc(args: []Value) -> Value {
        sum := 0.0;
        for arg in args {
            if arg.kind == Value_Kind.Number {
                sum += arg.number;
            }
        }
        return Value{kind = Value_Kind.Number, number = sum};
    };

    mul_proc :: proc(args: []Value) -> Value {
        product := 1.0;
        for arg in args {
            if arg.kind == Value_Kind.Number {
                product *= arg.number;
            }
        }
        return Value{kind = Value_Kind.Number, number = product};
    };

    sub_proc :: proc(args: []Value) -> Value {
        if len(args) == 0 {
            return Value{kind = Value_Kind.Number, number = 0};
        }
        if len(args) == 1 {
            return Value{kind = Value_Kind.Number, number = -args[0].number};
        }
        
        result := args[0].number;
        for i := 1; i < len(args); i += 1 {
            result -= args[i].number;
        }
        return Value{kind = Value_Kind.Number, number = result};
    };

    eq_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number == args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    env["+"] = Value{kind = Value_Kind.Proc, procedure = add_proc};
    env["*"] = Value{kind = Value_Kind.Proc, procedure = mul_proc};
    env["-"] = Value{kind = Value_Kind.Proc, procedure = sub_proc};
    env["="] = Value{kind = Value_Kind.Proc, procedure = eq_proc};

    return env;
}