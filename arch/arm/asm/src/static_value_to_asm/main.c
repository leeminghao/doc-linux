#include <stdio.h>
#include <stdlib.h>

int test(void)
{
    return 6;
}

int main(int argc, char *argv[])
{
    static int a = 0;

    a = test();

    return 0;
}
