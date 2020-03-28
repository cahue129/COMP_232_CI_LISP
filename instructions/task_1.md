# TASK 1

Recall **Cambridge Polish Notation** (**CPN**), in which operators and their operands are enclosed in parenthesis.

For example, `(add 1 2)` is the **CPN** equivalent of `1+2`.

Expressions in **CPN** can be nested, so the following expression would be valid, and would result in `6`.

```
(add 1 (add 2 3))
```

Your must create a functioning **CPN** calculator which works with the functions listed in the **OPER_TYPE** enum in the provided code through the **MIN_OPER** function (all functions appearing after **MIN_OPER** in the enum will be implemented in later tasks.

This calculator will serve as the core functionality for **CI-LISP**.

You may want to check out the [sample runs](#sample-runs) below better understand what will be implemented before reading further.

The initial grammar is as follows:

```
program ::= s_expr EOL | s_expr EOFT | EOFT

s_expr ::= f_expr | number | QUIT

f_expr ::= ( FUNC s_expr_list )

s_expr_list ::= s_expr | s_expr s_expr_list

FUNC ::= neg | abs | add | sub |
	mult | div | remainder | exp |
	exp2 | pow | log | sqrt |
	cbrt | hypot | max | min |
	print | read | equal | less |
	greater

number ::= INT | DOUBLE

INT ::= optional +/-,
	then some digits

DOUBLE ::= optional +/-,
	then some digits,
	then a decimal point,
	then optionally some more digits
	
QUIT ::= "quit"
```

The non-terminals **s_expr** and **f_expr** are shorthand:

* **s_expr** means *symbolic* expression
* **f_expr** means *function* expression

## DATA STRUCTURES

Next we'll discuss the structures provided in [ciLisp.h](../src/ciLisp.h). For a more intuitive understanding of the structures and their names defined here, note that **AST** is short for *__A__bstract __S__yntax __T__ree*. As such, the structures discussed below are intended to house data in an abstract syntax tree.

### NUMBERS

The **NUM\_TYPE** enum and **NUM\_AST\_NODE** struct define everything necessary to house both numeric data types (**INT_TYPE** and **DOUBLE_TYPE**) in a single struct. 

```c
typedef enum {
    INT_TYPE,
    DOUBLE_TYPE
} NUM_TYPE;

typedef struct {
    NUM_TYPE type;
    double value;
} NUM_AST_NODE;

typedef NUM_AST_NODE RET_VAL;
```

Each **NUM\_AST\_NODE** will house a member of the **NUM\_TYPE** enum (denoting the type of number being stored) alongside value of that number (always stored as a *double*).

The last line, which gives the **NUM\_AST\_NODE** struct a second name (**RET\_VAL**), exists exclusively for readability. When we evaluate a part of our syntax tree, the result will always be a number. We will use **NUM\_AST\_NODE**s to house numbers which are *part of* the syntax tree, and **RET\_VAL**s to house the results of evaulation (*__RET__urned __VAL__ues*).

### FUNCTIONS

Note that the terms "operator" and "function" will be used interchangeably.

We'll start our discussion of data structures for function 

```c
typedef enum oper {
    NEG_OPER,
    ABS_OPER,
    ADD_OPER,
    SUB_OPER,
    MULT_OPER,
    DIV_OPER,
    REMAINDER_OPER,
    EXP_OPER,
    EXP2_OPER,
    POW_OPER,
    LOG_OPER,
    SQRT_OPER,
    CBRT_OPER,
    HYPOT_OPER,
    MAX_OPER,
    MIN_OPER,
    PRINT_OPER,
    READ_OPER,
    RAND_OPER,
    EQUAL_OPER,
    LESS_OPER,
    GREATER_OPER,
    CUSTOM_OPER
} OPER_TYPE;
```

This enum lists all functions which will be implemented throughout the course of the project. Most of them (all of the functions appearing before **PRINT_OPER** in the enum) will be implemented in this first task.

When function calls are parsed as **f_expr**s, the data for said calls will be stored in a **FUNC\_AST\_NODE**

```c
typedef struct {
    OPER_TYPE oper;
    char *ident;
    struct ast_node *opList;
} FUNC_AST_NODE;
```

This struct stores the operator used in the function call (a member of the **OPER_TYPE** enum) and the list of operands to use as inputs for the function (a linked list of **ast\_node**s).

It also houses a *char \** so it can store the identifier of the function in string form. Note that this is only necessary for user defined functions (functions of type **CUSTOM_OPER**), which will be implemented in a later task. The **ident** field in the **FUNC\_AST\_NODE** should not be populated for any other functions. Instead, the **oper** field should be assigned to the **OPER_TYPE** member corresponding to the function name.

Take note of the `resolveFunc` function defined in [ciLisp.c](../src/ciLisp.c). This function takes as input a function's name, and outputs the corresponding **OPER_TYPE** member. It will be used to populate the **oper** field in each **FUNC\_AST\_NODE** while parsing.

Also note that the `resolveFunc` works because the array of function names (`funcNames`, in [ciLisp.c](../src/ciLisp.c)) lists all functions in the same order as the **OPER_TYPES** enum. If either of these is edited, the other must also be edited to match.

### GENERIC NODES

We've already discussed two types of abstract syntax tree nodes for housing numbers and functions. In order to make these types of nodes interchangeable, it is necessary to wrap them in a generic abstract syntax tree node which can store either type of node.

As such, we have the **AST\_NODE** type:

```c
typedef enum {
    NUM_NODE_TYPE,
    FUNC_NODE_TYPE
} AST_NODE_TYPE;

typedef struct ast_node {
    AST_NODE_TYPE type;
    union {
        NUM_AST_NODE number;
        FUNC_AST_NODE function;
    } data;
    struct ast_node *next;
} AST_NODE;
```

An **AST\_NODE** stores a member of the **AST\_NODE\_TYPE** enum in it's **type** field, so it can be determined what type of node is housed in its **data** field (a union which can store either a **NUM\_AST\_NODE** or a **FUNC\_AST\_NODE**). It also stores a pointer to the another **AST\_NODE** in its **next** field, which allows **AST_NODE**s to be stored in a linked list style for use as operands (see the **opList** field in **FUNC\_AST\_NODE**).

## Tokenization

First, it is necessary to define all tokens and all non-terminals within the grammar. **token**s (and non-terminals, called **type**s by yacc), will be defined in [ciLisp.y](../src/ciLisp.y). The provided tokenization and parse definitions are:

```bison
%union {
    double dval;
    char *sval;
    struct ast_node *astNode;
};

%token <sval> FUNC
%token <dval> INT DOUBLE
%token LPAREN RPAREN EOL QUIT EOFT

%type <astNode> s_expr f_expr number s_expr_list
```

The union contains all types that **token**s and **type**s will have. In this case, **token** and **type** values will all be stored as *double*, *char \** or *ast_node \**. (We will discuss the *ast_node* type later in this document).

The following three lines define tokens as follows:

* **FUNC** tokens, with data stored as *char \**
* **INT** and **DOUBLE** tokens, with data stored as *double*
* **LPAREN**, **RPAREN**, **EOL**, **QUIT** and **EOFT** tokens, with no stored value (the tokens themselves convey all necessary information)

The token definitions are followed by type definitions. The data for types **s_expr**, **f_expr** and **number** is stored in *ast_node \** form. We will discuss these further after we finish discussion of tokenization.

The tokens defined by the yacc file must be tokenized. As we know, the lex file is used to configure a tokenizer.

The provided [ciLisp.l](../src/ciLisp.l) is only partially complete. It has rules to tokenize and return some tokens, but not all of them. You must complete it. Identify all missing tokens and tokenize them. Use the syntax for the provided tokenizations as an example. Refer to the Bison and Flex documentation for a regular expression reference.

Use the **INT** tokenization as an example for double (pay attention to how the value of the token is stored as a double). Note how the string value (representing function names) is stored alongside **FUNC** tokens; you will not need to assign string values to any other tokens other than **FUNC** yet, but you will in later tasks.

While there is a rule to tokenize functions, most of the function names are missing and therefore won't be tokenized until they are added!

Pay attention to the `llog` calls made for debugging purposes each time a token is created.  These calls will place messages in the `flex_bison.log` file in the `logs` directory, which will be useful for debugging purposes.

## PARSING

The goal of the parser is to construct an abstract syntax tree after tokenization. Most of the productions in your grammar will have an equivalent production in [ciLisp.y](../src/ciLisp.y), which is the configuration file for the parser.

The first set of productions in [ciLisp.y](../src/ciLisp.y) are for parsing programs:

```bison
program:
    s_expr EOL {
        ylog(program, s_expr EOL);
        if ($1) {
            printRetVal(eval($1));
            YYACCEPT;
        }
    }
    | s_expr EOFT {
        ylog(program, s_expr EOFT);
        if ($1) {
            printRetVal(eval($1));
        }
        exit(EXIT_SUCCESS);
    }
    | EOFT {
        exit(EXIT_SUCCESS);
    };
```

is the implementation of the first production in the grammar itself:

```
program ::= s_expr EOL | s_expr EOFT | EOFT
```

The first part of the production configuration `program: s_expr EOL` denotes that when parsing a **program** can be created via reduction from an **s_expr** followed by an **EOL** token. The values of this **s_expr** and **EOL** can be referenced with `$1` and `$2` respectively. If there were a third element in the reduction to a **program**, that third element's value could be references with `$3` and so on.

The rest of the production, this block:

```bison
{
    ylog(program, s_expr EOL);
    if ($1) {
        printRetVal(eval($1));
        YYACCEPT;
    }
}
```

denotes what should be done when that reduction is made.

The `ylog` call is a debug print (made to `logs/bison_flex.log`), stating which reduction was made. Any productions that you implement should include similar `ylog` calls. The `YYACCEPT` definition essentially means "we're done here, that was a valid program". Step through the generated parser in the `src/bison` directory after running if you want to know more about it.

The line `printRetVal(eval($1))` first calls the `eval` function on `$1` and then prints the resulting **RET\_VAL**. Note that `$1` is the value of the **s_expr** being used in the reduction, and that any **s_expr**'s value is an **AST\_NODE \*** as defined further up in [ciLisp.y](../src/ciLisp.y).

Then, the line `freeNode($1)` recursively frees the abstract syntax tree, starting from the **AST_NODE** references by `$1`, which is the root of the tree.

The rest of the yacc file is incomplete. Some productions are missing bodies, while others are missing entirely:

```bison
s_expr:
    number {
        ylog(s_expr, number);
        $$ = $1;
    }
    | f_expr {

    }
    | QUIT {
        ylog(s_expr, QUIT);
        exit(EXIT_SUCCESS);
    }
    | error {
        ylog(s_expr, error);
        yyerror("unexpected token");
        $$ = NULL;
    };

number:
    INT {

    };

f_expr:
    LPAREN FUNC s_expr_list RPAREN {
        
    };

s_expr_list:
    s_expr {
        ylog(s_expr_list, s_expr);
        $$ = $1;
    };
```

Note that `$$`, wherever it appears, references the value that should be assigned to the result of the reduction. For instance, in the `s_expr: number` production, `$$ = $1;` means "assign to the **s_expr** being created the value of the **number** which comprises it". **s_expr** and **number** both have type **AST_NODE \*** (as defined earlier in [ciLisp.y](../src/ciLisp.y)), so this assignment is perfectly valid.

The goal in *most* productions is to assign value to the syntax tree element being reduced to based on the values of the elements from which it is being composed. This often requires either the creation and population of an appropriate struct instance or adding references between existing struct instances.

The figure below (which can be found [here](../figures/task_1/task_1.png)) may help you visualize what needs to be done. Note that some reductions in the grammar are not illustrated in the figure.

![figure_t1](../figures/task_1/task_1.png)

Many of these productions will need to call the functions declared at the bottom of [ciLisp.h](../src/ciLisp.h):

```c
AST_NODE *createNumberNode(double value, NUM_TYPE type);
AST_NODE *createFunctionNode(char *funcName, AST_NODE *opList);
AST_NODE *addOperandToList(AST_NODE *newHead, AST_NODE *list);
```

These functions need to be defined in [ciLisp.c](../src/ciLisp.c); some of their definitions are partially completed already. They all already exist in [ciLisp.c](../src/ciLisp.c) and are heavily commented, detailing what each function needs to do.

Whenever a function needs to be accessible by the parser (that is, if the config file [ciLisp.y](../src/ciLisp.y) calls it) it must be declared in [ciLisp.h](../src/ciLisp.h).

For instance, in the `number: INT` production, you will likely want to assign `$$` (the value of the **number**) to the result of a call to `createNumberNode`, which should create an **AST_NODE** housing a **NUMBER\_AST\_NODE** whose data is populated with that from the **INT** token.

## EVALUATION

### GENERIC EVALUATION

Once parsing is complete (i.e. when a series of tokens is reduced to a sequence `s_expr EOL`, the contents of a single program) the `eval` function is called on the root **s_expr**. This function is the entry point for a recursive system of functions whose purpose is to evaluate the syntax tree and output the resulting **RET_VAL**.

The `eval` function takes as input a generic **AST_NODE \***. Its job is to determine which type of **AST_NODE** is referrenced and call the corresponding function to evaluate it. During this task, this means determining if the referenced **AST_NODE** is of type **NUM\_NODE\_TYPE** or **FUNC\_NODE\_TYPE** and calling `evalNumNode` or `evalFuncNode` on it respectively.

### NUMBER EVALUATION

`evalNumNode` should be quick and easy, and we will not discuss it further here.

### FUNCTION EVALUATION

`evalFuncNode` should check which **OPER_TYPE** the **FUNCTION\_AST\_NODE** uses, and call an appropriate function to evaluate the result of running that operation with the input referenced linked list of operands.

You will need to create functions to evaluate each of these operations given their inputs. The remaining function types in the `FUNC_TYPE` enumeration will be defined later in the project.

* neg
	* unary
	* returns the negation of the operand
	* i.e. given *x* returns -*x*
* abs
	* unary
	* returns the absolute value of the operand
* add
	* *n*-ary
	* returns the sum of its operands
	* return type depends on input types
	* if given no inputs, prints warning and returns 0 as an integer
* sub
	* binary
	* returns result of subtracting second operand from first operand
	* return type depends on operand types
* mult
	* *n*-ary
	* returns the product of the operands
	* return type depends on operand types
	* if given no inputs, prints warning and returns 1 as an integer
* div
	* binary
	* returns the result of division of the first operand by second operand
	* return type depends on operand types
	* floor division if done with 2 integers
* remainder
	* binary
	* returns remainder of first operand divided by second operand
	* works for doubles as well, remainder after floor division
	* return type depends on operand types
	* return must be non-negative
* exp
	* unary
	* returns _e_ raised to the specified power
	* always returns a double
* exp2
	* unary
	* returns _2_ raised to the specified power
	* if operand is negative, return type is always double
	* otherwise, return type depends on operand type
* pow
	* binary
	* returns first operand raised to power of second operand
	* return type depends on operand types
* log
	* unary
	* returns natural log of operand
	* always returns a double
* sqrt
	* unary
	* returns the square root of the operand
	* always returns a double
* cbrt
	* unary
	* returns the cube root of the input
	* always returns a double
* hypot
	* *n*-ary
	* returns the square root of the sum of squares of operands
	* if given no inputs, prints a warning and returns 0
	* always returns a double
* max
	* *n*-ary
	* returns maximum value among the operands
	* return type is the type of the maximum operand
	* if given no operands, throws an error
* min
	* *n*-ary
	* returns minimum value among the operands
	* return type is the type of the minimum operand
	* if given no operands, throws an error

Unary functions take 1 operand, binary take 2 operands, and *n*-ary take any number of operands. Functions which are given too few operands should throw errors (see `yyerror` in [ciLisp.c](../src/ciLisp.c) and [ciLisp.h](../src/ciLisp.h)). Functions which are given too many operands should print a warning stating that the extra operands were ignored (see `printWarning` in [ciLisp.c](../src/ciLisp.c), and only use the required number of operands in calculation. Whenever an error is thrown, the function which threw it should return an integer with value `NAN` (short for "not a number").

Check out the `math` library (open the console and type `man math` to get its documentation) before starting these implementations. Note that many of the `math` library functions don't quite work how we want them to (for instance, `math`'s `remainder` can return a negative value, and our implementation needs to deal with that).

## DISPLAYING VALUES

In order to see our outputs, it is necessary to define a function to print **RET_VAL** data. You will need to complete the `printRetVal` function in [ciLisp.c](../src/ciLisp.c) to this end. Check the sample runs below to see how outputs should be [formatted](https://en.cppreference.com/w/c/io/fprintf).

## <a name="sample-runs"></a>SAMLPLE RUNS

Inputs are on the same line as the `>`, and the output is printed below (along with any warnings). These sample runs are 

### neg
```
> (neg 5)
Integer : -5

> (neg 5.5)
Double : -5.500000

> (neg -5.0)
Double : 5.000000

> (neg -5)
Integer : 5

> (neg)
ERROR: neg called with no operands!
Integer : nan

> (neg 1 2)
WARNING: neg called with extra (ignored) operands!
Integer : -1

> quit

Process finished with exit code 0
```

### abs
```
> (abs 1)
Integer : 1

> (abs 1.2)
Double : 1.200000

> (abs -3)
Integer : 3

> (abs 0)
Integer : 0

> (abs 0.0)
Double : 0.000000

> (abs -1.4)
Double : 1.400000

> (abs)
ERROR: abs called with no args.
Integer : nan

> (abs -1 2)
WARNING: abs call with extra operands. Only first operand used!
Integer : 1

> quit

Process finished with exit code 0
```

### add
```
> (add)
WARNING: add call with no operands, 0 returned!
Integer : 0

> (add 1)
Integer : 1

> (add 1.0)
Double : 1.000000

> (add 1 2 3 4 5)
Integer : 15

> (add 1 -2 3 -4 5 -6)
Integer : -3

> (add 0.0 1 -2 3 -4 5 -6)
Double : -3.000000

> (add 1 -1.0)
Double : 0.000000

> quit

Process finished with exit code 0
```

### sub
```
> (sub)
ERROR: sub called with no operands!
Integer : nan

> (sub 1)
ERROR: sub called with only one arg!
Integer : nan

> (sub 1.0)
ERROR: sub called with only one arg!
Integer : nan

> (sub 1 2)
Integer : -1

> (sub 2 1)
Integer : 1

> (sub 2 -1)
Integer : 3

> (sub 2.0 1)
Double : 1.000000

> (sub 2.0 -1)
Double : 3.000000

> (sub 1 1.0)
Double : 0.000000

> (sub 2.0 1.0)
Double : 1.000000

> (sub 1 2 3)
WARNING: sub called with extra (ignored) operands!
Integer : -1

> quit

Process finished with exit code 0
```

### mult
```
> (mult)
WARNING: mult call with no operands, 1 returned!
Integer : 1

> (mult 1)
Integer : 1

> (mult 1.0)
Double : 1.000000

> (mult -1)
Integer : -1

> (mult -1 -1.0)
Double : 1.000000

> (mult 1 -2 3 -4 5)
Integer : 120

> (mult -1.0 2 -3.0 4 -5)
Double : -120.000000

> quit

Process finished with exit code 0
```


### div
```
> (div)
ERROR: sub called with no operands!
Integer : nan

> (div 1)
ERROR: sub called with only one arg!
Integer : nan

> (div 1.0)
ERROR: sub called with only one arg!
Integer : nan

> (div 1 2)
Integer : 0

> (div 1.0 2)
Double : 0.500000

> (div 2 1)
Integer : 2

> (div 2.0 1)
Double : 2.000000

> (div 5 2.0)
Double : 2.500000

> (div -20.0 4)
Double : -5.000000

> (div 1 2 3 4)
WARNING: sub called with extra (ignored) operands!
Integer : 0

> (div 1 2 3)
WARNING: sub called with extra (ignored) operands!
Integer : 0

> (div 5.0 2 3)
WARNING: sub called with extra (ignored) operands!
Double : 2.500000

> quit

Process finished with exit code 0
```

### remainder
```
> (remainder)
ERROR: remainder called with no operands.
Integer : nan

> (remainder 1)
ERROR: remainder called with one arg.
Integer : nan

> (remainder 0)
ERROR: remainder called with one arg.
Integer : nan

> (remainder -1.0)
ERROR: remainder called with one arg.
Integer : nan

> (remainder 1 2)
Integer : 1

> (remainder 2 1)
Integer : 0

> (remainder 2.5 1)
Double : 0.500000

> (remainder 2 3)
Integer : 2

> (remainder -6 10)
Integer : 4

> (remainder -6.0 10.0)
Double : 4.000000

> (remainder -6.0 -10.0)
Double : 4.000000

> (remainder 1 2 3)
WARNING: remainder called with extra (ignored) operands!
Integer : 1

> (remainder 23 7 10)
WARNING: remainder called with extra (ignored) operands!
Integer : 2

> quit

Process finished with exit code 0
```

### exp
```
> (exp)
ERROR: exp called with no operands!
Integer : nan

> (exp 1)
Double : 2.718282

> (exp (log 1))
Double : 1.000000

> (exp -1)
Double : 0.367879

> (exp 5.0)
Double : 148.413159

> (exp -2.0)
Double : 0.135335

> (exp 1 2)
WARNING: exp called with extra (ignored) operands!
Double : 2.718282

> quit

Process finished with exit code 0
```

### exp2
```
> (exp2)
ERROR: exp2 called with no operands!
Integer : nan

> (exp2 1)
Integer : 2

> (exp2 1.0)
Double : 2.000000

> (exp2 0)
Integer : 1

> (exp2 0.0)
Double : 1.000000

> (exp2 0.5)
Double : 1.414214

> (exp2 (div 1 2.0))
Double : 1.414214

> (exp2 -2)
Double : 0.250000

> (exp2 -2.0)
Double : 0.250000

> (exp2 1 2)
WARNING: exp2 called with extra (ignored) operands!
Integer : 2

> quit

Process finished with exit code 0
```

### pow
```
> (pow)
ERROR: pow called with no operands!
Integer : nan

> (pow 1)
ERROR: pow called with only one arg!
Integer : nan

> (pow 1.0)
ERROR: pow called with only one arg!
Integer : nan

> (pow 1 1)
Integer : 1

> (pow 1 1.0)
Double : 1.000000

> (pow 2 1)
Integer : 2

> (pow 2.1 1)
Double : 2.100000

> (pow -2 0.5)
Double : nan

> (pow -2 0)
Integer : 1

> (pow -2.0 0.0)
Double : 1.000000

> (pow -2.0 0)
Double : 1.000000

> (pow 3 3)
Integer : 27

> (pow 3.0 3)
Double : 27.000000

> (pow 27 (div 1 3.0))
Double : 3.000000

> (pow 1 2 3)
WARNING: pow called with extra (ignored) operands!
Integer : 1

> quit

Process finished with exit code 0
```

### log
```
> (log)
ERROR: log called with no operands!
Integer : nan

> (log 1)
Double : 0.000000

> (log 0)
Double : -inf

> (log -1)
Double : nan

> (log 0.0)
Double : -inf

> (log -1.0)
Double : nan

> (log (exp 1))
Double : 1.000000

> (div (log 27) (log 3))
Double : 3.000000

> (div (log 27.0) (log 3))
Double : 3.000000

> (log 1 2)
WARNING: log called with extra (ignored) operands!
Double : 0.000000

> quit

Process finished with exit code 0
```

### sqrt
```
> (sqrt)
ERROR: sqrt called with no operands!
Integer : nan

> (sqrt 1)
Double : 1.000000

> (sqrt 1.0)
Double : 1.000000

> (sqrt 0)
Double : 0.000000

> (sqrt 0.0)
Double : 0.000000

> (sqrt -1)
Double : nan

> (sqrt -1.0)
Double : nan

> (sqrt 4)
Double : 2.000000

> (sqrt 4.0)
Double : 2.000000

> (sqrt 2)
Double : 1.414214

> (sqrt 1 2)
WARNING: sqrt called with extra (ignored) operands!
Double : 1.000000

> quit

Process finished with exit code 0
```

### cbrt
```
> (cbrt)
ERROR: cbrt called with no operands!
Integer : nan

> (cbrt 0)
Double : 0.000000

> (cbrt 0.0)
Double : 0.000000

> (cbrt -1)
Double : -1.000000

> (cbrt -1.0)
Double : -1.000000

> (cbrt 1)
Double : 1.000000

> (cbrt 1.0)
Double : 1.000000

> (cbrt 27)
Double : 3.000000

> (cbrt 27.0)
Double : 3.000000

> (cbrt 4)
Double : 1.587401

> (cbrt (pow 3 3))
Double : 3.000000

> (cbrt (pow 3 6))
Double : 9.000000

> (cbrt 1 2)
WARNING: cbrt called with extra (ignored) operands!
Double : 1.000000

> quit

Process finished with exit code 0
```

### hypot
```
> (hypot)
ERROR: hypot called with no operands, 0.0 returned!
Double : 0.000000

> (hypot 1)
Double : 1.000000

> (hypot 1.0)
Double : 1.000000

> (hypot 3 4)
Double : 5.000000

> (hypot -3 4)
Double : 5.000000

> (hypot -30 -40.0)
Double : 50.000000

> (hypot 4 4 7)
Double : 9.000000

> (hypot 7.0 4 4.0)
Double : 9.000000

> (hypot 12 13 14)
Double : 22.561028

> (hypot 5 5 5)
Double : 8.660254

> (hypot -5 -5.0 (sqrt 25))
Double : 8.660254

> (hypot 0 0 0.0 -3 0 0 0 0 4 0.0 -0.0 12)
Double : 13.000000

> quit

Process finished with exit code 0
```

### max
```
> (max)
ERROR: max called with no operands!
Integer : nan

> (max 1)
Integer : 1

> (max -1)
Integer : -1

> (max 1.0)
Double : 1.000000

> (max 	232311.121)
Double : 232311.121000

> (max 1 2 3 4 5 6 7 8.0 9)
Integer : 9

> (max 1 2 25.0 -26.0 12)
Double : 25.000000

> quit

Process finished with exit code 0
```

### min
```
> (min)
ERROR: min called with no operands!
Integer : nan

> (min 1)
Integer : 1

> (min 0.0)
Double : 0.000000

> (min 0)
Integer : 0

> (min -1 2 -3 4 -5 6)
Integer : -5

> (min -1.0 -12.0 12)
Double : -12.000000

> quit

Process finished with exit code 0
```

### composition tests
Note that you should perform tests to ensure that none of your functions break when composed. Below are a few examples, but you should do more than just the tests below.

```
> (log (exp (log (exp 1))))
Double : 1.000000

> (sub (mult 1 2 3 4) (add 1 2 3 4))
Integer : 14

> (sub (mult 1 2 3 -4.0) (add -1 -2 -3 -4))
Double : -14.000000

> (hypot (sqrt (div 100 7.0)) (mult 6 (sqrt (div 100.0 7))))
Double : 22.990681

> (hypot (sqrt (div 100 7.0)) (sqrt (mult 6 (div 100.0 7))))
Double : 10.000000

> (add 1 (add 2 (add 3 (add 4 (add 5 (add 6 (add 7)))))))
Integer : 28

> (add 1 (add 2 (add 3 (add 4 (add 5 (add 6 (sub 0 -7.0)))))))
Double : 28.000000

> quit

Process finished with exit code 0
```





