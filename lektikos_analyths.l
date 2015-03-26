%{
#define yywrap() 1

#define T_eof			300
#define T_id			301
#define T_constint		302
#define T_constchar		303
#define T_constbool		304
#define T_conststring	305
#define T_and			305
#define T_bool			306
#define T_char			307
#define T_decl			308
#define T_def			309
#define T_else			310
#define T_elsif			311
#define T_end			312
#define T_exit			313
#define T_false			314
#define T_for			315
#define T_head			316
#define T_if			317
#define T_int			318
#define T_list			319
#define T_mod			320
#define T_new			321
#define T_nil			322
#define T_nil_is		323
#define T_not			324
#define T_or			325
#define T_ref			326
#define T_return		327
#define T_skip			328
#define T_tail			329
#define T_true			330

#include <string.h>

void yyerror(const char msg[]);
int lineno = 1;
char yycopy[1000];
int copylen;
%}

L	[A-Za-z]
D	[0-9]
HEX	{D}|[abcdef]
W	[ \t]
T1	[\+\-\*#=<>/]
T2	"<>"|"<="|">="
S1 	[()\[\],;:]
S2 	":="
ES 	"\\n"|"\\t"|"\\r"|"\\0"|"\\"|"\\\'"|"\\\""|("\\x"{HEX}{HEX})

%x STRING


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
\'(.|{ES})\'			{
						  strcpy(yycopy,yytext+1); 		//afairw ta ''
						  yycopy[strlen(yycopy)-1] = '\0'; 
						  strcpy(yytext,yycopy);		//ginetai strcpy giati |yycopy| < |yytext|
						  return T_constchar;
						}
						
\"						{ BEGIN(STRING); copylen = 0; }
<STRING>\"				{
						  BEGIN(INITIAL);
						  yycopy[copylen]='\0';
						  yytext=strdup(yycopy);	//thelei strdup giati sto telos |yytext|=1
						  return T_conststring; 
						}
<STRING>{
	"\\."				{ yycopy[copylen++] = foo(yytext[1]; }

	"\\n"				{ yycopy[copylen++]='\n'; }
	"\\t"				{ yycopy[copylen++]='\t'; }
	"\\r"				{ yycopy[copylen++]='\r'; }
	"\\0"				{ yycopy[copylen++]='\0'; }
	"\\"				{ yycopy[copylen++]='\\'; }
	"\\\'"				{ yycopy[copylen++]='\''; }
	"\\\""				{ yycopy[copylen++]='\"'; }
	("\\x"{HEX}{HEX})	{ yycopy[copylen++]='\'; }
}
<STRING>\n				{ yyerror("strings must extend to only one line\n"); }
<STRING><<EOF>>			{ yyerror("unterminated string\n"); }
<STRING>[^\\\"\n]+		{ strcpy(yycopy+copylen,yytext); copylen = copylen + yyleng; }

.						{ /*yyerror("Illegal token.\n");*/ }


%%


void yyerror(const char msg[])
{
	fprintf(stderr,"ERROR, line %d: %s\n",lineno,msg);
	exit(1);
}


int main(int argc , char **argv)
{
	int token;
	
	yyin = fopen(argv[1],"r");
	printf("\n\n");
	while((token=yylex()) != 0)
	{
		printf("token: %d  ,  lexeme: %s\n",token,yytext);
	}
	printf("\n\n");
	
	return 0;
}
