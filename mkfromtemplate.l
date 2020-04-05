%option noyywrap
%{
    #include "funcs.h"

    char *projectName="";
    char *templateName="";
    char *markBlock="";
    char *markText="";

    char *currentName="";
    FILE *currentFile;

    int depth=0;
    int marksReplaced=0;

    GNode* rootNode;
    GNode* currentNode;

    mark rootMark;
    mark currentMark;
%}


%x MetaBlock MetaText    TreeNameSet Tree     FileNameSet FileWrite 

%%
^===\ meta\n          {BEGIN MetaBlock;
                      markBlock="";
                      markText="";
                      currentMark=NULL;
                      }
                    
<MetaBlock>[^:\n]+        {markBlock=appendStr(markBlock,yytext);}
<MetaBlock>:[ ]*           {BEGIN MetaText;}
<MetaBlock>\#.*\n           
<MetaBlock>\n           

<MetaText>.+               {markText=appendStr(markText,yytext);}  
<MetaText>\n               { if(currentMark==NULL){
                               currentMark=newMark(NULL,markBlock,markText);
                               rootMark=currentMark;
                             }
                             else{
                               currentMark->nextMark=newMark(NULL,markBlock,markText);
                               currentMark=currentMark->nextMark;  
                             }
                             markText="";markBlock=""; 
                             BEGIN MetaBlock;
                           }
<MetaBlock>^===\ tree[ ]*\n   { if(marksReplaced==0){
                                    replaceMarks(templateName,projectName,rootMark);
                                return 0;
                                }
                                currentName="";
                                rootNode=NULL;
                                BEGIN TreeNameSet;
                              } 

<TreeNameSet>[ ]*  
<TreeNameSet>[^ \n]+ {currentName=appendStr(currentName,yytext);}
<TreeNameSet>\n { if(rootNode==NULL){
                    rootNode = currentNode = g_node_new(currentName);
                  }
                 currentNode->data=strdup(currentName);
                 BEGIN Tree;
                }   

<Tree>^[-]* {   
                int newDepth= strlen(yytext);
                 
                if((newDepth-depth)>1){
                    printf("Error on tree structure\n");
                    return -1;
                }
                
                    //Shallower
                else if(depth>newDepth){
                    while(depth > newDepth){
                        currentNode = currentNode->parent;
                        depth --;
                    }
                    GNode* newNode = g_node_append_data(currentNode->parent,"m"); 
                    currentNode = newNode;
                }
                    //Deeper
                else if(depth < newDepth){
                    GNode* newNode = g_node_append_data(currentNode,"m"); 
                    currentNode = newNode;
                    depth++;
                }
                    //Same Depth
                else if(newDepth==depth){
                    GNode* newNode = g_node_append_data(currentNode->parent,"m"); 
                    currentNode = newNode;
                }

                currentName="";
                BEGIN TreeNameSet;
            }

<Tree>[^-=]|\n 

<Tree>^===[ ]* {makeDirs(rootNode);
                currentName="";
                BEGIN FileNameSet;}


<FileNameSet>[^ \n]+ {currentName=appendStr(currentName,yytext);}
<FileNameSet>\n {currentFile=getFilePointer(currentName,rootNode);
                 currentName="";
                 BEGIN FileWrite;}   

<FileWrite>.+\n {fprintf(currentFile,"%s",yytext);}
    
<FileWrite>\n===[ ]* {fclose(currentFile);
                      BEGIN FileNameSet;} 


%%

int main(int argc, char *argv[]){
    
    if(argv[2]==NULL){
        printf("Insuficient number of arguments\n");
        return 1;
    }
        
    projectName =  argv[1] ;
    templateName = argv[2] ; 

    char* comand=malloc(150);
    sprintf(comand,"cp %s temp.txt",argv[2]);
    system(comand);
    free(comand);

    freopen("temp.txt", "rw", stdin);
    marksReplaced=0;
    yylex();

    freopen("temp.txt", "rw", stdin);
    //Clean flex_buffer
    yyrestart(stdin);
    marksReplaced=1;
    yylex();

    system("rm temp.txt");
    
    return 0;
}
