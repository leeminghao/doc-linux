/*
 *  linux/lib/write.c
 *
 *  (C) 2015  Leeminghao
 */

#define __LIBRARY__
#include <unistd.h>

_syscall3(int,read,int,fd,char *,buf,off_t,count)
