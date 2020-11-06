%{
    void yyerror(char *s)

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "writefile.h"

    int symbols[100];
    char temp[10];
    char lineW[100];
    int idx = 0;
    int line = 0;

    struct tac{
        char result[20];
        char operator[5];
        char operand_1[20];
        char operand_2[20];
    }

    struct threeADD quadraple[20];

    void yyerror (char *s);

    int symbolVal(char symbol);
    void updateSymbolVal(char symbol, int val);
    int addToTable(char operand, char operator1, char operator2);
    void generateCode();
%}

%code requires {
	struct incod
	{
		char codeVariable[10];
		int val;
	};
}

%union {int num; char id; int cond; struct incod code;}         /* Yacc definitions */
%start line

%token print
%token <num> num
%token <id> id
%token <num> true_
%token <num> false_

%token less
%token greater
%token equal
%token lessequal
%token greaterequal
%token notequal
%token if_
%token else_
%token while_

%type <num> line 
%type <code> exp term ending_term condition
%type <id> assignment

%left '+' '-'
%left '*' '/' '%'

%%
    /* Add Code Here */
%%

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

/* returns the value of a given symbol */

int symbolVal(char symbol)
{
	int bucket = getSymbolIdx(symbol);
	return symbols[bucket];
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
	int bucket = getSymbolIdx(symbol);
	symbols[bucket] = val;
}
void generateCode()
{
	int count = 0;
	char buffer[50];

	while(count < ind)
	{
		
		if (strcmp(quadraple[count].result, "")==0)
		{
			sprintf(buffer, "%s %s", quadraple[count].operator, quadraple[count].operand_1);
			writeLine(buffer);
			count++;
			continue;
		}
		sprintf(buffer, "%s := %s %s %s", quadraple[count].result, quadraple[count].operand_1,
			quadraple[count].operator, quadraple[count].operand_2);
		writeLine(buffer);
		count++;
	}
}

int main (void)
{
	yyparse();
	generateCode();
}

void yyerror (char *s) {fprintf (stderr, "%s at line %d\n", s, line);}