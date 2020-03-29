# TASK 4

In this task, you will:

* Implement the `rand`, `read`, `equal`, `less`, `greater` and `print` functions.
* Implement conditionals (CI Lisp's equivalent of the `if` statement, or ternary operator)

The functions will will work as follows:

* `rand`
	* no arguments
	* generates and returns random `double` between `0` and `1`
	* C's `rand` function generates an `int` from `0` to `RAND_MAX`; you'll need to find a way to map its outputs to doubles between 0 and 1.
	* you are not required to seed here, meaning your `rand` calls will output the same sequence of numbers in each run. You may choose to seed if you are interested in getting more random outputs; I recommend using some easy source changing data (like the clock time) to get seeds if you choose to do so.
* `read`
	* no arguments
	* prints `read :: ` to the `stdout`, and gets the users response (from `stdin`, which is either the console or a file depending on how you're feeding inputs in). If the user's response is an `int` or `double` literal, as defined by CI Lisp's grammar, `read` returns the corresponding number. If the user's response is invalid, it should print a message stating such and then prompt again, infinitely, until the user enters a valid input.
* `equal`, `less`, `greater`
	* binary
	* returns an `int` with value `1` if the condition holds (i.e. if the first argument is equal to, less than, greater than the second respectively). returns an `int` with value `0` otherwise.
* `print`
	* n-ary
	* evaluates and prints all operands. returns the **last** operand.
	* should be very simple, as `printRetVal` should already be implemented.

The conditional operator will require expanding the grammar:

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

This expansion adds 1 new keyword (`cond`) and 1 new production:

```
s_expr ::= ( cond s_expr s_expr s_expr )
```

A conditional expression contains 3 `s_expr`s. If the first `s_expr` (the condition) is nonzero (i.e. "true"), then the conditional returns the value of the second `s_expr` is returned. Otherwise, the condition is 0 (i.e. "false") so the third `s_expr`'s value is returned.

If `A`, `B` and `C` are expressions, then CI Lisp's `( cond A B C )` is the equivalent of `A ? B : C` in C (the ternary operator).

This will require the addition of a new type of `AST_NODE` called the `COND_AST_NODE`; it should store three `AST_NODE *`s (the pointers to `A`, `B` and `C` in the example above). You will also need to expand the `AST_NODE` struct itself to allow it to house `COND_AST_NODE`s alongside the other node types.

## Sample Runs

There are some sample runs below demonstrating the new functionality in very simple statments (and some of the old functionality). Yours, of course, should also verify that all old functionality is still intact, and that they interact without error with the new functions.

Make sure you understand why each value printed in each run below is printed. Note that the result of the full program evaluation is always printed, so the last print is not from a call to the `print` function.

```
> (print 1)
Integer : 1
Integer : 1

> (add 1 (print 2) )
Integer : 2
Integer : 3

> (add 1 (print 2 3 4 ) )
Integer : 2
Integer : 3
Integer : 4
Integer : 5

> quit

Process finished with exit code 0
```

```
> (rand)
Double : 0.000008

> (rand)
Double : 0.131538

> (rand)
Double : 0.755605

> (rand)
Double : 0.458650

> (rand)
Double : 0.532767

> (rand)
Double : 0.218959

> (rand)
Double : 0.047045

> (rand)
Double : 0.678865

> (rand)
Double : 0.679296

> quit

Process finished with exit code 0
```

The sample run below provides an opportunity to test that specifications were followed in task 2. If `x` has different values in the first two prints, then variable evaluation is not being done as specified. The value stored in the symbol table should be replaced with an `AST_NODE` housing **just a `NUMBER_AST_NODE` value** the first time `x` is evaluated, so the second time should not generated a second random number.

The third printed value below is, of course, the result of the entire expression, which is `x + x`.

```
> ( ( let (x (rand)) ) (add (print x) (print x) ) )
Double : 0.000008
Double : 0.000008
Double : 0.000016

> quit

Process finished with exit code 0
```

```
> (equal 0 0)
Integer : 1

> (equal 0 0.0)
Integer : 1

> (equal 0 0.1)
Integer : 0

> (less 0 0)
Integer : 0

> (less -1 0)
Integer : 1

> (less 0 -1.0)
Integer : 0

> (greater 0 1)
Integer : 0

> (greater 1 0)
Integer : 1

> (greater 0 0.0)
Integer : 0

> quit

Process finished with exit code 0
```

```
> ( ( let (x 0) (y 1) ) (less x y) )
Integer : 1

> quit

Process finished with exit code 0
```

```
> (cond 0 5 6)
Integer : 6

> (cond 1 5 6)
Integer : 5

> (cond (less 0 1) 5 6)
Integer : 5

> (cond (less 1 0) 5 6)
Integer : 6

> quit

Process finished with exit code 0
```

Note that while `x` and `y` are both accessed twice below, there is only a single `read` call for each one; if `x`'s definition is left as a function node containing a `read` call after the first evaluation, then `read` will be incorrectly called again, but if `x`'s definition is replaced with a numerical value the first time it is accessed, then the second access simply gets this numerical value.

```
> ( ( let (x (read)) ) (print x) )
read :: 1
Integer : 1
Integer : 1

> ( ( let (x (read)) (y (read)) ) (print x x y y) )
read :: 1
Integer : 1
Integer : 1
read :: 2
Integer : 2
Integer : 2
Integer : 2

> quit

Process finished with exit code 0
```
