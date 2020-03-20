%option noyywrap
%{
    #include <string.h>
    #include <stdlib.h> 
    #include <glib.h>
    #include <gmodule.h>
    #include <string.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <errno.h>
    #include "funcs.h"

    char *projectName="my-project";
    char *email="";
    char *author="";
    int depth=0;
    GNode* rootNode;
    GNode* currentNode;

%}


%x Meta DEFemail DEFauthor Tree TreeNameSet TreeRoot

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
<Meta>^===\ tree$    { 
                       currentNode=rootNode= g_node_new(appendBar(projectName));
                       BEGIN Tree;
                     }   

<TreeRoot>^.$ {}                                  

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

void printNodos(GNode* node){
    char* pdata = "null";
    if(node->parent){
        pdata =node->parent->data;
        }
    printf("Nodo:%s, Filho do:%s, Filhos:%d\n",node->data,pdata,g_node_n_children(node));
    
     for(int i=0;i<g_node_n_children(node);i++){
         printNodos(g_node_nth_child(node,i));
     }
}



int main(int argc, char const *argv[]){
    
    projectName=argv[1];
    
    yylex();

    printf("Email: %s, Autor; %s\n",email,author);    
    printNodos(rootNode);
    
    return 0;
}