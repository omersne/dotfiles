#include <stdio.h>

int main(int argc, char *argv[])
{
	char old = '\0';

	char c = getc(stdin);
	while (1) {

		if (c == EOF) {

			if (old != '\n' && old != '\0')
				putc(old, stdout);
			break;

		} else {

			putc(old, stdout);

		}

		old = c;

		c = getc(stdin);
	}

	return 0;
}

