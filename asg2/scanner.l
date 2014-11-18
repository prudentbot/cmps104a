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

TOK_VOID		(void)
TOK_BOOL		(bool)
TOK_CHAR		(char)
TOK_INT			(int)
TOK_STRING		(string)
TOK_STRUCT		(struct)
TOK_IF			(if)
TOK_ELSE		(else)
TOK_WHILE		(while)
TOK_RETURN		(return)
TOK_FALSE		(false)
TOK_TRUE		(true)
TOK_NULL		(null)
TOK_ORD			(ord)
TOK_CHR  		(chr)
TOK_NEW			(new)

TOK_ARRAY		("[]")
TOK_EQ			(==)
TOK_NE			(!=)
TOK_LE			(<=)
TOK_GE			(>=)
TOK_LT			(<)
TOK_GT			(>)

LETTER          [A-Za-z_]
DIGIT           [0-9]
TOK_INTCON      ({DIGIT}+)
NOTNUMBER       ({DIGIT}+[Ee][+-]?)

TOK_IDENT       ({LETTER}({LETTER}|{DIGIT})*)
NOTIDENT		({DIGIT}+{TOK_IDENT})
TOK_CHARCON		('([^\\'\n]|\\[\\'"0nt])')
TOK_STRINGCON	(\"([^\\"\n]|\\[\\'"0nt])*\")

%%

"#".*           { scanner_include(); }
[ \t]+          { IGNORE (white space) }
\n              { scanner_newline(); }

{TOK_VOID}          { return yylval_token (TOK_VOID); }
{TOK_BOOL}          { return yylval_token (TOK_BOOL); }
{TOK_CHAR}          { return yylval_token (TOK_CHAR); }
{TOK_INT}           { return yylval_token (TOK_INT); }
{TOK_STRING}        { return yylval_token (TOK_STRING); }
{TOK_IF}            { return yylval_token (TOK_IF); }
{TOK_ELSE}          { return yylval_token (TOK_ELSE); }
{TOK_WHILE}         { return yylval_token (TOK_WHILE); }
{TOK_RETURN}        { return yylval_token (TOK_RETURN); }
{TOK_STRUCT}        { return yylval_token (TOK_STRUCT); }
{TOK_FALSE}         { return yylval_token (TOK_FALSE); }
{TOK_TRUE}          { return yylval_token (TOK_TRUE); }
{TOK_NULL}          { return yylval_token (TOK_NULL); }
{TOK_NEW}           { return yylval_token (TOK_NEW); }

{TOK_IDENT}         { return yylval_token (TOK_IDENT); }
{TOK_INTCON}        { return yylval_token (TOK_INTCON); }
{TOK_CHARCON}       { return yylval_token (TOK_CHARCON); }
{TOK_STRINGCON}     { return yylval_token (TOK_STRINGCON); }

{TOK_ARRAY}         { return yylval_token (TOK_ARRAY); }

{TOK_EQ}        { return yylval_token (TOK_EQ); }
{TOK_NE}        { return yylval_token (TOK_NE); }
{TOK_LE}        { return yylval_token (TOK_LE); }
{TOK_GE}        { return yylval_token (TOK_GE); }
{TOK_GT}		{ return yylval_token (TOK_LT); }
{TOK_LT}		{ return yylval_token (TOK_GT); }
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


{NOTNUMBER}     { scanner_badtoken (yytext);
                  return yylval_token (TOK_INTCON); }
{NOTIDENT}		{ scanner_badtoken (yytext);
				  return yylval_token (TOK_IDENT); }

.               { scanner_badchar (*yytext); }

%%

