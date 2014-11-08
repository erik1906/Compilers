%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

struct info {
        char type[100];
        struct info* firstChild;
        struct info* nextSibling;
};

#define YYSTYPE struct info*

void yyerror (char const *s);

void Init_PD2(struct info** x, char* y);
void PrintTree (struct info* x);
void Print (struct info* x, int l);
void PrintTree2 (struct info* x);

%}

%token CLASS PROGRAM
%token IF FOR ID VOID INT BOOL CALLOUT BREAK CONTINUE ELSE RETURN
%token bool_literal char_literal string_literal int_literal
%token COMMA SEMCOL
%token PLUS MINUS MUL DIV MOD
%token LT GT LE GE NE EQ
%token ASS PASS MASS
%token AND OR NOT
%token OP CP OB CB OS CS

%nonassoc NE EQ
%nonassoc LT GT GE LE
%right UMINUS


%%

program	: CLASS PROGRAM	OB feild_methods CB {	Init_PD2 (&$$, "program");
                                                $$->firstChild = $4;
                                                PrintTree2($$);
                                            }
    ;

feild_methods    :   feild_methods  feild_method    {   Init_PD2(&$$, "feild_methods");
                                                        if($1){
                                                            $$->firstChild = $1;
                                                            $1->nextSibling = $2;
                                                        }
                                                        else
                                                            $$->firstChild = $2;
                                                    }
    |       {   $$ = NULL; }
    ;

feild_method    :   type ID OP args CP block {   Init_PD2(&$$, "method_decl");
                                $$->firstChild = $2;
                                if($4) {
                                    $2->nextSibling = $4;
                                    $4->nextSibling = $6;
                                }
                                else
                                    $2->nextSibling = $6;
                            }
    |   VOID ID OP args CP block    {   Init_PD2(&$$, "method_decl");
                                        $$->firstChild = $2;
                                        if($4) {
                                            $2->nextSibling = $4;
                                            $4->nextSibling = $6;
                                        }
                                        else
                                            $2->nextSibling = $6;
                                    }
    |   type ID OS int_literal CS ARR_IDS SEMCOL {   Init_PD2(&$$, "feild_decl");
                                            $$->firstChild = $1;
                                            $1->nextSibling = $2;
                                            $2->nextSibling = $4;
                                            $4->nextSibling = $6;
                                        }
    |   type ID ARR_IDS SEMCOL  {   Init_PD2(&$$, "feild_decl");
                                    $$->firstChild = $1;
                                    $1->nextSibling = $2;
                                    $2->nextSibling = $3;
                                }
    |   type ID ASS literal SEMCOL  {   Init_PD2(&$$, "assign");
                                        $$->firstChild = $1;
                                        $1->nextSibling = $2;
                                        $2->nextSibling = $4;
                                    }
    ;

type    :   INT {   Init_PD2(&$$, "int");
                    $$->firstChild = $1;
                }
    |   BOOL    {   Init_PD2(&$$, "bool");
                    $$->firstChild = $1;
                }
    ;

ARR_IDS :   COMMA ARR_ID ARR_IDS    {   Init_PD2(&$$, "feild");
                                        $$->firstChild = $2;
                                        $2->nextSibling = $3;
                                    }
    |       {   $$ = NULL;
            }
    ;

ARR_ID  :   ID  {   $$ = $1;
                }
    |   ID OS int_literal CS    {   Init_PD2(&$$, "array");
                                    $$->firstChild = $1;
                                    $1->nextSibling = $3;
                                    PrintTree($$);
                                }
    ;

args    :   arg args1   {   Init_PD2(&$$, "args");
                            $$->firstChild = $1;
                            $1->nextSibling = $2;
                        }
    |       {   $$ = NULL;
            }
    ;

args1   :   COMMA arg args1 {   Init_PD2(&$$, "args");
                                $$->firstChild = $2;
                                $2->nextSibling = $3;
                            }
    |       {   $$ = NULL;
            }
    ;

arg :   BOOL ID {   Init_PD2(&$$, "bool");
                    $$->firstChild = $2;
                }
    |   INT ID  {   Init_PD2(&$$, "int");
                    $$->firstChild = $2;
                }
    ;

