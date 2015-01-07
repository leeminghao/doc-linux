/*
 *  linux/lib/ssetmask.c
 *
 *  (C) 2015 Leeminghao
 */

#define __LIBRARY__
#include <unistd.h>

_syscall1(int,ssetmask,int,newmask)
