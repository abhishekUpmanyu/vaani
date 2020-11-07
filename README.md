# Vaani

## Getting Started

1. To get started, first make sure you have flex(lex) and bison(yacc) installed on your system
2. Also make sure you have git installed and set up on your computer
3. To clone the repo, go to cmd:
```
git clone https://github.com/abhishekUpmanyu/vaani
```
4. Change to a new branch:
```
cd vaani
git checkout -b branchName 
```
branchName should ideally be informative of whatever task you're performing
5. Make your changes

## Compiling

1. TO compile the program, first compile .y file (the command `bison` maybe different based on whether you use bison or yacc)
`bison -d vaani.y`
2. Compile lex file
`flex vaani.l`
3. Compiler generated code to an output file
`gcc lex.yy.c vaani.tab.c -o out`
4. Run
`.\out`

## Pushing the code

1. Start cmd
2. Switch to the directory you're working in
`cd <path>`
3. Commit and push (Replcae `<Some Commit message>` witha  commit message and `branchName` with the branch you created earlier)
```
git add .
git commit -m "<Some Commit message>"
git push origin branchName
```
4. Go to github and open a PR for your branch
