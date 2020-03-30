#include "funcs.h"

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
    
    if(G_NODE_IS_LEAF(node)&&lastChar!='/') 
        fopen(path,"a");
    else{
        mkdir(path,0700);
    }    

    for(int i=0;i<g_node_n_children(node);i++){
         makeDirs(g_node_nth_child(node,i));
    }
}

void printNodos(GNode* node){
    char* pdata = "null";
    printf("data: %s\n",node->data);
    if(!node){return;}
    if(node->parent){
        pdata = node->parent->data;
        }
    printf("Nodo:%s, Filho do:%s, Filhos:%d\n",node->data,pdata,g_node_n_children(node));
    printf("Path: %s\n",getPath(node));
    
     for(int i=0;i<g_node_n_children(node);i++){
         printNodos(g_node_nth_child(node,i));
     }
}