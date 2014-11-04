%{
	
#include "auxlib.h"
#include "lyutils.h"

#define YY_USER_ACTION  { scanner_useraction (); }
#define IGNORE(THING)   { }

%}

%option 8bit
%option debug
%option nodefault
%option nounput
%option noyywrap
%option verbose
%option warn

LETTER          [A-Za-z_]
DIGIT           [0-9]
NUMBER          ({DIGIT}+)
NOTNUMBER       ({DIGIT}+[Ee][+-]?)
IDENT           ({LETTER}({LETTER}|{DIGIT})*)
NOTIDENT		({DIGIT}+{IDENT})
CHAR			('([^\\'\n]|\\[\\'"0nt])')
STRING			(\"([^\\"\n]|\\[\\'"0nt])*\")
DBRKT			"[]"
DEQ				"=="
NEQ				"!="
LEQ				"<="
GEQ				">="


%%

"#".*           { scanner_include(); }
[ \t]+          { IGNORE (white space) }
\n              { scanner_newline(); }

{NUMBER}        { return yylval_token (NUMBER); }
{IDENT}         { return yylval_token (IDENT); }
{CHAR}			{ return yylval_token (1); }
{STRING}		{ return yylval_token (STRING); }
{DBRKT}			{ return yylval_token (DBRKT); }
{DEQ}			{ return yylval_token (DEQ); }
{NEQ}			{ return yylval_token (NEQ); }
{LEQ}			{ return yylval_token (LEQ); }
{GEQ}			{ return yylval_token (GEQ); }


"="             { return yylval_token ('='); }
"+"             { return yylval_token ('+'); }
"-"             { return yylval_token ('-'); }
"*"             { return yylval_token ('*'); }
"/"             { return yylval_token ('/'); }
"("             { return yylval_token ('('); }
")"             { return yylval_token (')'); }
";"             { return yylval_token (';'); }
"%"				{ return yylval_token ('%'); }
"!"				{ return yylval_token ('!'); }
"."				{ return yylval_token ('.'); }
","				{ return yylval_token (','); }
"{"				{ return yylval_token ('{'); }
"}"				{ return yylval_token ('}'); }
"["				{ return yylval_token ('['); }
"]"				{ return yylval_token (']'); }
"<"				{ return yylval_token ('<'); }
">"				{ return yylval_token ('>'); }


{NOTNUMBER}     { scanner_badtoken (yytext);
                  return yylval_token (NUMBER); }

.               { scanner_badchar (*yytext); }

%%

