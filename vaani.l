%{
#include "vaani.tab.h"
void yyerror (char *s);
int yylex();
%}
%%
"agar"                      {return if_;}

"jabtak"                    {return while_;}

"dikhao"                    {return print;}

"exit"                      {return exit_statement;}

"Sahi"                      {return true_;}
"Galat"                     {return false_;}

"<"                         {return less;}
">"                         {return greater;}
"=="                        {return equal;}
"<="                        {return lessequal;}
">="                        {return greaterequal;}
"!="                        {return notequal;}

[a-zA-Z]                    {yylval.id = yytext[0]; return id;}
([0-9]*[.])?[0-9]+          {yylval.num = atof(yytext);return num;}
[ \t\n]                     ;
[-+=;*/(){}%]               {return yytext[0];}
^[a-zA-Z_][a-zA-Z_0-9]*$    {ECHO; yyerror ("Sorry, only uni-character names are possible"); exit(1);}
.                           {ECHO; yyerror ("unexpected character"); exit(1);}

%%
int yywrap (void) {return 1;}