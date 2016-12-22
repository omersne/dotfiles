#include <stdio.h>

void take_from_stdin(void)
{	
	char c;
	while ((c = getc(stdin)) != EOF) {

		if (c == '\n') {
			fputs("\\n", stdout);
		} else {
			putc(c, stdout);
		}
	}
}

void take_from_arg(char *arg)
{
	int i = 0;
	while (arg[i] != '\0') {

		if (arg[i] == '\n')
			fputs("\\n", stdout);
		else
			putc(arg[i], stdout);

		i++;
	}
}

int main(int argc, char *argv[])
{
	if (argc == 1) {
		take_from_stdin();
	} else {
		take_from_arg(argv[1]);
	}
	
	return 0;
}

