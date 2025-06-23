package main

import "core:fmt"
import "core:strconv"
import "core:os"
import "core:strings"

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
    procedure_with_env: proc(args: []Value, env: ^Env) -> Value,
    list: []Value,
    boolean: bool,
    // Lambda-specific fields
    lambda_params: []string,
    lambda_body: []Expr,
    lambda_env: ^Env,  // Closure environment
    string: string,
}

Env :: struct {
    table: map[string]Value,
    parent: ^Env,
}

// Helper function to create error values and reduce redundancy
make_error :: proc(message: string) -> Value {
    fmt.println(message);
    return Value{kind = Value_Kind.Number, number = 0};
}

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

        // Handle string literals (consolidated approach)
        if expr.token_kind == Token_Kind.String {
            return Value{kind = Value_Kind.String, string = expr.value};
        }

        // Otherwise: symbol lookup (walk up parent chain)
        e := env;
        for e != nil {
            if val, exists := e.table[expr.value]; exists {
                return val;
            }
            e = e.parent;
        }
        return make_error(fmt.tprintf("Unbound symbol: %s", expr.value));

    case Expr_Kind.List:
        if len(expr.children) == 0 {
            return Value{kind = Value_Kind.List};
        }

        head := expr.children[0];
        args := expr.children[1:];

        // Special form: define
        if head.kind == Expr_Kind.Atom && head.value == "define" {
            if len(args) < 2 {
                return make_error("Invalid define syntax: need at least 2 arguments");
            }
            
            // (define name value)
            if args[0].kind == Expr_Kind.Atom {
                name := args[0].value;
                val := eval(args[1], env);
                env.table[name] = val;
                return val;
            }
            
            // (define (name params...) body...)
            if args[0].kind == Expr_Kind.List && len(args[0].children) > 0 {
                name := args[0].children[0].value;
                params: [dynamic]string;
                // Handle parameters (skip the first element which is the function name)
                for i := 1; i < len(args[0].children); i += 1 {
                    param := args[0].children[i];
                    if param.kind != Expr_Kind.Atom {
                        return make_error("Function parameters must be symbols");
                    }
                    append(&params, param.value);
                }
                
                // Create a closure environment that includes the function itself
                closure_env := deep_copy_env(env);
                
                // Create the lambda with all remaining expressions as the body
                lambda := Value{
                    kind = Value_Kind.Lambda,
                    lambda_params = params[:],
                    lambda_body = args[1:],
                    lambda_env = &closure_env^,
                };
                
                // Now add the function to its own environment for recursion
                closure_env.table[name] = lambda;
                
                // Also add to the current environment
                env.table[name] = lambda;
                return lambda;
            }
            
            return make_error("Invalid define syntax");
        }

        // Special form: if
        if head.kind == Expr_Kind.Atom && head.value == "if" {
            if len(args) != 3 {
                return make_error("Invalid if syntax: need condition, then, else");
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
                return make_error("Invalid lambda syntax: need parameters and body");
            }
            
            // Extract parameters
            if args[0].kind != Expr_Kind.List {
                return make_error("Lambda parameters must be a list");
            }
            
            params: [dynamic]string;
            for param in args[0].children {
                if param.kind != Expr_Kind.Atom {
                    return make_error("Lambda parameters must be symbols");
                }
                append(&params, param.value);
            }
            
            // Create lambda value with closure
            return Value{
                kind = Value_Kind.Lambda,
                lambda_params = params[:],
                lambda_body = args[1:],
                lambda_env = deep_copy_env(env),
            };
        }

        // Evaluate head to get function
        fn_val := eval(head, env);
        if fn_val.kind != Value_Kind.Proc && fn_val.kind != Value_Kind.Lambda {
            return make_error(fmt.tprintf("Head of list is not a function: %v", head.value));
        }

        // Evaluate arguments
        evaled_args: [dynamic]Value;
        for arg in args {
            append(&evaled_args, eval(arg, env));
        }

        // Apply function
        if fn_val.kind == Value_Kind.Proc {
            if fn_val.procedure_with_env != nil {
                return fn_val.procedure_with_env(evaled_args[:], env);
            } else {
                return fn_val.procedure(evaled_args[:]);
            }
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
        return make_error(fmt.tprintf("Lambda expects %d arguments, got %d", len(lambda.lambda_params), len(args)));
    }
    
    // New environment for lambda execution, chained to closure
    new_env := Env{table = make(map[string]Value), parent = lambda.lambda_env};
    
    // Bind parameters
    for param, i in lambda.lambda_params {
        new_env.table[param] = args[i];
    }
    
    // Evaluate lambda body
    result := Value{kind = Value_Kind.Number, number = 0};
    for expr in lambda.lambda_body {
        result = eval(expr, &new_env);
    }
    
    return result;
}

