int function(int a, int b, int c)
{

    char buffer[14] = { 0 };
    int sum;

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

    sum = a + b + c;
    return sum;
}

int main(int argc, char **argv)
{
    int x;
    int y;

    x = function(1, 2, 3);
    y = x + 3;

    return 0;
}
