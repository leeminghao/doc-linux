extern void a(char *);

int main(int argc, char **argv)
{
    static char string[] = "hello world\n";
    a(string);
}
