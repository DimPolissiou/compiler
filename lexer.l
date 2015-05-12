%option nounput
%option noinput
%option noyywrap
%{
/***************************************************************************
  Course    : Compilers - Assignment 1 - Lexer
  Authors   : Γαλανόπουλος Δημήτρης (dimgal9@gmail.com)
			  Πολυσίου Δημήτριος (dimpolissiou@gmail.com)
  Date      : March 29, 2015
  Note      : Written for the Tony language, using flex and gcc
  -----------
  School of ECE, National Technical University of Athens.
****************************************************************************/

#include "parser.tab.h"

#include <string.h>

char *strdup(const char *s);
int fileno(FILE *stream);
void yyerror(const char msg[]);
char escseqfun(char *s);
int lineno = 1;

char yycopy[1000];
int copylen;

int nested_comments;
%}

L	[A-Za-z]
D	[0-9]
HEX	{D}|[a-fA-F]
W	[ \t\r\f]
T1	[\+\-\*#=<>/]
T21	"<>"
T22	"<="
T23	">="
S1	[()\[\],;:]
S2	":="
ES	(\\.)|("\\x"{HEX}{HEX})

%x STRING
%x COMMENTS


%%


"and"		{ return T_and; }
"bool"		{ return T_bool; }
"char"		{ return T_char; }
"decl"		{ return T_decl; }
"def"		{ return T_def; }
"else"		{ return T_else; }
"elsif"		{ return T_elsif; }
"end"		{ return T_end; }
"exit"		{ return T_exit; }
"false"		{ return T_false; }
"for"		{ return T_for; }
"head"		{ return T_head; }
"if"		{ return T_if; }
"int"		{ return T_int; }
"list"		{ return T_list; }
"mod"		{ return T_mod; }
"new"		{ return T_new; }
"nil"		{ return T_nil; }
"nil?"		{ return T_nil_is; }
"not"		{ return T_not; }
"or"		{ return T_or; }
"ref"		{ return T_ref; }
"return"	{ return T_return; }
"skip"		{ return T_skip; }
"tail"		{ return T_tail; }
"true"		{ return T_true; }

\n						{ lineno++; }
{W}+					{ /* nothing */ }
{L}({L}|{D}|_|\?)*		{ yylval.n = (char *)malloc(strlen(yytext) +1);	strcpy(yylval.n, yytext); return T_id; }
{D}+					{ yylval.integer = atoi(yytext); return T_constint; }
{T1}					{ return yytext[0]; }
"<>"					{ return T_dif; }
"<="					{ return T_leq; }
">="					{ return T_geq; }
{S1}					{ return yytext[0]; }
":="					{ return T_assign; }

\'[^\'\"\\]\'			{
						  yytext[0] = yytext[1];
						  yytext[1] = '\0';
						  yylval.chr = yytext[0];
						  return T_constchar;
						}
\'{ES}\'				{
						  yytext[0] = escseqfun(yytext+2);
						  yytext[1] = '\0';
						  yylval.chr = yytext[0];
						  return T_constchar;
						}

						
\"						{ BEGIN(STRING); copylen = 0; }
<STRING>\"				{
						  BEGIN(INITIAL);
						  yycopy[copylen]='\0';
						  yytext=strdup(yycopy);
						  yylval.s = (char *)malloc(strlen(yytext) +1);
						  strcpy(yylval.s, yytext);
						  return T_conststring; 
						}
<STRING>{ES}			{ yycopy[copylen++] = escseqfun(yytext+1); }
<STRING>\n				{ yyerror("strings must extend to only one line\n"); }
<STRING><<EOF>>			{ yyerror("unterminated string\n"); }
<STRING>[^\\\"\n]+		{ strcpy(yycopy+copylen,yytext); copylen = copylen + yyleng; }

\%(.)*\n				{ lineno++; }

"<*"					{ BEGIN(COMMENTS); nested_comments = 0; }
<COMMENTS>\n			{ lineno++; }
<COMMENTS>"<*"			{ nested_comments++; }
<COMMENTS>"*>"			{ nested_comments--; if (nested_comments<0) BEGIN(INITIAL); }
<COMMENTS>\*			{ /* nothing */ }
<COMMENTS><				{ /* nothing */ }
<COMMENTS><<EOF>>		{ yyerror("unterminated comments\n"); }
<COMMENTS>[^\*\<\n]+	{ /* nothing */ }

.						{ yyerror("Illegal token.\n"); }


%%


void yyerror(const char msg[])
{
	fprintf(stderr,"ERROR, line %d: %s\n",lineno,msg);
	exit(1);
}

char escseqfun(char *s)
{
	char c;
	
	switch (s[0])
	{
		case 'n' :		return '\n';
		case 't' :		return '\t';
		case 'r' :		return '\r';
		case '0' :		return '\0';
		case '\\' :		return '\\';
		case '\'' :		return '\'';
		case '\"' :		return '\"';
		case 'x' :		
			if ((s[2]>='a')&&(s[2]<='f'))  c = s[2]-'a'+10;
			else if ((s[2]>='A')&&(s[2]<='F')) c = s[2]-'A'+10;
			else if ((s[2]>='0')&&(s[2]<='9')) c = s[2]-'0';
			else return 'x';
			if ((s[1]>='a')&&(s[1]<='f'))  c += (s[1]-'a'+10)*16;
			else if ((s[1]>='A')&&(s[1]<='F')) c += (s[1]-'A')*16;
			else if ((s[1]>='0')&&(s[1]<='9')) c += (s[1]-'0')*16;
			else return 'x';
			return c;
		default :		return s[0];
	}
}

