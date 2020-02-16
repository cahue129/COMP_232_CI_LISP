%{
    #include "ciLisp.h"
%}

%union {
    double dval;
    char *sval;
    struct ast_node *astNode;
};

%token <sval> FUNC
%token <dval> INT DOUBLE
%token LPAREN RPAREN EOL QUIT

%type <astNode> s_expr f_expr number s_expr_list

%%

program:
    s_expr EOL {
        fprintf(stderr, "yacc: program ::= s_expr EOL\n");
        if ($1) {
            printRetVal(eval($1));
            freeNode($1);
        }
    };

s_expr:
    number {
        fprintf(stderr, "yacc: s_expr ::= number\n");
        $$ = $1;
    }
    | f_expr {
        
    }
    | QUIT {
        fprintf(stderr, "yacc: s_expr ::= QUIT\n");
        exit(EXIT_SUCCESS);
    }
    | error {
        fprintf(stderr, "yacc: s_expr ::= error\n");
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
        fprintf(stderr, "yacc: s_expr_list ::= s_expr\n");
        $$ = $1;
    };
%%

