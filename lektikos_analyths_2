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

#define T_eof			300
#define T_id			301
#define T_constint		302
#define T_constchar		303
#define T_constbool		304
#define T_conststring	305
#define T_dif			306
#define T_leq			307
#define T_geq			308
#define T_assign		309
#define T_and			400
#define T_bool			401
#define T_char			402
#define T_decl			403
#define T_def			404
#define T_else			405
#define T_elsif			406
#define T_end			407
#define T_exit			408
#define T_false			409
#define T_for			410
#define T_head			411
#define T_if			412
#define T_int			413
#define T_list			414
#define T_mod			415
#define T_new			416
#define T_nil			417
#define T_nil_is		418
#define T_not			419
#define T_or			420
#define T_ref			421
#define T_return		422
#define T_skip			423
#define T_tail			424
#define T_true			425

#include <string.h>

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
{L}({L}|{D}|_|\?)*		{ return T_id; }
{D}+					{ return T_constint; }
{T1}					{ return yytext[0]; }
"<>"					{ return T_dif; }
"<="					{ return T_leq; }
">="					{ return T_geq; }
{S1}					{ return yytext[0]; }
":="					{ return T_assign; }

\'[^\'\"\\]\'			{
						  yytext[0] = yytext[1];
						  yytext[1] = '\0';
						  return T_constchar;
						}
\'{ES}\'				{			//yytext[0] == "\'"
						  yytext[0] = escseqfun(yytext+2);
						  yytext[1] = '\0';
						  return T_constchar;
						}

						
\"						{ BEGIN(STRING); copylen = 0; }
<STRING>\"				{
						  BEGIN(INITIAL);
						  yycopy[copylen]='\0';
						  yytext=strdup(yycopy);	//thelei strdup giati sto telos |yytext|=1 < |yycopy|
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

int main(int argc , char **argv)
{
	int token;
	
	yyin = fopen(argv[1],"r");
	printf("\n\n");
	while((token=yylex()) != 0)
	{
		printf("token: %3d  ,  lexeme: %s\n",token,yytext);
	}
	printf("\n\n");
	
	return 0;
}

