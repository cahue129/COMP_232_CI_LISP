# TASK 3

In this task, you will add typecasting functionality to the `let_elem`, allowing symbols to have a specified type.

The new grammar is:

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

let_list ::= let_elem | let_list let_elem

let_elem ::= ( SYMBOL s_expr ) | ( type SYMBOL s_expr )

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

You'll need to expand the `SYMBOL_TABLE_NODE` to include a `type` field (storing a `NUM_TYPE`). As such, you should also expand the `NUM_TYPE` `enum` to include a `NO_TYPE` element, for when `SYMBOL_TABLE_NODE`s are created without type-casting.

When evaluating symbols, you'll need to take their type into consideration; the `NUMBER_AST_NODE` that should be stored in the `SYMBOL_TABLE_NODE`'s contained `NUMBER_AST_NODE` after evaluation should be stored in the specified type. If this causes a loss of precision (i.e. if a double is cast as an int) then a warning should be given stating that this is the case.

This task should be quick; if you find you need to make more than a few simple changes, you're likely overthinking it!

```
> ((let (int a 1.25))(add a 1))
WARNING: precision loss on int cast from 1.25 to 1 for variable a.
Integer : 2

> ((let (double a 5))(add a .25))
ERROR: invalid character: >>.<<
Double : 30.000000

> ((let (double a 5))(add a 0.25))
Double : 5.250000

> quit

Process finished with exit code 0
```
