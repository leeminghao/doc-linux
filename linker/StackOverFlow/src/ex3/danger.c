#include <stdio.h>

int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    int sum;
    int *ret;

    buffer[0] = 'a';
    buffer[1] = 'b';
    buffer[2] = 'c';
    buffer[3] = 'd';
    buffer[4] = 'e';
    buffer[5] = 'f';
    buffer[6] = 'g';
    buffer[7] = 'h';
    buffer[8] = 'i';
    buffer[9] = 'j';
    buffer[10] = 'k';
    buffer[11] = 'l';
    buffer[12] = 'm';
    buffer[13] = 'n';

    // the location is function return address
    ret = (int*)(buffer + 26);
    // return address + 8 for jump to next instruct
    (*ret) += 8;
    sum = a + b + c;
    return sum;
}

void main()
{
    int x;

    x = 0;
    function(1, 2, 3);
    x = 1;
    printf("%d\n", x);
}

/* The stack of `main` call `function`
|        ...
|-------------------------------| main ebp     : 40      : 32
|       call main ebp
|-------------------------------| -4           : 36      : 28
|    x = 0 - movl $0, 28(%esp)
|-------------------------------| -8           : 32      : 24
|
|-------------------------------| -12          : 28      : 20
|
|-------------------------------| -16          : 24      : 16
|
|-------------------------------| -20          : 20      : 12
|
|-------------------------------| -24          : 16      : 8
|             3
|-------------------------------| -28          : 12      : 4
|             2
|-------------------------------| -32          : 8       : base main esp
|             1
|-------------------------------| -36          : 4       : call function
|   x = 1 - movl $1, 28(%esp)     <-- return address
|-------------------------------| function ebp : main esp
|      main ebp
|-------------------------------| -4           : 28
|            ret
|-------------------------------| -8           : 24
|  sum  |   buffer[13-11]
|-------------------------------| -12          : 20
| buffer[10-9] | buffer[8-7]
|-------------------------------| -16          : 16
| buffer[6-5]  | buffer[4-3]
|-------------------------------| -20          : 12
| buferr[2-1]  | buffer[0]
|-------------------------------| -24          : 8
|
|-------------------------------| -28          : 4
|
|-------------------------------| -32          : base function esp
 */
