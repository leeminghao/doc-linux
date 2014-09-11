#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void foo(const char *input)
{
    char buf[10];

    printf("My stack looks like:\n%p\n%p\n%p\n%p\n%p\n%p\n%p\n\n");
    strcpy(buf, input);
    printf("buf = %s\n", buf);
    printf("Now the stack looks like:\n%p\n%p\n%p\n%p\n%p\n%p\n%p\n\n");
}

void bar(void)
{
    printf("Oh, I've been hacked!\n");
}

int main(int argc, char *argv[])
{

    printf("address of foo = %p\n", foo);
    printf("address of bar = %p\n", bar);

    if (argc != 2) {
        printf("Please supply a string as an argument\n");
        return 1;
    }

    foo(argv[1]);
    printf("Exit");

    return 0;
}
