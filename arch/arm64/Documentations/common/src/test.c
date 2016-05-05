#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int
func2(int x, int y, int z)
{
    int r = 0;

    r = x + y + z;

    return r;
}

static int
func1(int i, int j)
{
    int tmp = 3;
    int k = 0;
    k = func2(i, j, tmp);
    return k;
}

int main(int argc, char *argv[])
{
    int i = 1;
    int j = 2;
    int k = 0;

    k = func1(i, j);

    return 0;
}
