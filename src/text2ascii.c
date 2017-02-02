#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#ifndef DEFAULT_SEPARATOR
#define DEFAULT_SEPARATOR			' '
#endif

#define MAX_ASCII_VALUE_STR_LENGTH		3
#define ASCII_2_TEXT_MAX_DELIM_LENGTH		1

#define CLEAR_BUF()	do { \
				for (counter = 0; counter <= MAX_ASCII_VALUE_STR_LENGTH; counter++) \
					buf[counter] = '\0'; \
				counter = 0; \
			} while (0)

int main(int argc, char *argv[])
{
	char separator = DEFAULT_SEPARATOR;
#ifdef ASCII_2_TEXT
	char buf[MAX_ASCII_VALUE_STR_LENGTH + 1];
	int ascii_val;
	int counter = 0;
#endif

	int opt;
	static const struct option long_options[] = {
		{ "help",		no_argument,		0, 'h' },
		{ "delimiter",		required_argument,	0, 'd' },
	};

	static const char options[] = "hd:";

	while ((opt = getopt_long(argc, argv, options, long_options, 0)) != EOF) {

		switch (opt) {

		case 'h':
			printf("Usage: %s [-d <delimiter>]\n", argv[0]);
			return 0;
			break;

		case 'd':
			if (strlen(optarg) != 1) {
				fprintf(stderr, "Error. The delimiter must"
						" be a single character.\n");
				return EXIT_FAILURE;
			}

			separator = optarg[0];
			break;

		default:
			fprintf(stderr, "Error: Use `--help' for more information.\n");
			return EXIT_FAILURE;
			break;

		}
	}

	char c;

#ifdef ASCII_2_TEXT
	CLEAR_BUF();

	while (1) {

		c = getchar();

		if (c != separator && c != EOF \
				&& counter < MAX_ASCII_VALUE_STR_LENGTH) {
			buf[counter++] = c;
			continue;
		}

		ascii_val = atoi(buf);

		printf("%c", ascii_val);

		CLEAR_BUF();

		if (c == EOF)
			break;
	}
#else
	while ((c = getchar()) != EOF)
		printf("%d%c", c, separator);
#endif

	return EXIT_SUCCESS;
}
