package main

import "core:fmt"
import "core:strconv"

Value_Kind :: enum {
    Number,
    Proc,
    List,
    Bool,
    Lambda,
    String,
}

Value :: struct {
    kind: Value_Kind,
    number: f64,
    procedure: proc(args: []Value) -> Value,
    list: []Value,
    boolean: bool,
    // Lambda-specific fields
    lambda_params: []string,
    lambda_body: []Expr,
    lambda_env: ^Env,  // Closure environment
    string: string,
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

        // Handle string literals
        if len(expr.value) > 0 && expr.value[0] == '"' {
            return Value{kind = Value_Kind.String, string = expr.value[1:len(expr.value)-1]};
        }

        // Handle string tokens (from tokenizer)
        if expr.token_kind == Token_Kind.String {
            return Value{kind = Value_Kind.String, string = expr.value};
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
                // Store function body as list
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

        // Special form: lambda
        if head.kind == Expr_Kind.Atom && head.value == "lambda" {
            if len(args) != 2 {
                fmt.println("Invalid lambda syntax: need parameters and body");
                return Value{kind = Value_Kind.Number, number = 0};
            }
            
            // Extract parameters
            if args[0].kind != Expr_Kind.List {
                fmt.println("Lambda parameters must be a list");
                return Value{kind = Value_Kind.Number, number = 0};
            }
            
            params: [dynamic]string;
            for param in args[0].children {
                if param.kind != Expr_Kind.Atom {
                    fmt.println("Lambda parameters must be symbols");
                    return Value{kind = Value_Kind.Number, number = 0};
                }
                append(&params, param.value);
            }
            
            // Create lambda value with closure
            return Value{
                kind = Value_Kind.Lambda,
                lambda_params = params[:],
                lambda_body = args[1:],
                lambda_env = env,
            };
        }

        // Evaluate head to get function
        fn_val := eval(head, env);
        if fn_val.kind != Value_Kind.Proc && fn_val.kind != Value_Kind.Lambda {
            fmt.printf("Head of list is not a function: %v\n", head.value);
            return Value{kind = Value_Kind.Number, number = 0};
        }

        // Evaluate arguments
        evaled_args: [dynamic]Value;
        for arg in args {
            append(&evaled_args, eval(arg, env));
        }

        // Apply function
        if fn_val.kind == Value_Kind.Proc {
            return fn_val.procedure(evaled_args[:]);
        } else if fn_val.kind == Value_Kind.Lambda {
            return apply_lambda(fn_val, evaled_args[:]);
        }
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
        return true; // Functions are truthy
    case Value_Kind.Lambda:
        return true; // Lambdas are truthy
    case Value_Kind.String:
        return len(val.string) > 0;
    case:
        return false;
    }
}

apply_lambda :: proc(lambda: Value, args: []Value) -> Value {
    if len(args) != len(lambda.lambda_params) {
        fmt.printf("Lambda expects %d arguments, got %d\n", len(lambda.lambda_params), len(args));
        return Value{kind = Value_Kind.Number, number = 0};
    }
    
    // New environment for lambda execution
    new_env := make(Env);
    
    // Copy parent environment
    for key, value in lambda.lambda_env {
        new_env[key] = value;
    }
    
    // Bind parameters
    for param, i in lambda.lambda_params {
        new_env[param] = args[i];
    }
    
    // Evaluate lambda body
    result := Value{kind = Value_Kind.Number, number = 0};
    for expr in lambda.lambda_body {
        result = eval(expr, &new_env);
    }
    
    return result;
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

    lt_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number < args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    gt_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number > args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    lte_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number <= args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    gte_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number >= args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    ne_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        
        if args[0].kind == Value_Kind.Number && args[1].kind == Value_Kind.Number {
            return Value{kind = Value_Kind.Bool, boolean = args[0].number != args[1].number};
        }
        
        return Value{kind = Value_Kind.Bool, boolean = false};
    };

    print_proc :: proc(args: []Value) -> Value {
        for arg, i in args {
            if i > 0 {
                fmt.print(" ");
            }
            switch arg.kind {
            case Value_Kind.Number:
                fmt.printf("%f", arg.number);
            case Value_Kind.Bool:
                if arg.boolean {
                    fmt.print("#t");
                } else {
                    fmt.print("#f");
                }
            case Value_Kind.String:
                fmt.printf("\"%s\"", arg.string);
            case Value_Kind.List:
                fmt.print("(");
                for child, j in arg.list {
                    if j > 0 {
                        fmt.print(" ");
                    }
                    // Recursively print list elements
                    temp_val := Value{kind = Value_Kind.List, list = []Value{child}};
                    print_proc([]Value{temp_val});
                }
                fmt.print(")");
            case Value_Kind.Proc:
                fmt.print("#<procedure>");
            case Value_Kind.Lambda:
                fmt.print("#<lambda>");
            case:
                fmt.print("unknown");
            }
        }
        fmt.println();
        return Value{kind = Value_Kind.Number, number = 0};
    };

    env["+"] = Value{kind = Value_Kind.Proc, procedure = add_proc};
    env["*"] = Value{kind = Value_Kind.Proc, procedure = mul_proc};
    env["-"] = Value{kind = Value_Kind.Proc, procedure = sub_proc};
    env["="] = Value{kind = Value_Kind.Proc, procedure = eq_proc};
    env["<"] = Value{kind = Value_Kind.Proc, procedure = lt_proc};
    env[">"] = Value{kind = Value_Kind.Proc, procedure = gt_proc};
    env["<="] = Value{kind = Value_Kind.Proc, procedure = lte_proc};
    env[">="] = Value{kind = Value_Kind.Proc, procedure = gte_proc};
    env["!="] = Value{kind = Value_Kind.Proc, procedure = ne_proc};
    env["print"] = Value{kind = Value_Kind.Proc, procedure = print_proc};

    return env;
}