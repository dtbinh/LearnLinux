/***********************************************************************
Test the setting of the locale variables.

	% cc -o chklocale chklocale.c

	% ./chklocale
	LC_CTYPE    = C
	LC_COLLATE  = C
	LC_TIME     = C
	LC_NUMERIC  = C
	LC_MONETARY = C
	LC_MESSAGES = C

	% env LANG=en_US ./chklocale
	LC_CTYPE    = en_US
	LC_COLLATE  = en_US
	LC_TIME     = en_US
	LC_NUMERIC  = en_US
	LC_MONETARY = en_US
	LC_MESSAGES = en_US

	% env LC_MESSAGES=da LANG=en_US ./chklocale
	LC_CTYPE    = en_US
	LC_COLLATE  = en_US
	LC_TIME     = en_US
	LC_NUMERIC  = en_US
	LC_MONETARY = en_US
	LC_MESSAGES = da

	% env LC_ALL=C LC_MESSAGES=da LANG=en_US ./chklocale
	LC_CTYPE    = C
	LC_COLLATE  = C
	LC_TIME     = C
	LC_NUMERIC  = C
	LC_MONETARY = C
	LC_MESSAGES = C

[06-Dec-2001]
***********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <locale.h>

int
main(void)
{
	char *p;

	(void)printf("LC_CTYPE    = %s\n", (p = setlocale(LC_CTYPE,   ""), p ? p : ""));
	(void)printf("LC_COLLATE  = %s\n", (p = setlocale(LC_COLLATE, ""), p ? p : ""));
	(void)printf("LC_TIME     = %s\n", (p = setlocale(LC_TIME,    ""), p ? p : ""));
	(void)printf("LC_NUMERIC  = %s\n", (p = setlocale(LC_NUMERIC, ""), p ? p : ""));
	(void)printf("LC_MONETARY = %s\n", (p = setlocale(LC_MONETARY,""), p ? p : ""));

#if defined(LC_MESSAGES)		/* POSIX.2 extension beyond C89, C++98, and C99 */
	(void)printf("LC_MESSAGES = %s\n", (p = setlocale(LC_MESSAGES,""), p ? p : ""));
#endif

	return (EXIT_SUCCESS);
}