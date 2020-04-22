# TASK 2

Here you will add support for definition and evaluation of variables (called **symbols** in Lisp jargon). Check out the updated grammar:

```
program ::= s_expr EOL | s_expr EOFT | EOFT

s_expr ::= f_expr 
	| number 
	| SYMBOL
	| ( let_section s_expr )
	| QUIT

f_expr ::= ( FUNC s_expr_list )

s_expr_list ::= s_expr | s_expr s_expr_list

FUNC ::= neg | abs | add | sub |
	mult | div | remainder | exp |
	exp2 | pow | log | sqrt |
	cbrt | hypot | max | min |
	print | read | equal | less |
	greater

let_section ::= <empty> | ( let let_list )

let_list ::= let_elem | let_elem let_list

let_elem ::= ( SYMBOL s_expr )

SYMBOL ::= letter+

letter ::= [a-zA-Z]

number ::= INT | DOUBLE

INT ::= optional +/-,
	then some digits

DOUBLE ::= optional +/-,
	then some digits,
	then a decimal point,
	then optionally some more digits
	
QUIT ::= "quit"
```

You will need to update your project to support this new grammar.

Symbol tokenization should be a walk in the park; just make sure it comes after the function and keyword tokenizations in the lex file so that functions and keywords aren't tokenized as symbols!

A `let_elem` defines a symbol. Its children are a `SYMBOL` token and an `s_expr`, the idea being to define a symbol using the identifier stored in the `SYMBOL` token and the `AST_NODE` which stores the `s_expr`.

Below are some expressions which use symbols. Note that anywhere an `s_expr` can exist, the sequence `( let_section s_expr )` can also exist, so symbol definitions can appear in nested scopes.

```
( (let (x 1) ) x )

(add ((let (abc 1)) (sub 3 abc)) 4)
 
(mult ((let (a 1) (b 2)) (add a b)) (sqrt 2))
 
(add ((let (a ((let (b 2)) (mult b (sqrt 10))))) (div a 2)) ((let (c 5)) (sqrt c)))

((let (first (sub 5 1)) (second 2)) (add (pow 2 first) (sqrt second)))

((let (abc 1)) (sub ((let (abc 2) (de 3)) (add abc de)) abc))
```

First, you'll need a way to store symbols in `AST_NODE`s, just like you have already stored numbers and functions. You'll want to modify the `AST_NODE_TYPE` enum and create the `SYM_AST_NODE` struct to store symbol data:

```c
typedef enum {
    NUM_NODE_TYPE,
    FUNC_NODE_TYPE,
    SYM_NODE_TYPE
} AST_NODE_TYPE;

typedef struct {
    char* id;
} SYM_AST_NODE;
```

You should use a linked list of symbols in each scope to keep track of the symbol names alongside their values. You may want to use this struct (or something similar) for this linked list:

```c
typedef struct symbol_table_node {
    char *id;
    AST_NODE *value;
    struct symbol_table_node *next;
} SYMBOL_TABLE_NODE;
```

And to link each scope to its contained symbol table and to parent scopes, and to allow `SYM_AST_NODE`s to be stored in generic `AST_NODE`s you'll want to modify the `AST_NODE` struct:

```c
typedef struct ast_node {
    AST_NODE_TYPE type;
    struct ast_node *parent;
    struct symbol_table_node *symbolTable;
    union {
        NUM_AST_NODE number;
        FUNC_AST_NODE function;
        SYM_AST_NODE symbol;
    } data;
    struct ast_node *next;
} AST_NODE;
```

You will need to add methods for symbol creation, for linking symbol table nodes together into linked lists, for linking said linked lists of symbol table nodes up to the `AST_NODE`s whose scope they are in, and for looking through these symbol tables to find values.

You will also need to edit functions that you've already created in order to assign parents to child `AST_NODE`s. Specifically, the parent of the values in an `s_expr_list` is the `s_expr` housing the `f_expr` for which the `s_expr_list` is the argument list.

Note that when evaluating symbols, you need to look not only through the local symbol table but also through those in parent scopes; this is what the `parent` pointer should be used for. If an undefined variable is evaluated, the `DEFAULT_RET_VAL` (an `INT_TYPE` with `NAN` value) should be returned and an error should be printed.

Whenever a symbol is evaluated, its value in the symbol table will be stored as an `AST_NODE`. That `AST_NODE` should be evaluated (whatever type it is). Then, if the `AST_NODE` as not a number node, it should be replaced with a number node storing the value which resulted from evaluating the original `AST_NODE`.

## SAMPLE RUNS

```
> ( (let (x 1) ) x )
Integer : 1

> (add ((let (abc 1)) (sub 3 abc)) 4)
Integer : 6

> (mult ((let (a 1) (b 2)) (add a b)) (sqrt 2))
Double : 4.242641

> (add ((let (a ((let (b 2)) (mult b (sqrt 10))))) (div a 2)) ((let (c 5)) (sqrt c)))
Double : 5.398346

> ((let (first (sub 5 1)) (second 2)) (add (pow 2 first) (sqrt second)))
Double : 17.414214

> ((let (abc 1)) (sub ((let (abc 2) (de 3)) (add abc de)) abc))
Integer : 4

> ((let (abc 1)) (sub ((let (abc 2)) (add abc de)) abc))
ERROR: Undefined Symbol!
Integer : nan

> QUIT
ERROR: Undefined Symbol!
Integer : nan

> quit

Process finished with exit code 0
```

