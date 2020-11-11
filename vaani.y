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
%code requires {
	struct incod
	{
		char codeVariable[10];
		int val;
	};
}

%union {float num; char id; int cond;};       /* Yacc definitions */
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


%left '+' '-'
%left '*' '/' '%'

%%

    line		: assignment ';'			{	stackTop = -1;}
				| exit_statement ';'		{
												printf("Exiting program. Goodbye\n");
												struct tac quadruple;
												sprintf(quadruple.result, "0");
												sprintf(quadruple.operator, "EXIT");
												quadruple.operand1[0]='\0';
												quadruple.operand2[0]='\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												generateCode();
												exit(0);
											}
				| print expression ';'		{
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												stackTop = -1;
												printf("Printing %f\n", $2); 
											}
				| line assignment ';'		{stackTop = -1;}
				| line exit_statement ';'	{printf("Exiting program. Goodbye\n");
												struct tac quadruple;
												sprintf(quadruple.result, "0");
												sprintf(quadruple.operator, "EXIT");
												quadruple.operand1[0]='\0';
												quadruple.operand2[0]='\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												generateCode();
												exit(0);}
				| print relation ';'        {
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												printf("Relation %f\n", $2);
												stackTop = -1;
											}
				| line print expression ';'	{
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												stackTop = -1;
												printf("Printing %f\n", $3); 
											}
				
				| line print relation ';'   {
												struct tac quadruple;
												quadruple.result[0]='\0';
												sprintf(quadruple.operator, "PRINT");
												sprintf(quadruple.operand1, "%s", lineBufferStack[stackTop]);
												quadruple.operand2[0] = '\0';
												quadruples[++quadruplesIdx] = quadruple;
												printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												printf("Relation %f\n", $3);
												stackTop = -1;
											}
        | condition 				{ printf("Conditional Statement %f", $1);}
				;
	
	assignment	: id '=' expression			{
												printf("[log] Assignment - %c=%f\n", $1, $3);
												updateSymbolVal($1, $3);
												if(lineBufferStack[stackTop][0] == 't'){
													stackTop--;
													printf("[log] Popped %s from stack\n", lineBufferStack[stackTop+1]); 
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
													printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												}
											}
				| id '=' relation			{
												printf("[log] Assignment - %c=%f\n", $1, $3);
												updateSymbolVal($1, $3);
												if(lineBufferStack[stackTop][0] == 't'){
													stackTop--;
													printf("[log] Popped %s from stack\n", lineBufferStack[stackTop+1]); 
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
													printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
												}
											}
				;
	expression	: num						{
												printf("[log] Pushing %f in Stack\n", $1);
												$$ = $1;
												sprintf(lineBufferStack[++stackTop], "%f", $1);
											}
				| id 						{
												printf("[log] Pushing %c in stack\n", $1);
												$$ = symbolVal($1);
												sprintf(lineBufferStack[++stackTop], "%c", $1);
											}
				| expression '+' expression {
												$$ = $1+$3;
												operateOnStack("+");
												printf("[log] Operated -> Addition - %f -> %f+%f\n", $$, $1, $3); 
											}
				| expression '-' expression {
												$$ = $1-$3;
												operateOnStack("-");
												printf("[log] Operated on -> Subtraction -  %f-%f\n", $1, $3);
											}
				| expression '*' expression {
												$$ = $1*$3;
												operateOnStack("*");
												printf("[log] Operated on -> Multiplication - %f*%f\n", $1, $3); 
											}
				| expression '/' expression { 
												$$ = $1/$3;
												operateOnStack("/");
												printf("[log] Operated on -> Division - %f/%f\n", $1, $3);
											}
				| '(' expression ')' 		{ printf("[log] Paranthesis\n"); $$ = $2;}
				;
	relation    : expression less expression        { 	$$ = ($1<$3);
														operateOnStack("<");
											         	printf("[log] Operated on-> %f<%f\n", $1,$3); 
											        }    
				| expression greater expression     { 	$$ = ($1>$3);
												      	operateOnStack(">");
											         	printf("[log] Operated on-> %f>%f\n", $1,$3); 
												    }
				| expression equal expression       { 	$$ = ($1==$3);
				                                      	operateOnStack("==");
											         	printf("[log] Operated on-> %f==%f\n", $1,$3); 
				                                    }
				| expression lessequal expression   {   $$ = ($1<=$3);
				                                    	operateOnStack("<=");
											         	printf("[log] Operated on-> %f<=%f\n", $1,$3); 
				                                    }  
				| expression greaterequal expression {  $$ = ($1>=$3);
				                                       	operateOnStack(">=");
											         	printf("[log] Operated on-> %f>=%f\n", $1,$3); 
				                                     } 
				| expression notequal expression 	{   $$ = ($1!=$3);
				                                    	operateOnStack("!=");
											         	printf("[log] Operated on-> %f!=%f\n", $1,$3); 
				                                     }
				| true_ {	$$ = 1;
							printf("[log] %f=1", $$); 

				        }
				| false_ {	$$ = 0;
							printf("[log] %f=0", $$);
				         }
				| '(' relation ')' {$$ = $2; printf("[log] (%f)", $2);}
				;
	
	condition	: if_ relation '{' line '}'                         { if($2){ 
																				printf("[log] if_stmt %f",$4);
																				$$ = $4;
																			}
																	}
				| if_ relation '{' line '}' else_ '{' line '}'      { if($2) {
																				printf("[log] if_stmt %f",$4);
																				$$ = $4;
																			 }
																		else{
																				printf("[log] else_stmt %f",$8);
																				$$ = $8;
																			}
																	}

%%

/* returns the value of a given symbol */

// this is because 1+1 is invalid 1 + 1 is valid tanks so much how di i shrink? idk :( matlab? window size f11 let me tll you the best thing to do, you'll be happ full krke ek baar windows wala button daba 

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
	printf("[log] Popped %s from stack\n", operand2); 
	operand1 = lineBufferStack[stackTop--];
	printf("[log] Popped %s from stack\n", operand1); 
	strcpy(quadruple.operand1, operand1);
	strcpy(quadruple.operand2, operand2);
	sprintf(quadruple.operator, "%s", operator);
	sprintf(quadruple.result, "t%d", ++idsUsed);
	sprintf(lineBufferStack[++stackTop], "t%d", idsUsed);
	printf("[log] Pushed t%d in stack\n", idsUsed); 
	quadruples[++quadruplesIdx] = quadruple;
	printf("[log] Pushed a quadruple. Index - %d\n", quadruplesIdx);
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