#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <glib.h>
#include <gmodule.h>

char* appendStr(char* string1, char* string2);
void printNodos(GNode* );