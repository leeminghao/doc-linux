#ifndef _SAMPLES_H
#define _SAMPLES_H

static inline __attribute__((always_inline)) int test_pipe(void)
{
    int fds[2];
    pid_t pid;
    char str1[] = "1234567890";
    char str2[10];

    if (pipe(fds) < 0) {
        return -1;
    }
    if ((pid = fork()) < 0) {
        return -1;
    } else if (pid > 0) { // parent
        close(fds[0]);
        return write(fds[1], str1, 10);
    } else { // children
        close(fds[1]);
        return read(fds[0], str2, 10);
    }
}

#include <signal.h>

static inline void sig_usr(int signo)
{
    if (signo == SIGUSR1) {
        printf("received SIGUSR1\n");
    } else {
        printf("received %d\n", signo);
    }
}

static inline __attribute__((always_inline)) int test_signal(void)
{
    pid_t pid;

    if ((pid = fork()) < 0) {
        return -1;
    } else if (pid == 0) {
        signal(SIGUSR1, sig_usr);
        pause();
        return 0;
    } else {
        return kill(2, SIGUSR1);
    }
}

#endif /* _SAMPLES_H */