block   :   OB var_decls stmts CB   {   Init_PD2(&$$, "block");
                                        if($2){
                                            $$->firstChild = $2;
                                            $2->nextSibling = $3;
                                        }
                                        else
                                            $$->firstChild = $3;
                                    }
    ;

var_decls   :   var_decls var_decl  {   Init_PD2(&$$, "var_decls");
                                        if($1){
                                            $$->firstChild = $1;
                                            $1->nextSibling = $2;
                                        }
                                        else
                                            $$->firstChild = $2;
                                    }
    |       {   $$ = NULL;
            }
    ;

var_decl    :   arg vars SEMCOL {   Init_PD2(&$$, "var_decl");
                                    $$->firstChild = $1;
                                    $1->nextSibling = $2;
                                }
    ;

vars    :   COMMA var vars  {   Init_PD2(&$$, "var");
                                $$->firstChild = $2;
                                $2->nextSibling = $3;
                            }
    |       {   $$ = NULL;
            }
    ;

var :   ID  {   $$ = $1;
            }
    ;

stmts	:	stmts stmt	{	Init_PD2 (&$$, "stmts");
                            if ($1) {
                                $$->firstChild = $1;
                                $1->nextSibling = $2;
                            }
                            else
                                $$->firstChild = $2;
                            PrintTree($$);
                        }
    |			{	$$ = NULL;
                    PrintTree($$);
                }
    ;

stmt	:	block    {   $$ = $1; }
    |   expr_a SEMCOL	{	Init_PD2 (&$$, "eval");
                            $$->firstChild = $1;
                            PrintTree($$);
                        }
    |	IF OP expr_a CP block   {   Init_PD2 (&$$, "if");
                                    $$->firstChild = $3;
                                    $3->nextSibling = $5;
                                    PrintTree($$);
                                }
    |	IF OP expr_a CP block ELSE block  {   Init_PD2 (&$$, "if");
                                    $$->firstChild = $3;
                                    $3->nextSibling = $5;
                                    $5->nextSibling = $7;
                                    PrintTree($$);
                                }
    |   FOR fexpr COMMA expr_a block  {   Init_PD2(&$$, "for");
                                        $$->firstChild = $2;
                                        $2->nextSibling = $4;
                                        $4->nextSibling = $5;
                                        PrintTree($$);
                                    }
    |   RETURN Rexpr SEMCOL   {   Init_PD2(&$$, "return");
                            $$->firstChild = $1;
                            $1->nextSibling = $2;
                        }
    |   BREAK SEMCOL  {  $$ = $1;
                }
    |   CONTINUE SEMCOL  {   $$ = $1;
                }
    |   method_call SEMCOL  {   Init_PD2(&$$, "method_call");
                        $$->firstChild = $1;
    }
    ;

method_call :   CALLOUT OP string_literal CP   {   Init_PD2(&$$, "callout");
                                                    $$->firstChild = $3;
                                                    $3->nextSibling = $4;
        }
    ;

Rexpr   :   OP expr_a CP    {  $$ = $2;

                            }
    |       {   $$ = NULL;  }
    ;

fexpr   :   ID ASS expr_a { Init_PD2(&$$, "assign");
                            $$->firstChild = $1;
                            $1->nextSibling = $3;
                        }
    ;

