#include "funcs.h"

 char* appendBar(char* input){

    char* newString=malloc(strlen(input)+20);
    newString[0] = '\0'; 
    strcat(newString,input);
    strcat(newString,"/");

    return newString;
}