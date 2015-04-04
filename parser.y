%{
#include <string.h>
#include <stdio.h>

extern FILE *yyin;

void yyerror(const char msg[]);
int yylex();
%}

%union
{	
	/* Name */
	int					ival;
	char				*str;
	int					bool;
	char				chr;
	/* Symbol */
}

%token T_eof
%token T_id "id"
%token T_constint "int-const"
%token T_constchar "char-const"
%token T_constbool "bool-const"
%token T_conststring "string-literal"
%token T_dif "<>"
%token T_leq "<="
%token T_geq ">="
%token T_assign ":="
%token T_and "and"
%token T_bool "bool"
%token T_char "char"
%token T_decl "decl"
%token T_def "def"
%token T_else "else"
%token T_elsif "elsif"
%token T_end "end"
%token T_exit "exit"
%token T_false "false"
%token T_for "for"
%token T_head "head"
%token T_if "if"
%token T_int "int"
%token T_list "list"
%token T_mod "mod"
%token T_new "new"
%token T_nil "nil"
%token T_nil_is "nil?"
%token T_or "or"
%token T_ref "ref"
%token T_return "return"
%token T_skip "skip"
%token T_tail "tail"
%token T_true "true"

%type <ival> T_constint
%type <str> T_conststring T_id
%type <bool> T_constbool
%type <chr> T_constchar

%left "or"
%left "and"
%token T_not "not"
%nonassoc '=' '<' '>' "<>" "<=" ">="
%right '#'
%left '+' '-'
%left '*' '/' "mod"
%left SIGN

%%

Program		: func_def { } ;
		
func_def	: "def" header ':' def_list  stmt_list "end" { } ;

header		: "id" '(' formal_list ')' {}
			| type "id" '(' formal_list ')' {}
			| "id" '(' ')' {}
			| type "id" '(' ')' {}
			;

formal_list	: formal { }
			| formal ';' formal_list {}
			;
			
formal		: type id_list {}
			| "ref" type id_list {}
			;
			
id_list		: "id" {}
			| "id" ',' id_list {}
			;
			
type		: "int" {}
			| "bool" {}
			| "char" {}
			| type '[' ']' {}
			| "list" '[' type ']' {}
			;
			
func_decl	: "decl" header {} ;
			
def_list	: /* empty */
			| func_def def_list { }
			| func_decl def_list { }
			| var_def def_list { }
			;
			
var_def		: type id_list {} ;

stmt		: simple {}
			| "exit" {}
			| "return" expr {}
			| "if" expr ':' stmt_list "end" {}
			| "if" expr ':' stmt_list elsif_stmt "end" {}
			| "if" expr ':' stmt_list "else" ':' stmt_list "end" {}
			| "if" expr ':' stmt_list elsif_stmt "else" ':' stmt_list "end" {}
			| "for" simple_list ';' expr ';' simple_list ':' stmt_list "end" {}
			;
			
elsif_stmt	: "elsif" expr ':' stmt_list {}
			| elsif_stmt "elsif" expr ':' stmt_list {}
			;

stmt_list	: stmt { }
			| stmt stmt_list { }
			; 
			
simple		: "skip" {}
			| atom ":=" expr {}
			| call {}
			;
			
simple_list	: simple {}
			| simple ',' simple_list {}
			;

call		: "id" '(' ')' {} 
			| "id" '(' expr_list ')' {} 
			;
			
atom		: "id" {}
			| "string-literal" {}
			| atom '[' expr ']' {}
			| call
			;

expr		: atom {}
			| "int-const" {}
			| "char-const" {}
			| '(' expr ')' {}
			| '+' expr %prec SIGN {}
			| '-' expr %prec SIGN {}
			| expr '+' expr {}
			| expr '-' expr {}
			| expr '*' expr {}
			| expr '/' expr {}
			| expr "mod" expr {}
			| expr '=' expr {}
			| expr "<>" expr {}
			| expr '<' expr {}
			| expr '>' expr {}
			| expr "<=" expr {}
			| expr ">=" expr {}
			| "true" {}
			| "false" {}
			| "not" expr {}
			| expr "and" expr {}
			| expr "or" expr {}
			| "new" type '[' expr ']' {}
			| "nil" {}
			| "nil?" '(' expr ')' {}
			| expr '#' expr {}
			| "head" '(' expr ')' {}
			| "tail" '(' expr ')' {}
			;

expr_list	: expr {}
			| expr ',' expr_list {}
			;

%%

int main(int argc , char **argv)
{
	yyin = fopen(argv[1],"r");
	printf("\n");
	if ( yyparse()==0 )
	{
		printf("Great success!\n");
		return 0;
	}
	printf("Reached unreachable point.\n");
	return 1;
}