expr_a    :   expr_or   {   $$ = $1;
                        }
    |   ID ASS expr_or  {   Init_PD2(&$$, "assign_op");
                            $$->firstChild = $1;
                            $1->nextSibling = $3;
                        }
    |   ID PASS expr_or {   Init_PD2(&$$, "plus_eq");
                            $$->firstChild = $1;
                            $1->nextSibling = $3;
                        }
    |   ID MASS expr_or {   Init_PD2(&$$, "minus_eq");
                            $$->firstChild = $1;
                            $1->nextSibling = $3;
                        }
    |   ID OP expr_rec CP   {   Init_PD2(&$$, "method_call");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    ;

expr_rec    :   expr_a  expr_rec2   {   Init_PD2(&$$, "args");
                                        $$->firstChild = $1;
                                        $1->nextSibling = $2;
                                    }
    |       {   $$ = NULL;  }
    ;

expr_rec2   :   COMMA expr_a expr_rec2  {   Init_PD2(&$$, "args");
                                            $$->firstChild = $2;
                                            $2->nextSibling = $3;
    }
    |       {   $$ = NULL;  }
    ;

expr_or :   expr_and    {   $$ = $1;
                        }
    |   expr_or OR expr_and {   Init_PD2(&$$, "cond_OR");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    ;

expr_and :   expr_eq    {   $$ = $1;
                        }
    |   expr_and AND expr_eq    {   Init_PD2(&$$, "cond_AND");
                                    $$->firstChild = $1;
                                    $1->nextSibling = $3;
                                }
    ;

expr_eq :   expr_rel    {   $$ = $1;
                        }
    |   expr_eq EQ expr_rel {   Init_PD2(&$$, "EQUAL");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_eq NE expr_rel {   Init_PD2(&$$, "NOT_EQUAL");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    ;

expr_rel :   expr_pm {   $$ = $1;
                    }
    |   expr_rel LT expr_pm {   Init_PD2(&$$, "LESS_THAN");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_rel GT expr_pm {   Init_PD2(&$$, "GREATER_THAN");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_rel LE expr_pm {   Init_PD2(&$$, "LESS_EQUAL");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_rel GE expr_pm {   Init_PD2(&$$, "GREATER_EQUAL");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    ;

expr_pm :   expr_mdm    {   $$ = $1;
                        }
    |   expr_pm PLUS expr_mdm   {   Init_PD2(&$$, "plus");
                                        $$->firstChild = $1;
                                        $1->nextSibling = $3;
                                    }
    |   expr_pm MINUS expr_mdm  {   Init_PD2(&$$, "minus");
                                    $$->firstChild = $1;
                                    $1->nextSibling = $3;
                                }
    ;

expr_mdm    :   factor  {   $$ = $1;
                        }
    |   expr_mdm MUL factor {   Init_PD2(&$$, "mul");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_mdm DIV factor {   Init_PD2(&$$, "div");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    |   expr_mdm MOD factor {   Init_PD2(&$$, "mod");
                                $$->firstChild = $1;
                                $1->nextSibling = $3;
                            }
    ;

factor  :	OP expr_a CP	{	$$ = $2;
                            }
    |	NOT factor %prec NOT    {	Init_PD2 (&$$, "cond_NOT");
                                    $$->firstChild = $2;
                                }
    |	MINUS factor %prec UMINUS   {	Init_PD2 (&$$, "NEG");
                                        $$->firstChild = $2;
                                    }
    |	literal		{	$$ = $1;
                    }
    |   ID OS expr_a CS {   Init_PD2(&$$, "array");
                            $$->firstChild = $1;
                            $1->nextSibling = $3;
                        }
    |	ID	{	$$ = $1;
            }
    ;

literal :   int_literal	{	$$ = $1;
                        }
    |   string_literal  {   $$ = $1;
                        }
    |   char_literal    {   $$ = $1;
                        }
    |   bool_literal    {   $$ = $1;
                        }
    ;
%%

#include "lex.yy.c"

//extern yydebug = 1;

void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
 }

void Init_PD2 (struct info** x, char* type) {
    *x = (struct info*) malloc (sizeof(struct info));
    strcpy((*x)->type, type);
    (*x)->firstChild = NULL;
    (*x)->nextSibling = NULL;
}//Init_PD2

void PrintTree2 (struct info* x) {
    printf("********************\n");
    Print (x, 0);
}

void PrintTree (struct info* x) {

}

void Print (struct info* x, int level) {
    if (x == NULL) return;

    int i = 0;
    if(x->type[0] != '\0'){
        for (i = 0; i < level; i ++) printf ("    ");
        printf("%s\n", x->type);
    }

    Print (x->firstChild, level + 1);

    Print (x->nextSibling, level);
}

int main(void)
{

        yyparse();
        return 0;
}
