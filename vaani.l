%{
#include "vaani.tab.h"
void yyerror (char *s);
int yylex();
%}
%%
"if"                        {return if_;}
"else"                      {return else_;}

"while"                     {return while_;}

"print"                     {return print;}

"exit"                      {return exit_statement;}

"True"                      {return true_;}
"False"                     {return false_;}

"<"                         {return less;}
">"                         {return greater;}
"=="                        {return equal;}
"<="                        {return lessequal;}
">="                        {return greaterequal;}
"!="                        {return notequal;}

[a-zA-Z]                    {yylval.id = yytext[0]; return id;}
([0-9]*[.])?[0-9]+     {yylval.num = atof(yytext); printf("FLOAT, %s", yytext);return num;}
[ \t\n]                     ;
[-+=;*/(){}%]               {return yytext[0];}
^[a-zA-Z_][a-zA-Z_0-9]*$    {ECHO; yyerror ("Sorry, only uni-character names are possible"); exit(1);}
.                           {ECHO; yyerror ("unexpected character"); exit(1);}

%%
int yywrap (void) {return 1;}

// TODO: Change token names accordingly