#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <fcntl.h>

void say_hi(void) {
    printf("Hi I'am v1.0\n");
}

static void __attribute__ ((constructor)) init_function(void)
{
    printf("Hello, Init Library!\n");
}

static void __attribute__((destructor)) fini_function (void)
{
    printf("Hello, Destruct Library!\n");
}
