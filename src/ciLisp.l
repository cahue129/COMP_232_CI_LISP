%option noyywrap
%option nounput
%option noinput

%{
    #include "ciLisp.h"
    #define FLEX_BISON_LOG_PATH "../logs/flex_bison.log"
    #define llog(token) fprintf(flex_bison_log_file, "LEX: %s \"%s\"\n", #token, yytext);
%}

digit [0-9]
int [+-]?{digit}+
func "neg"|"abs"|"add"|"sub"|"mult"|"div"

%%

"quit" {
    return QUIT;
    }

{int} {
    llog(INT);
    yylval.dval = strtod(yytext, NULL);
    return INT;
    }


{func} {
    llog(FUNC);
    yylval.sval = (char *) malloc(strlen(yytext)*sizeof(char)+1);
    strcpy(yylval.sval, yytext);
    return FUNC;
    }

[\n] {
    llog(EOL);
    YY_FLUSH_BUFFER;
    return EOL;
    }

<<EOF>>  {
    llog(EOFT);
    return EOFT;
    }

[ \t] ; /* skip whitespace */


. { // anything else
    llog(INVALID);
    }

%%

/*
 * The code below should NOT be edited except to comment or uncomment
 * the "freopen" call in the main. When this call is commented, the fprintf
 * calls to stderr will appear in red in the console. When it is uncommented,
 * they will not appear in the console.
 */

#include <stdio.h>

int main(int argc, char **argv)
{
    int input_from_file = 0;
    flex_bison_log_file = stderr;

    // Comment the line below get inputs from the file specified in the program arguments
    // Otherwise they will need to be typed into the console
    freopen(argv[1], "r", stdin); input_from_file = 1;

    // Comment the line below to have flex and bison logging appear in stderr (red in the console)
    // Otherwise, this logging will appear in the logs folder.
    flex_bison_log_file = fopen(FLEX_BISON_LOG_PATH, "w");

    while(1) {
        if (!input_from_file)
            printf(">: ");
        if (yyparse()) {
            YY_FLUSH_BUFFER;
        }
    }
}
