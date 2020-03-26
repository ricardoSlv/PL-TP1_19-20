#include "funcs.h"

 char* appendStr(char* string1,char* string2){
    
    char* newString=malloc(strlen(string1)+strlen(string2)+1);
    newString[0] = '\0'; 
    strcat(newString,string1);
    strcat(newString,string2);

    return newString;
}

void printNodos(GNode* node){
    char* pdata = "null";
    printf("data: %s\n",node->data);
    if(!node){return;}
    if(node->parent){
        pdata =node->parent->data;
        }
    printf("Nodo:%s, Filho do:%s, Filhos:%d\n",node->data,pdata,g_node_n_children(node));
    
     for(int i=0;i<g_node_n_children(node);i++){
         printNodos(g_node_nth_child(node,i));
     }
}