%{
// Dummy parser for scanner project.
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "lyutils.h"
#include "astree.h"

%}



%debug
%defines
%error-verbose
%token-table

%token ROOT
%token TOK_VOID TOK_BOOL TOK_CHAR TOK_INT TOK_STRING
%token TOK_IF TOK_ELSE TOK_WHILE TOK_RETURN TOK_STRUCT
%token TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%token TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON
%token TOK_ORD TOK_CHR TOK_DECLID TOK_TYPEID 

%token TOK_BLOCK TOK_CALL TOK_IFELSE TOK_INITDECL
%token TOK_POS TOK_NEG TOK_NEWARRAY TOK_FIELD

%start program

%%

/* program : program token | ; */
/* token   : '(' | ')' | '[' | ']' | '{' | '}' | ';' | ',' | '.'
        | '=' | '+' | '-' | '*' | '/' | '%' | '!'
        | TOK_VOID | TOK_BOOL | TOK_CHAR | TOK_INT | TOK_STRING
        | TOK_IF | TOK_ELSE | TOK_WHILE | TOK_RETURN | TOK_STRUCT
        | TOK_FALSE | TOK_TRUE | TOK_NULL | TOK_NEW | TOK_ARRAY
        | TOK_EQ | TOK_NE | TOK_LT | TOK_LE | TOK_GT | TOK_GE
        | TOK_IDENT | TOK_INTCON | TOK_CHARCON | TOK_STRINGCON
        | TOK_ORD | TOK_CHR
        ;
*/ 

program     : ROOT program
            | program structdef
            | program function
            | program statement
            |
            ;


structdef   : TOK_STRUCT TOK_IDENT '{' fielddecls '}' { $$ = adopt1($1, adopt1sym($2, $4, TOK_TYPEID)); }
            ;

fielddecls  : fielddecls fielddecl ';' { $$ = adopt1($$, $2); }
            |
            ;

fielddecl   : basetype TOK_ARRAY TOK_IDENT  { $3->symbol = TOK_DECLID; $$ = adopt1($1, adopt1($2, $3)); }
            | basetype TOK_IDENT { $2->symbol = TOK_DECLID; $$ = adopt1($1, $2); }
            ;

basetype    : TOK_VOID { $$ = $1; } 
            | TOK_BOOL { $$ = $1; }
            | TOK_CHAR { $$ = $1; }
            | TOK_INT { $$ = $1; }
            | TOK_STRING { $$ = $1; }
            | TOK_TYPEID { $$ = $1; }
            ;

function    : identdecl '(' identdecls ')' block { $$ = adopt2($1, $3, $5); }
            | identdecl '(' ')' block { $$ = adopt1($1, $4); }
            ;

identdecls  : identdecls ',' identdecl { $$ = adopt1($1, $3); }
            | identdecl { $$ = $1; }
            ;

identdecl   : basetype TOK_ARRAY TOK_IDENT { $3->symbol = TOK_DECLID; $$ = adopt2($1, $2, $3); }
            | basetype TOK_IDENT { $2->symbol = TOK_DECLID; adopt1($1, $2); } 
            ;

block       : '{' statements '}' { $$ = $2; }
            | '{' '}' 
            | ';'

statements  : statements statement { $$ = adopt1($1, $2); }
            | statement { $$ = $1; }
            ;

statement   : block { $$ = $1; }
| vardecl { $$ = $1; }
| while { $$ = $1; }
| ifelse { $$ = $1; }
| return { $$ = $1; }
| expr ';' { $$ = $1; }
;

vardecl     : identdecl '=' expr ';' { $$ = adopt1($1, $3); }
            ;

while       : TOK_WHILE '(' expr ')' statement { $$ = adopt2($1, $3, $5); }
            ;

ifelse      : TOK_IF '(' expr ')' statement TOK_ELSE statement { $$ = adopt2($1, $3, $5); $$ = adopt1($1, $6); $$ = adopt1($6, $7); }
            | TOK_IF '(' expr ')' statement { $$ = adopt2($1, $3, $5); }
            ;

return      : TOK_RETURN expr ';' { $$ = adopt1($1, $2); }
            | TOK_RETURN ';'{ $$ = $1; }
            ;

expr        : expr '=' expr         { $$ = adopt2($2, $1, $3);} 
            | expr '+' expr         { $$ = adopt2($2, $1, $3);}
            | expr '-' expr         { $$ = adopt2($2, $1, $3);}
            | expr '*' expr         { $$ = adopt2($2, $1, $3);}
            | expr '/' expr         { $$ = adopt2($2, $1, $3);}
            | expr '%' expr         { $$ = adopt2($2, $1, $3);}
            | expr TOK_EQ expr      { $$ = adopt2($2, $1, $3);}
            | expr TOK_NE expr      { $$ = adopt2($2, $1, $3);}
            | call { $$ = $1; }
            /*| expr { $$ = $1; }*/
            | constant { $$ = $1;}
            ;

call : TOK_IDENT '(' args ')' { $$ = adopt1($1, $3); }
| TOK_IDENT '(' ')' { $$ = $1; }
;

args: args ',' expr { $$ = adopt1($1, $3); }
| expr { $$ = $1; }
;

constant : TOK_INTCON { $$ = $1; }
| TOK_STRINGCON { $$ = $1; }
| TOK_CHARCON { $$ = $1; }
| TOK_FALSE { $$ = $1; }
| TOK_TRUE { $$ = $1; }
| TOK_NULL { $$ = $1; }
;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}

bool is_defined_token (int symbol) {
	return YYTRANSLATE (symbol) > YYUNDEFTOK;
}
