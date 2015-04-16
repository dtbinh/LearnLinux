### /usr/local/src/hoc/hoc-7.0.0.beta/ascii-to-msg.awk, Sat Dec 29 09:03:19 2001
### Edit by Nelson H. F. Beebe <beebe@math.utah.edu>
### ====================================================================
### Extract quoted strings from assembly language files (*.s) produced
### by C/C++ compilers, or from input containing one quoted string per
### line, with no leading or trailing space, and convert them to a
### fragment of a hoc translation file to facilitate preparation of
### translations of internal messages.
###
### Usage:
###	awk -f ascii-to-msg.awk *.s > outfile
###
### 	awk -f ascii-to-msg.awk <<EOF > outfile
###	"def"
###	"abc"
###	EOF
###
### Warning: Some compilers (FreeBSD, IBM, lcc, SGI, ...) do not produce
### assembly code output that this program can handle: see the note on
### string formats in the code below.
### [29-Dec-2001]
### ====================================================================

BEGIN	\
{
	LAST_FILENAME = ""
	EOL = "\001"			# end-of-line marker before sort_pipe is run
	sort_pipe = "sort -u -f | tr '\001' '\n' | grep -v '^### SORTKEY:' "
	title = ""
}

(FILENAME != LAST_FILENAME)	\
{
	close(sort_pipe)
	LAST_FILENAME = FILENAME
	cfile = FILENAME
	gsub("[.]s",".c",cfile)
	title = "### ====================================================================\n" \
		"### From " cfile ":\n"
}

### Typical string formats in assembly code files:
###
###	.ascii   "illegal reassignment to immutable named constant\000"	# Sun C/C++, gcc-2.95.2
###	.ascii   "illegal reassignment to immutable named constant\X00"	# Compaq/DEC cxx
###	.asciz   "illegal reassignment to immutable named constant"	# gcc/g++ 2.95.3
###	.byte    "illegal reassignment to immutable named constant"	# IBM AIX gcc 2.95.3
###	.string  "illegal reassignment to immutable named constant"	# egcs
###	.STRINGZ "illegal reassignment to immutable named constant"	# HP-UX 10.01 cc (K&R)
###
### IBM AIX cc/c89/xlc/xlC store such constants as .long arrays of
### hexadecimal values, FreeBSD cc and SGI cc/c89/CC store such
### constants as .byte arrays of hexadecimal values, and lcc outputs
### .byte arrays decimal values: we do not attempt to deal with those
### numeric formats here.
###
### The HP cc compiler sometimes splits string constants into two parts:
###
###	.STRING	"illegal "
###	.STRINGZ	"assignment of number to existing string variable"
###
### We do not attempt to deal with those either.

/^[ \t]*[.](ascii|asciz|byte|string|STRINGZ)/ \
{
	k = index($0,"\"")
	if (k > 0)
		do_string(substr($0,k))
}

/^".*"$/ { do_string($0) }

END	{ close(sort_pipe) }

### ====================================================================

function do_string(s)
{
	gsub("\\\\000","",s)
	gsub("\\\\[xX]00","",s)
	t = s
	gsub("\\\\[abfnrtv]","",t)	# discard control characters
	gsub("0x%[0-9]*[dXx]|%[-]?[0-9*]*[.]?[*]?l?[bcdefgosxHMSYX]","",t)	# discard format items
	if (t ~ "[A-Za-z]")	# translation strings must have at least one letter!
	{
		name = msg_name(s)
		if (length(name) > 8) # ignore "___msg_x" names of one-letter messages
		{
			if (title != "")
			{
				print title
				title = ""
			}
			printf("### SORTKEY: %s%s", name, EOL)	| sort_pipe
			printf("### %s%s", s, EOL)		| sort_pipe
			printf("%s = \\%s", name, EOL)		| sort_pipe
			printf("\t\"\"%s\n", EOL)		| sort_pipe
		}
	}
}


function msg_name(s)
{
	s = tolower(s)

	## print "DEBUG 1: s = [" s "]" >"/dev/tty"

	gsub("\\\\n","\n",s)
	gsub("\\\\t","\t",s)
	gsub("\n"," ",s)
	gsub("\t"," ",s)
	gsub("\"","_",s)
	gsub("^ +","",s)
	gsub("[.]? *$","",s)
	gsub("[^a-z0-9]","_",s)
	gsub("__+","_",s)
	gsub("^_+","",s)
	gsub("_+$","",s)

	## print "DEBUG 2: s = [" s "]" >"/dev/tty"

	s = ("___msg_" s)
	if (s in InUse)
	{
		print FILENAME ":" FNR ": duplicate translation variable " s " also at " InUse[s] > "/dev/tty"
		print "### WARNING: duplicate translation variable: " s " at " InUse[s] " and " FILENAME ":" FNR
	}
	else
		InUse[s] = FILENAME ":" FNR
	return (s)
}