make_global_env :: proc() -> Env {
    env := Env{table = make(map[string]Value)};

    add_proc :: proc(args: []Value) -> Value {
        if len(args) < 2 {
            return make_error("+ requires at least 2 arguments");
        }
        result := args[0].number;
        for i := 1; i < len(args); i += 1 {
            result += args[i].number;
        }
        return Value{kind = Value_Kind.Number, number = result};
    };

    mul_proc :: proc(args: []Value) -> Value {
        if len(args) < 2 {
            return make_error("* requires at least 2 arguments");
        }
        result := args[0].number;
        for i := 1; i < len(args); i += 1 {
            result *= args[i].number;
        }
        return Value{kind = Value_Kind.Number, number = result};
    };

    sub_proc :: proc(args: []Value) -> Value {
        if len(args) < 2 {
            return make_error("- requires at least 2 arguments");
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
        return Value{kind = Value_Kind.Bool, boolean = args[0].number == args[1].number};
    };

    lt_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].number < args[1].number};
    };

    gt_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].number > args[1].number};
    };

    lte_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].number <= args[1].number};
    };

    gte_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].number >= args[1].number};
    };

    ne_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].number != args[1].number};
    };

    print_proc :: proc(args: []Value) -> Value {
        for arg, i in args {
            if i > 0 {
                fmt.print(" ");
            }
            switch arg.kind {
            case Value_Kind.Number:
                // Check if the number is a whole number
                if arg.number == f64(int(arg.number)) {
                    fmt.printf("%d", int(arg.number));
                } else {
                    // Use %g to automatically remove trailing zeros
                    fmt.printf("%g", arg.number);
                }
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
                    print_proc([]Value{child});
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

    read_proc :: proc(args: []Value) -> Value {
        if len(args) != 0 {
            return make_error("read takes no arguments");
        }
        fmt.print("> ");
        input: [1024]u8;
        n, _ := os.read(os.stdin, input[:]);
        if n == 0 {
            return Value{kind = Value_Kind.String, string = ""};
        }
        // Remove both carriage return and newline for Windows compatibility
        end := n;
        if end > 0 && input[end-1] == '\n' {
            end -= 1;
        }
        if end > 0 && input[end-1] == '\r' {
            end -= 1;
        }
        return Value{kind = Value_Kind.String, string = string(input[:end])};
    };

    eval_proc :: proc(args: []Value, env: ^Env) -> Value {
        if len(args) != 1 {
            return make_error("eval takes exactly 1 argument");
        }
        if args[0].kind != Value_Kind.String {
            return make_error("eval argument must be a string");
        }
        
        // Tokenize and parse the string
        tokens := tokenize(args[0].string);
        if len(tokens) == 0 {
            return Value{kind = Value_Kind.Number, number = 0};
        }
        
        exprs, _ := parse_exprs(tokens);
        if len(exprs) == 0 {
            return make_error("Failed to parse expression");
        }
        
        // Evaluate in the current environment
        result := Value{kind = Value_Kind.Number, number = 0};
        for expr in exprs {
            result = eval(expr, env);
        }
        return result;
    };

    load_proc :: proc(args: []Value) -> Value {
        if len(args) != 1 {
            return make_error("load takes exactly 1 argument");
        }
        if args[0].kind != Value_Kind.String {
            return make_error("load argument must be a string");
        }
        
        // Read file
        data, ok := os.read_entire_file(args[0].string);
        if !ok {
            return make_error(fmt.tprintf("Could not read file: %s", args[0].string));
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
        code := strings.join(code_lines[:], " ");
        
        // Evaluate the code
        tokens := tokenize(code);
        exprs, _ := parse_exprs(tokens);
        if len(exprs) == 0 {
            return make_error("Failed to parse file");
        }
        
        // Evaluate in a new global environment
        load_env := make_global_env();
        result := Value{kind = Value_Kind.Number, number = 0};
        for expr in exprs {
            result = eval(expr, &load_env);
        }
        return result;
    };

    concat_proc :: proc(args: []Value) -> Value {
        if len(args) < 2 {
            return make_error("concat takes at least 2 arguments");
        }
        
        result: [dynamic]u8;
        for arg in args {
            if arg.kind != Value_Kind.String {
                return make_error("concat arguments must be strings");
            }
            for char in arg.string {
                append(&result, u8(char));
            }
        }
        return Value{kind = Value_Kind.String, string = string(result[:])};
    };

    str_eq_proc :: proc(args: []Value) -> Value {
        if len(args) != 2 {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        if args[0].kind != Value_Kind.String || args[1].kind != Value_Kind.String {
            return Value{kind = Value_Kind.Bool, boolean = false};
        }
        return Value{kind = Value_Kind.Bool, boolean = args[0].string == args[1].string};
    };

    begin_proc :: proc(args: []Value) -> Value {
        if len(args) == 0 {
            return Value{kind = Value_Kind.Number, number = 0};
        }
        // Return the last argument
        return args[len(args) - 1];
    };

    env.table["+"] = Value{kind = Value_Kind.Proc, procedure = add_proc};
    env.table["*"] = Value{kind = Value_Kind.Proc, procedure = mul_proc};
    env.table["-"] = Value{kind = Value_Kind.Proc, procedure = sub_proc};
    env.table["="] = Value{kind = Value_Kind.Proc, procedure = eq_proc};
    env.table["<"] = Value{kind = Value_Kind.Proc, procedure = lt_proc};
    env.table[">"] = Value{kind = Value_Kind.Proc, procedure = gt_proc};
    env.table["<="] = Value{kind = Value_Kind.Proc, procedure = lte_proc};
    env.table[">="] = Value{kind = Value_Kind.Proc, procedure = gte_proc};
    env.table["!="] = Value{kind = Value_Kind.Proc, procedure = ne_proc};
    env.table["print"] = Value{kind = Value_Kind.Proc, procedure = print_proc};
    env.table["read"] = Value{kind = Value_Kind.Proc, procedure = read_proc};
    env.table["eval"] = Value{kind = Value_Kind.Proc, procedure_with_env = eval_proc};
    env.table["load"] = Value{kind = Value_Kind.Proc, procedure = load_proc};
    env.table["concat"] = Value{kind = Value_Kind.Proc, procedure = concat_proc};
    env.table["str="] = Value{kind = Value_Kind.Proc, procedure = str_eq_proc};
    env.table["begin"] = Value{kind = Value_Kind.Proc, procedure = begin_proc};

    return env;
}

// Deep copy the environment chain for closures
deep_copy_env :: proc(env: ^Env) -> ^Env {
    if env == nil {
        return nil;
    }
    new_env := new(Env);
    new_env.table = make(map[string]Value);
    for k, v in env.table {
        new_env.table[k] = v;
    }
    // Reference the parent, do not deep copy it
    new_env.parent = env.parent;
    return new_env;
}