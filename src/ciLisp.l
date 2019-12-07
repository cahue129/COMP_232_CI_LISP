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

{int} {
    yylval.dval = strtod(yytext, NULL);
    fprintf(stderr, "lex: INT dval = %lf\n", yylval.dval);
    return INT;
}

"quit" {
    return QUIT;
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

[ \t] ; /* skip whitespace */

. { // anything else
    printf("ERROR: invalid character: >>%s<<\n", yytext);
    }

%%

/*
 * The main below should NOT be edited except to comment or uncomment
 * the "freopen" call. When this call is commented, the fprintf calls
 * to stderr will appear in red in the console. When it is uncommented,
 * they will not appear in the console.
 */

int main(void) {

    freopen("/dev/null", "w", stderr);

    char *s_expr_buffer = NULL;
    char *s_expr_str = NULL;
    size_t s_expr_str_len = 0;
    YY_BUFFER_STATE buffer;

    while (true) {
        printf("\n> ");

        getline(&s_expr_buffer, &s_expr_str_len, stdin);

        s_expr_str = calloc(s_expr_str_len+2, sizeof(char));
        strcpy(s_expr_str, s_expr_buffer);
        s_expr_str[s_expr_str_len++] = '\0';
        s_expr_str[s_expr_str_len++] = '\0';
        
        buffer = yy_scan_buffer(s_expr_str, s_expr_str_len);
        yyparse();

        yy_delete_buffer(buffer);
        free(s_expr_str);
        free(s_expr_buffer);
        s_expr_buffer = NULL;
        s_expr_str = NULL;
        s_expr_str_len = 0;
        fflush(stdin);
    }
}
