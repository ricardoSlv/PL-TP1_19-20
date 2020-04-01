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

%}


%x Meta DEFemail DEFauthor  SetNameRoot Tree TreeNameSet FileNameSet FileWrite 

%%
^===\ meta$          {BEGIN Meta;}
<Meta>^email:[ ]*    {BEGIN DEFemail;}
<DEFemail>.*$        {email=strdup(yytext);
                      BEGIN Meta; 
                     }
<Meta>^author:[ ]*   {BEGIN DEFauthor;}
<DEFauthor>.*$       {author=strdup(yytext);
                      BEGIN Meta;
                     }  
<Meta>^===\ tree[ ]*\n   {
                          rootFolder="";
                          BEGIN SetNameRoot; 
                         } 
<Meta>.|\n {}                           

<SetNameRoot>[^{%name%}\n ] {rootFolder=appendStr(rootFolder,yytext);
                             printf("%s\n",rootFolder);}
<SetNameRoot>\{%name%\} {rootFolder=appendStr(rootFolder,projectName);}
<SetNameRoot>\{|%|n|a|m|e|%|\} {rootFolder=appendStr(rootFolder,projectName);}
<SetNameRoot>\   {}
<SetNameRoot>\n {currentNode = rootNode = g_node_new(rootFolder);
                printf("Started Tree, root: %s\n", currentNode->data);
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
<TreeNameSet>[^{%name%} \n]+ {currentName=appendStr(currentName,yytext);}
<TreeNameSet>\{%name%\}  {currentName=appendStr(currentName,projectName);
                          printf("yytext: %s, project: %s\n",yytext,projectName);}
<TreeNameSet>(\{|%|n|a|m|e|%|\}) {currentName=appendStr(currentName,yytext);}
<TreeNameSet>\n {
                 currentNode->data=strdup(currentName);
                 BEGIN Tree;
                }   

<Tree>^===[ ]* {makeDirs(rootNode);
                currentName="";
                BEGIN FileNameSet;}
<Tree>[^-=]|\n {printf("");}


<FileNameSet>[^{%name%} \n]+ {currentName=appendStr(currentName,yytext);}
<FileNameSet>\{%name%\}  {currentName=appendStr(currentName,projectName);
                          printf("yytext: %s, project: %s\n",yytext,projectName);}
<FileNameSet>(\{|%|n|a|m|e|%|\}) {currentName=appendStr(currentName,yytext);}
<FileNameSet>\n {currentFile=getFilePath(currentName,rootNode);
                 currentName="";
                 BEGIN FileWrite;}   

<FileWrite>[^{%name%}{%author%}\n]+\n? {fileAppend(currentFile,yytext);}

<FileWrite>\{%name%\}  {fileAppend(currentFile,projectName);}
<FileWrite>\{%name%\}\n  {fileAppend(currentFile,projectName); fileAppend(currentFile,"\n");}
<FileWrite>(\{|%|n|a|m|e|%|\})\n? {fileAppend(currentFile,yytext);}

<FileWrite>\{%author%\}  {fileAppend(currentFile,author);}
<FileWrite>\{%author%\}\n  {fileAppend(currentFile,author); fileAppend(currentFile,"\n");}
<FileWrite>(\{|%|a|u|t|h|o|r|%|\})\n? {fileAppend(currentFile,yytext);}

<FileWrite>\{%email%\}  {fileAppend(currentFile,email);}
<FileWrite>\{%email%\}\n  {fileAppend(currentFile,email); fileAppend(currentFile,"\n");}
<FileWrite>(\{|%|e|m|a|i|l|%|\})\n? {fileAppend(currentFile,yytext);}

<FileWrite>\n===[ ]* {BEGIN FileNameSet;} 


.|\n {}
%%

int main(int argc, char const *argv[]){

    projectName = (argv[1]) ? argv[1] : ""; 
    yylex();

    printf("Email: %s, Autor; %s\n",email,author);    
    printNodos(rootNode);
    
    return 0;
}