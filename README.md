# CI LISP

Read **everything in this file** before opening the instructions for the individual tasks. You are responsible for understanding the grading structure before starting, and you will likely miss **tons of points** in documentation if you do not.

## Summary

Through the course of this project, you will implement an interpreter for *CI LISP*, a *Lisp*-like language.

The project is divided into tasks, which should be done sequentially and are listed in the [TASKS](#tasks) section below.

## Submission Requirements

You **must** submit once for **each task**, with documentation showing sample runs sufficient to verify that all new functionality works as intended and that no old functionality has been broken. For example, your submission documentation for task 1 should show that all functionality for task 1 works, and that for task 2 should show that everything from tasks 2 works and that everything from task 1 still works with your updated implementation.

Your most recent submission will be the only one graded, usually. However, if your most recent submission breaks functionality that was implemented in prior tasks, we can give full credit for those prior tasks and only dock points on the task that broke things.

Consider, for example, the situation in which your submitted task 5 broke some features from task 3 and 4. If your task 3 submission had everything in tasks 1-3 working and documented, and your task 4 submission had everythin in tasks 1-4 working and documented, then you will receive full points for tasks 3 and 4 and will be docked some points from task 5. If, on the other hand, you did not submit fully functional projects for tasks 3 and 4, it will be assumed that they never worked and you will lose points on tasks 3, 4 and 5 (as tasks 3 and 4 are prerequisite to 5, because some functionality in 5 relies on that from 3 and 4).

## Documentation Requirements

Documentation will be worth 25% of the project grade, but submissions made with no documentation will not be graded and will receive no points.

Documentation will be graded based on **readability**, **completeness**, and **accuracy**.

Students will only receive points for functionality which is demonstrated to be working in the documentation. If you successfully complete all 5 tasks but only document tasks 1 and 5, you will only received credit for tasks 1 and 5.

Documentation should be broken into the following sections:

* Summary
	* Summarize what has been done so far. Specify which tasks have been completed so far.
* Sample Runs
	* Sample runs should **all** come from the most recent implementation. Sample runs which were done to test previous tasks should be **done again** with the new implementation.
	* Sample runs should be organized by task; there should be sample runs showing that everything in task 1 still works in the up-to-date implementation, and so on up through the most recent task.
* Known Bugs
	* If anything is not functioning to specification, you are responsible enough for testing enough to recognize that this is the case and **fix it**. If you give up on fixing something, you are required to list it here.
	* Bugs which are discovered by the grader but not listed here will be graded **harshly**. Bugs which are listed here will be graded **nicely**.
	* Known bugs should also be organized by task, and should be well-described.
	* Lazy bug descriptions which don't go into detail about what is going wrong ("\<functionality\> doesn't work", "\<feature\> throws an error") will be graded as if the bug was not listed here.
	* This includes bugs that were created in functionality from prior tasks. If your task 5 breaks your task 3, we will check your task 3 submission if the bug is noted here, but if it is not noted here then we will assume that task 3 never worked and grade accordingly.

Doctored sample runs or otherwise intentionally misleading documentation will be considered **cheating** and will result in an automatic 0 for the whole project. Let us be clear: the grader will run the tests in your sample runs (in addition to many other tests), and if they don't work as they appear to in your documentation then you will fail.

Tasks **must** be completed sequentially. If you implement tasks 1, 2, 4 and 5, you will only receive points for tasks 1 and 2 because 3 was never done.


##<a name="tasks"></a> Tasks

Task 1 includes figures demonstrating how the syntax tree will be built for the initial grammar. You are encouraged to create similar visualizations of productions added in future tasks.

Task 1 is also **much** more detailed in its description of how to go about organizing the project. This is to give you a feel for we want to organize the project for ease of expansion. While this level of direction will not be given in the subsequent tasks, you should aim to keep everything as comparmentalized, clean, and easy to build on as task 1 is. 

It is a good idea to sweep each task 2-3 times after completion making it cleaner, replacing repeated code with function calls, and generally simplifying wherever possible. This will save you time in the long run, as simpler, more organized code is drastically easier to build on.

Every task will expand the grammar; your job is to expand the scanner, parser, data structures, parsing methods, and evaluation methods to meet the new requirements.

[TASK 1](./instructions/task_1.md) : Tokenization, Parsing and Evaluation of arithmetics in Cambridge Polish Notation

[TASK 2](./instructions/task_2.md) : Symbol definition and evaluation.

[TASK 3](./instructions/task_3.md) : Typecasting

TASK 4 : Conditionals, comparisons, read, random and print

TASK 5 : Composable, recursion-capable user-defined functions

## Point Breakdown

* Documentation : 25 points
* Task 1 : 15 points
* Task 2 : 20 points
* Task 3 : 5 points
* Task 4 : 15 points
* Task 5 : 20 points
