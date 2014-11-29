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
%token TOK_ORD TOK_CHR

%token TOK_BLOCK TOK_CALL TOK_IFELSE TOK_INITDECL
%token TOK_POS TOK_NEG TOK_NEWARRAY TOK_TYPEID TOK_FIELD

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

fielddecl   : basetype TOK_ARRAY TOK_IDENT  { $$ = adopt1($1, adopt1($2, adopt1sym($3, NULL, TOK_DECLID))); }
            | basetype TOK_DECLID { $$ = adopt1($1, adopt1sym($2, NULL, TOK_DECLID)); }
            ;

basetype    : TOK_VOID { $$ = $1; } 
            | TOK_BOOL { $$ = $1; }
            | TOK_CHAR { $$ = $1; }
            | TOK_INT { $$ = $1; }
            | TOK_STRING { $$ = $1; }
            | TOK_TYPEID {$$ = $1;}
            ;

function    : identdecl '(' identdecls ')' block
            | identdecl '(' ')' block
            ;

identdecls  : identdecls ',' identdecl
            | identdecl
            ;

identdecl   : basetype TOK_ARRAY TOK_DECLID
            | basetype TOK_DECLID
            ;

block       : '{' statements '}'
            | '{' '}'
            | ';'

statements  : statements statement
            | statement
            ;

statement   : block | vardecl | while | ifelse | return | expr ';'
            ;

vardecl     : identdecl '=' expr ';'
            ;

while       : TOK_WHILE '(' expr ')' statement
            ;

ifelse      : TOK_IF '(' expr ')' statement TOK_ELSE statement
            | TOK_IF '(' expr ')' statement
            ;

return      : TOK_RETURN expr ';'
            | TOK_RETURN ';'
            ;

expr        : expr '=' expr         { $$ = adopt2($2, $1, $3);} 
            | expr '+' expr         { $$ = adopt2($2, $1, $3);}
            | expr '-' expr         { $$ = adopt2($2, $1, $3);}
            | expr '*' expr         { $$ = adopt2($2, $1, $3);}
            | expr '/' expr         { $$ = adopt2($2, $1, $3);}
            | expr '%' expr         { $$ = adopt2($2, $1, $3);}
            | expr TOK_EQ expr      { $$ = adopt2($2, $1, $3);}
            | expr TOK_NE expr      { $$ = adopt2($2, $1, $3);}
            | call
            | expr  

call : TOK_IDENT '(' args ')'
;

args: args ',' expr
| expr
|
;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}

bool is_defined_token (int symbol) {
	return YYTRANSLATE (symbol) > YYUNDEFTOK;
}
