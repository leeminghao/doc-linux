/*
 *  linux/lib/signal.c
 *
 *  (C) 2015 Leeminghao
 */

#define __LIBRARY__
#include <unistd.h>

void (*signal(int sig, void (*fn)(int)))(int signal)
{
    long res;
    __asm__ volatile ("int $0x80"
                      : "=a" (res)
                      : "0" (__NR_signal),"b" ((long)(sig)),"c" ((long)(fn)));
    if (res >= 0)
        return (void(*)(int)) res;
    errno = -res;
    return 0;
}
