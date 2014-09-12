int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    buffer[13] = 'a';
    int sum;
    sum = a + b + c;
    return sum;
}

void main()
{
    int i;
    i = function(1, 2, 3);
}
