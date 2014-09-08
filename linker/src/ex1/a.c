#include <string.h>

#include <unistd.h>

void a(char *s)
{
    write(1, s, strlen(s));
}
