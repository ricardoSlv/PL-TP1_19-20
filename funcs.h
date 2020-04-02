#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
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

char* appendStr(char* string1, char* string2);

void printNodos(GNode* );

char* getPath(GNode* );

char* getFilePath (char* nodeData, GNode* rootNode);

void fileAppend(char* filePath,char* text);   

void makeDirs(GNode* );
