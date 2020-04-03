#include "funcs.h"


mark newMark(mark ParentMark,char* nMarkBlock,char* nMarkText){
    
    mark nMark= malloc(sizeof(struct Mark));

    if(ParentMark!=NULL){printf("parentnotnull\n");
        ParentMark->nextMark=nMark;
    }
    
    nMark->block = strdup(nMarkBlock);
    nMark->text = strdup(nMarkText);
    
    nMark->nextMark=NULL;

    return nMark;
}

void printMarks(mark rootMark){
    mark currMk=rootMark;
    while(currMk){
        printf("%s: %s\n",currMk->block,currMk->text);
        currMk=currMk->nextMark;
    }
}

void replaceMarks(char* templateName,char* projectName,mark rootMark){
    char* comand=malloc(150);
    
    mark currentMark=rootMark;

    while(currentMark){
        sprintf(comand,"sed  -i 's/{%%%s%%}/%s/g' temp.txt",currentMark->block,currentMark->text);
        system(comand);
        currentMark=currentMark->nextMark;
    }
    sprintf(comand,"sed  -i 's/{%%name%%}/%s/g' temp.txt",projectName);
    system(comand);
}


char* appendStr(char* string1,char* string2){
    
    char* newString=malloc(strlen(string1)+strlen(string2)+1);
    newString[0] = '\0'; 
    strcat(newString,string1);
    strcat(newString,string2);

    return newString;
}

char* getPath(GNode* node){
    
    char* path="";

    while(node->parent){
    path = appendStr(strdup(node->data),path);
    node = node->parent;
    }
    path = appendStr(strdup(node->data),path);

    return path;
}

void makeDirs(GNode* node){
    
    char* path=getPath(node);
    char lastChar=path[strlen(path)-1];
    printf("making dir, path: %s, last char: %s\n",path,&lastChar);
    
    if(G_NODE_IS_LEAF(node)&&lastChar!='/') {
        FILE* f=fopen(path,"a");
        fclose(f);
    }
    else{
        mkdir(path,0700);
    }    

    for(int i=0;i<g_node_n_children(node);i++){
         makeDirs(g_node_nth_child(node,i));
    }
    
    free(path);
}

GNode* findNodo(GNode* rootNode,char* targetData){
    GNode* targetNode=NULL;
    
    if(!rootNode){return NULL;}
    else if (strcmp(rootNode->data,targetData)==0) {
        return rootNode;
    }
    else{
        for(int i=0;i<g_node_n_children(rootNode);i++){
            targetNode=findNodo(g_node_nth_child(rootNode,i),targetData);
            if(targetNode!=NULL){
                return targetNode;
            }
        }
        return NULL; 
    }
}

char* getFilePath (char* nodeData, GNode* rootNode){
   
    gpointer name = strdup(nodeData);
    GNode* targetNode = findNodo(rootNode,nodeData);
    char* path=getPath(targetNode);
    return path;
}

void fileAppend(char* filePath,char* text){
        
    FILE* file=fopen(filePath,"a");
    fprintf(file,"%s",text);
    fclose(file);

}


void printNodos(GNode* node){
    
    char* pdata = "null";
    //printf("data: %s\n",node->data);
    
    if(!node){return;}
    if(node->parent){
        pdata = node->parent->data;
    }

    printf("N:%s\n P:%s  S:%d\n\n",(char*)node->data,pdata,g_node_n_children(node));
    printf("Path: %s\n",getPath(node));
    printf("%s\n",(char*)node->data);
    
    for(int i=0;i<g_node_n_children(node);i++){
         printNodos(g_node_nth_child(node,i));
    }
}


