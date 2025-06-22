# LAP: Lisp-like Applied Processor written in Odin

## Pipeline Overview

[Source code string]
      ↓
🧱 1. **Tokenizer (Lexer)** – breaks raw input into tokens  
      ↓  
🌲 2. **Parser** – builds nested AST (usually as lists)  
      ↓  
⚙️ 3. **Evaluator (Interpreter)** – evaluates AST in an environment  
      ↓  
🧠 4. **Environment** – holds symbol definitions, user functions, variables

### License

This project is available opensource under the MIT License see [LICENSE](LICENSE) for full details
