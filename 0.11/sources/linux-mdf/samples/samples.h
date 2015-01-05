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
        write(fds[1], str1, 10);
    } else { // children
        close(fds[1]);
        read(fds[0], str2, 10);
    }

    return 0;
}

#endif /* _SAMPLES_H */
