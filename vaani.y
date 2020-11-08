%{
    void yyerror(char *s);
	int yylex();
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	#include <ctype.h>

    float symbols[52];
    char temp[10];
    char lineW[100];
    int idx = 0;
    int line = 0;

    struct tac{
        char result[20];
        char operator[5];
        char operand_1[20];
        char operand_2[20];
    };

    // struct threeADD quadraple[20];

    void yyerror (char *s);
	int getSymbolIdx(char token);
    float symbolVal(char symbol);
    void updateSymbolVal(char symbol, float val);
    float addToTable(char operand, char operator1, char operator2);
    void generateCode();
%}



%union {float num; char id; int cond; struct incod code;}         /* Yacc definitions */
%start line

%token print
%token exit_statement
%token <num> num
%token <id> id
%token <num> true_
%token <num> false_

%token less greater equal
%token lessequal greaterequal
%token notequal
%token if_
%token else_
%token while_

%type <num> line 
%type <num> expression 
%type <id> assignment 
%type <num> relation


%left '+' '-'
%left '*' '/' '%'

%%

    line		: assignment ';'			{;}
				| exit_statement ';'		{
												printf("Exiting program. Goodbye\n");
												exit(0);
											}
				| print expression ';'		{ printf("Printing %f\n", $2); }
				| line assignment ';'		{;}
				| line exit_statement ';'	{
												printf("Exiting program. Goodbye\n");	
												exit(0);
											}
				| print relation ';'        { print("Relation %d\n", $2);}							
				| line print expression ';'	{ printf("Printing %f\n", $3); }
				
				| line print relation ';'   { printf("Relation %d\n", $3.val);}
				;
	
	assignment	: id '=' expression			{ printf("[log] Assignment - %c=%f\n", $1, $3); updateSymbolVal($1, $3);}
				| id '=' relation			{ printf("[log] Assignment - %c=%f\n", $1, $3); updateSymbolVal($1, $3);}
				;
	expression	: num						{ printf("[log] ValueNum - %f=%f\n", $$, $1); $$ = $1; }
				| id 						{ printf("[log] ValueId - %c\n", $1); $$ = symbolVal($1);}
				| expression '+' expression { printf("[log] Addition - %f+%f\n", $1, $3); $$ = $1+$3;}
				| expression '-' expression { printf("[log] Subtraction -  %f-%f\n", $1, $3); $$ = $1-$3;}
				| expression '*' expression { printf("[log] Multiplication - %f*%f\n", $1, $3); $$ = $1*$3;}
				| expression '/' expression { printf("[log] Division - %f/%f\n", $1, $3); $$ = $1/$3;}
				| '(' expression ')' 		{ printf("[log] Paranthesis\n"); $$ = $2;}
				;
	relation    : expression less expression         { 	$$ = ($1<$3);
											         	printf("[log] %f<%f\n", $1,$3); 
											        }    
				| expression greater expression     { 	$$ = ($1>$3);
												      	printf("[log] %f>%f\n", $1,$3); 
												    }
				| expression equal expression       { 	$$ = ($1==$3);
				                                      	printf("[log] %f==%f\n", $1,$3); 
				                                    }
				| expression lessequal expression   {   $$ = ($1<=$3);
				                                    	printf("[log] %f<=%f\n", $1,$3); 
				                                    }  
				| expression greaterequal expression {  $$ = ($1>=$3);
				                                       	printf("[log] %f>=%f\n", $1,$3); 
				                                     } 
				| expression notequal expression 	{   $$ = ($1!=$3);
				                                    	printf("[log] %f!=%f\n", $1,$3); 
				                                     }
				| true_ {	$$ = 1;
							printf("[log] %f=1", $$); 

				        }
				| false_ {	$$ = 0;
							printf("[log] %f=0", $$);
				         }
				;

%%

/* returns the value of a given symbol */

float symbolVal(char symbol)
{
	int bucket = getSymbolIdx(symbol);
	return symbols[bucket];
}


int getSymbolIdx(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, float val)
{
	int bucket = getSymbolIdx(symbol);
	symbols[bucket] = val;
}

void generateCode()
{
	// int count = 0;
	// char buffer[50];

	// while(count < ind)
	// {
		
	// 	if (strcmp(quadraple[count].result, "")==0)
	// 	{
	// 		sprintf(buffer, "%s %s", quadraple[count].operator, quadraple[count].operand_1);
	// 		writeLine(buffer);
	// 		count++;
	// 		continue;
	// 	}
	// 	sprintf(buffer, "%s := %s %s %s", quadraple[count].result, quadraple[count].operand_1,
	// 		quadraple[count].operator, quadraple[count].operand_2);
	// 	writeLine(buffer);
	// 	count++;
	// }
}

int main (void)
{
	yyparse();
	// generateCode();
}

void yyerror (char *s) {fprintf (stderr, "%s at line %d\n", s, line);}