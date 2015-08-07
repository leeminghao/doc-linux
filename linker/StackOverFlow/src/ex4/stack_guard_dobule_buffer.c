int function(int a, int b, int c)
{
    char buffer1[10] = { 0 };
    char buffer[14]  = { 0 };

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

    buffer1[0] = '0';
    buffer1[1] = '1';
    buffer1[2] = '2';
    buffer1[3] = '3';
    buffer1[4] = '4';
    buffer1[5] = '5';
    buffer1[6] = '6';
    buffer1[7] = '7';
    buffer1[8] = '8';
    buffer1[9] = '9';

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
