%{
    void yyerror(char *s);
	int yylex();
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	#include <ctype.h>

    float symbols[52];

    struct tac{
        char result[5];
        char operator[5];
        char operand1[50];
        char operand2[50];
    };
	struct tac quadruples[200];
	char lineBufferStack[100][50];
	int stackTop = -1;
	int idsUsed = -1;
	int quadruplesIdx = -1;

    // struct threeADD quadraple[20];

    void yyerror (char *s);
	int getSymbolIdx(char token);
    float symbolVal(char symbol);
    void updateSymbolVal(char symbol, float val);
    float addToTable(char operand, char operator1, char operator2);
    void generateCode();
	void operateOnStack(char* operator);
%}

%union {float num; char id;};       /* Yacc definitions */

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
%type <num> condition
%type <num> cond

%left '+' '-'
%left '*' '/' '%'

%%

    line		: assignment ';' lline			{	stackTop = -1;}
				| exit_statement ';' 	{
												printf("Exiting program. Goodbye\n");
												struct tac quadruple;
												sprintf(quadruple.result, "0");
												sprintf(quadruple.operator, "EXIT");
												quadruple.operand1[0]='\0';
												quadruple.operand2[0]='\0';
												quadruples[++quadruplesIdx] = quadruple;
												generateCode();
												exit(0);
											}
				| print printable ';' lline		{;}
				| loop lline				{;}
        		| condition lline 				{ ;}
				;

	lline		:  								{;}
				| assignment ';' lline			{	stackTop = -1;}
				| print printable ';' lline		{ ; }
				| loop lline				{ ; }
				| condition lline			{ ; }
				| exit_statement ';' 	{
												printf("Exiting program. Goodbye\n");
												struct tac quadruple;
												sprintf(quadruple.result, "0");
												sprintf(quadruple.operator, "EXIT");
												quadruple.operand1[0]='\0';
												quadruple.operand2[0]='\0';
												quadruples[++quadruplesIdx] = quadruple;
												generateCode();
												exit(0);
											}
				;
	
	printable	: relation      			{
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												stackTop = -1;
												printf("Printing relation -> %f\n", $1); 
											}
				| expression				{
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												stackTop = -1;
												printf("Printing %f\n", $1); 
											}
				;
	
	assignment	: id '=' expression			{
												updateSymbolVal($1, $3);
												if(lineBufferStack[stackTop][0] == 't'){
													stackTop--;
													sprintf(quadruples[quadruplesIdx].result, "%c", $1);
													idsUsed--;
												}
												else{
													struct tac quadruple;
													sprintf(quadruple.result, "%c", $1);
													quadruple.operator[0] = '\0';
													sprintf(quadruple.operand1, "%f", $3);
													quadruple.operand2[0] = '\0';
													quadruples[++quadruplesIdx] = quadruple;
												}
											}
				| id '=' relation			{
												updateSymbolVal($1, $3);
												if(lineBufferStack[stackTop][0] == 't'){
													stackTop--;
													sprintf(quadruples[quadruplesIdx].result, "%c", $1);
													idsUsed--;
												}
												else{
													struct tac quadruple;
													sprintf(quadruple.result, "%c", $1);
													quadruple.operator[0] = '\0';
													sprintf(quadruple.operand1, "%f", $3);
													quadruple.operand2[0] = '\0';
													quadruples[++quadruplesIdx] = quadruple;
												}
											}
				;
	expression	: num						{
												$$ = $1;
												sprintf(lineBufferStack[++stackTop], "%f", $1);
											}
				| id 						{
												$$ = symbolVal($1);
												sprintf(lineBufferStack[++stackTop], "%c", $1);
											}
				| expression '+' expression {
												$$ = $1+$3;
												operateOnStack("+");
											}
				| expression '-' expression {
												$$ = $1-$3;
												operateOnStack("-");
											}
				| expression '*' expression {
												$$ = $1*$3;
												operateOnStack("*");
											}
				| expression '/' expression { 
												$$ = $1/$3;
												operateOnStack("/");
											}
				| '(' expression ')' 		{$$ = $2;}
				;
	relation    : expression less expression        { 	$$ = ($1<$3);
														operateOnStack("<");
											        }    
				| expression greater expression     { 	$$ = ($1>$3);
												      	operateOnStack(">");
												    }
				| expression equal expression       { 	$$ = ($1==$3);
				                                      	operateOnStack("==");
				                                    }
				| expression lessequal expression   {   $$ = ($1<=$3);
				                                    	operateOnStack("<=");
				                                    }  
				| expression greaterequal expression {  $$ = ($1>=$3);
				                                       	operateOnStack(">=");
				                                     } 
				| expression notequal expression 	{   $$ = ($1!=$3);
				                                    	operateOnStack("!=");
				                                     }

				| true_ {	$$ = 1;
				        }
				| false_ {	$$ = 0;
				         }
				| '(' relation ')' {$$ = $2;}
				;

	cond		: relation 	{
								char op[5];
								sprintf(op, "%s", quadruples[quadruplesIdx].operator);
								sprintf(quadruples[quadruplesIdx].operator, "GO%s", op);
								stackTop = -1;
							}
				;

	loop		: while_ cond '{' line '}' {
										struct tac blockStack[200];
											int start;
											int i=0;
											for (;;i++, quadruplesIdx--){
												if(quadruples[quadruplesIdx].operator[0]=='G'&&quadruples[quadruplesIdx].operator[1]=='O') break;
												blockStack[i] = quadruples[quadruplesIdx];
											}
											sprintf(quadruples[quadruplesIdx].result, "%d", quadruplesIdx+3);
											start = quadruplesIdx;
											struct tac quadruple;
											quadruple.operand1[0] = '\0';
											quadruple.operand2[0] = '\0'; 
											sprintf(quadruple.operator, "GOTO");
											sprintf(quadruple.result, "%d", quadruplesIdx+i+4);
											quadruples[++quadruplesIdx] = quadruple;
											i--;
											while(i>=0){
												quadruples[++quadruplesIdx] = blockStack[i--];
											}
											struct tac quadruple2;
											quadruple2.operand1[0] = '\0';
											quadruple2.operand2[0] = '\0'; 
											sprintf(quadruple2.operator, "GOTO");
											sprintf(quadruple2.result, "%d", start+1);
											quadruples[++quadruplesIdx] = quadruple2;
										}; 
	
	condition	: if_ cond '{' line '}' {
											struct tac blockStack[200];
											int i=0;
											for (;;i++, quadruplesIdx--){
												if(quadruples[quadruplesIdx].operator[0]=='G'&&quadruples[quadruplesIdx].operator[1]=='O') break;
												blockStack[i] = quadruples[quadruplesIdx];
											}
											sprintf(quadruples[quadruplesIdx].result, "%d", quadruplesIdx+3);
											struct tac quadruple;
											quadruple.operand1[0] = '\0';
											quadruple.operand2[0] = '\0'; 
											sprintf(quadruple.operator, "GOTO");
											sprintf(quadruple.result, "%d", quadruplesIdx+i+3);
											quadruples[++quadruplesIdx] = quadruple;
											i--;
											while(i>=0){
												quadruples[++quadruplesIdx] = blockStack[i--];
											}
											if($2){ 
												$$ = $4;
											}
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

void operateOnStack(char* operator){
	char *operand1;
	char *operand2;
	struct tac quadruple;
	operand2 = lineBufferStack[stackTop--];
	operand1 = lineBufferStack[stackTop--];
	strcpy(quadruple.operand1, operand1);
	strcpy(quadruple.operand2, operand2);
	sprintf(quadruple.operator, "%s", operator);
	sprintf(quadruple.result, "t%d", ++idsUsed);
	sprintf(lineBufferStack[++stackTop], "t%d", idsUsed);
	quadruples[++quadruplesIdx] = quadruple;
}
/* updates the value of a given symbol */
void updateSymbolVal(char symbol, float val)
{
	int bucket = getSymbolIdx(symbol);
	symbols[bucket] = val;
}

void generateCode()
{
	
	int i = 0;
	int line=1;
	printf("Three Address Code : \n");
	for(;i<quadruplesIdx+1;i++, line++){
		if(quadruples[i].result[0] == '0'){
			printf("%3d. EXIT\n", line); break;
		}
		if(quadruples[i].result[0] == '\0' && quadruples[i].operator[0] == 'P'){
			printf("%3d. PRINT %s\n", line, quadruples[i].operand1); continue;
		}
		if(quadruples[i].operator[0] == 'G' && quadruples[i].operator[1] == 'O'){
			if(quadruples[i].operand1[0]=='\0' && quadruples[i].operand2[0]=='\0'){
				printf("%3d. GOTO %s\n", line, quadruples[i].result); continue;
			}
			printf("%3d. IF %s %s %s GOTO %s\n", line, quadruples[i].operand1, (quadruples[i].operator+2), quadruples[i].operand2, quadruples[i].result);
			continue;
		}
		printf("%3d. %s := %s %s %s\n", line, quadruples[i].result, quadruples[i].operand1, quadruples[i].operator, quadruples[i].operand2);
	}
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
}

void yyerror (char *s) {fprintf (stderr, "Error -> %s", s);}