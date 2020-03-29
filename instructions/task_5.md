# TASK 5

Your last task is add support for user-defined functions via lambda expressions. These functions will work with composition with eachother and with built-in functions. They will also work with recursion.

The final grammar will be:

```
program ::= s_expr EOL | s_expr EOFT | EOFT

s_expr ::= f_expr 
	| number 
	| SYMBOL
	| ( let_section s_expr )
	| ( cond s_expr s_expr s_expr )
	| QUIT

f_expr ::= ( FUNC s_expr_list )

s_expr_list ::= s_expr | s_expr s_expr_list

arg_list ::= symbol | symbol arg_list

FUNC ::= neg | abs | add | sub |
	mult | div | remainder | exp |
	exp2 | pow | log | sqrt |
	cbrt | hypot | max | min |
	print | read | equal | less |
	greater

let_section ::= <empty> | ( let let_list )

let_list ::= let_elem | let_list let_elem

let_elem ::= ( SYMBOL s_expr ) 
	| ( type SYMBOL s_expr )
	| ( SYMBOL lambda ( arg_list ) s_expr )
	| ( type SYMBOL lambda ( arg_list) s_expr )

SYMBOL ::= letter+

letter ::= [a-zA-Z]

number ::= INT | DOUBLE

type ::= int | double

INT ::= optional +/-,
	then some digits

DOUBLE ::= optional +/-,
	then some digits,
	then a decimal point,
	then optionally some more digits
	
QUIT ::= "quit"
```

The new productions are:

```
arg_list ::= symbol | symbol arg_list
```

```
let_elem ::= ( SYMBOL lambda ( arg_list ) s_expr )
	| ( type SYMBOL lambda ( arg_list) s_expr )
```

An example `let_elem` defining a function could be:

```
( int integerAdd lambda (x y) (add x y) )
```

The function defined above is called `integerAdd`. It takes 2 arguments, specified in its `arg_list`, called `x` and `y`. It returns the result of addition of `x` and `y`, but cast to an integer.

Function definitions will be stored in a symbol table. You may decide whether to store them in the same symbol table as variables or a separate table just for function definitions.

In either case, you will need to expand the `SYMBOL_TABLE_NODE` to specify which type of symbol is being stored; where there was only one option prior (variables) there are now three options: variable, function and argument, all of which will need to be treated differently. It is strongly recommended that arguments are placed in their own symbol table.

In order for custom functions to work recursively, you will need to implement a stack on which the argument values will be stored. The final data structures are below:

```
typedef enum {
    VAR_TYPE,
    LAMBDA_TYPE,
    ARG_TYPE
} SYMBOL_TYPE;

typedef struct symbol_table_node {
    char *id;
    AST_NODE *value;
    SYMBOL_TYPE symbolType;
    NUM_TYPE numType;
    struct stack_node *stack;
    struct symbol_table_node *next;
} SYMBOL_TABLE_NODE;

typedef struct stack_node {
    RET_VAL value;
    struct stack_node *next;
} STACK_NODE;
```

Evaluating a custom function should be done as follows:

1. Evaluate all arguments.
2. Put all argument values on the stacks of their respective `ARG_TYPE` definitions in the the function definitions argument table.
3. Evaluate the custom function definition, using the values on the top of the stack. Store the result.
4. Pop the argument values off of the top of the stack.
5. Return the result.

Straying from the sequence of instructions above may result in functions which work on their own, but do not work recursively and/or with composition.

## Sample Runs

As always, the sample runs below are minimal and are to demonstrate functionality. Your tests should be much more in-depth, and should actively seek out situations which might cause errors (as the grader's tests will).

```
> ( (let (myFunc lambda (x y) (add x y) ) ) (myFunc 1 2) )
Integer : 3

> quit

Process finished with exit code 0
```

```
> ((let (double myFunc lambda (x y) (mult (add x 5) (sub y 2)))) (sub (myFunc 3 5) 2))
Integer : 22

> quit

Process finished with exit code 0
```

```
> ((let (f lambda (x y) (add x y)))(f (sub 5 2) (mult 2 3)))
Integer : 9

> quit

Process finished with exit code 0
```

```
> ((let (int a 1)(f lambda (x y) (add x y)))(f 2 (f a 3)))
Integer : 6

> quit

Process finished with exit code 0
```

The sample run below has been doctored as follows: the input has been split into 2 lines, even though it was 1 line in the actual run, in order to allow it to fit in a markdown text block.

```
> ((let (gcd lambda (x y) (cond (greater y x) (gcd y x) (cond (equal y 0) (x) (gcd y (remainder x y))))))
(gcd 95 55))
Integer : 5

> quit

Process finished with exit code 0
```


