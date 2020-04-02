%option noyywrap
%{
    #include "funcs.h"

    char *projectName="";
    char *email="";
    char *author="";

    char *rootFolder=""; 
    char *currentName="";
    char *currentFile="";

    int depth=0;

    GNode* rootNode;
    GNode* currentNode;

    mark rootMark;
    mark currentMark;
%}


%x MetaBlock MetaText SetNameRoot Tree TreeNameSet FileNameSet FileWrite 

%%
^===\ meta$          {BEGIN MetaBlock;
                      currentName="";}

<MetaBlock>[:\n ]+        {appendStr(currentName,yytext);}
<MetaBlock>:[ ]* {BEGIN MetaText;}
<MetaText>.+ {appendStr(currentName,yytext);}  
<MetaText>\n {BEGIN MetaBlock;}
<MetaBlock>^===\ tree[ ]*\n   {
                          rootFolder="";
                          BEGIN SetNameRoot; 
                         } 
<MetaBlock>\ |\n  {}                           

<SetNameRoot>[^ \n]+ {rootFolder=appendStr(rootFolder,yytext);}
<SetNameRoot>\   {}
<SetNameRoot>\n {currentNode = rootNode = g_node_new(rootFolder);
                 BEGIN Tree;}

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
                currentName="";
                BEGIN TreeNameSet;
            }

<TreeNameSet>[ ]*  {}
<TreeNameSet>[^ \n]+ {currentName=appendStr(currentName,yytext);}
<TreeNameSet>\n {
                 currentNode->data=strdup(currentName);
                 BEGIN Tree;
                }   

<Tree>^===[ ]* {makeDirs(rootNode);
                currentName="";
                BEGIN FileNameSet;}
<Tree>[^-=]|\n {}


<FileNameSet>[^ \n]+ {currentName=appendStr(currentName,yytext);}
<FileNameSet>\n {currentFile=getFilePath(currentName,rootNode);
                 currentName="";
                 BEGIN FileWrite;}   

<FileWrite>.+\n {fileAppend(currentFile,yytext);}
<FileWrite>\n===[ ]* {BEGIN FileNameSet;} 


.|\n {}
%%

int main(int argc, char const *argv[]){

    projectName = (argv[1]) ? argv[1] : ""; 
    yylex();

    printNodos(rootNode);
    
    return 0;
}