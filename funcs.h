#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <glib.h>
#include <gmodule.h>
#include <stdio.h>

typedef struct Mark
{
    char* block;
    char* text;
    struct Mark* nextMark;
}*mark;

mark newMark(mark ParentMark,char* nMarkBlock,char* nMarkText);

void printMarks(mark rootMark); 

char* appendStr(char* string1, char* string2);

void replaceMarks(char* templateName, char* projectName, mark rootMark);

void printNodos(GNode* );

char* getPath(GNode* );

FILE* getFilePointer (char* nodeData, GNode* rootNode);


void makeDirs(GNode* );
