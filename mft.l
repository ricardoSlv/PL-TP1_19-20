%option noyywrap
%{
    #include "funcs.h"

    char *projectName="";
    char *rootFolder="";  
    char *email="";
    char *author="";
    int depth=0;
    GNode* rootNode;
    GNode* currentNode;

%}


%x Meta DEFemail DEFauthor  SetNameRoot Tree TreeNameSet

%%
^===\ meta$          {BEGIN Meta;}
<Meta>^email:[ ]*    {BEGIN DEFemail; }
<DEFemail>.*$        {email=strdup(yytext);
                      BEGIN Meta; 
                     }
<Meta>^author:[ ]*   {BEGIN DEFauthor; }
<DEFauthor>.*$       {author=strdup(yytext);
                      BEGIN Meta;
                     }  
<Meta>^===\ tree[ ]*\n   {
                          rootFolder="";
                          BEGIN SetNameRoot; 
                         }   

<SetNameRoot>[^{%name%}\n ] {rootFolder=appendStr(rootFolder,yytext);
                            printf("%s\n",rootFolder);}
<SetNameRoot>\{%name%\} {rootFolder=appendStr(rootFolder,projectName);}
<SetNameRoot>\   {printf("space");}
<SetNameRoot>\n {currentNode = rootNode = g_node_new(rootFolder);
                 printf("start tree\n");BEGIN Tree;
                }

<Tree>^[-]* {   
                int newDepth= strlen(yytext);
                if((newDepth-depth)>1){return -1;}
                
                else if(depth>newDepth){
                    while(depth > newDepth){
                        currentNode = currentNode->parent;
                        depth --;
                    }
                    GNode* newNode = g_node_append_data(currentNode->parent,"m"); 
                    currentNode = newNode;
                }
                else if(depth < newDepth){
                GNode* newNode = g_node_append_data(currentNode,"m"); 
                currentNode = newNode;
                depth++;
                }

                else if(newDepth==depth){
                    GNode* newNode = g_node_append_data(currentNode->parent,"m"); 
                    currentNode = newNode;
                }
                BEGIN TreeNameSet;
            }

<TreeNameSet>[ ]*  {}
<TreeNameSet>[^ ^\n]*$ {
                         currentNode->data=strdup(yytext);
                         BEGIN Tree;
                        }

<Tree>[^-]|\n {}
<Meta>.|\n {}
.|\n {}
%%


int main(int argc, char const *argv[]){

    projectName = (argv[1]) ? argv[1] : ""; 
    yylex();

    printf("Email: %s, Autor; %s\n",email,author);    
    printNodos(rootNode);
    
    return 0;
}