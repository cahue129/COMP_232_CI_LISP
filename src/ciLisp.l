%option noyywrap
%option nounput
%option noinput

%{
    #include "ciLisp.h"
%}

digit [0-9]
int [+-]?{digit}+
func "neg"|"abs"|"add"|"sub"|"mult"|"div"

%%

"quit" {
    return QUIT;
    }

{int} {
    yylval.dval = strtod(yytext, NULL);
    fprintf(stderr, "lex: INT dval = %lf\n", yylval.dval);
    return INT;
    }


{func} {
    yylval.sval = (char *) malloc(strlen(yytext)*sizeof(char)+1);
    strcpy(yylval.sval, yytext);
    fprintf(stderr, "lex: FUNC sval = %s\n", yylval.sval);
    return FUNC;
    }

[\n] {
    fprintf(stderr, "lex: EOL\n");
    YY_FLUSH_BUFFER;
    return EOL;
    }
    
<<EOF>>  {
    fprintf(stderr, "lex: EOF\n");
    return EOFT;
    }

[ \t] ; /* skip whitespace */


. { // anything else
    printf("ERROR: invalid character: >>%s<<\n", yytext);
    }

%%

/*
 * The code below should NOT be edited except to comment or uncomment
 * the "freopen" call in the main. When this call is commented, the fprintf
 * calls to stderr will appear in red in the console. When it is uncommented,
 * they will not appear in the console.
 */

#include <stdio.h>

int main(void) 
{
    //Uncomment to remove logging.
    freopen("/dev/null", "w", stderr);

    while(1) {
        printf(">: ");
        if (yyparse()) {
            YY_FLUSH_BUFFER;
        }
    }
}
