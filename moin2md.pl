#!/usr/bin/perl
# Convert MoinMoin wiki markup to Markdown markup.
use strict;
use warnings;

while (<>) {
    # Headings - orger is important!
    s/=== ([^=]+) ===/### $1/;  # Heading 3
    s/== ([^=]+) ==/## $1/;     # Heading 2
    s/= ([^=]+) =/# $1/;        # Heading 1

    # Bold text
    s/'''([^']+)'''/**$1**/g;

    # Links
    s/\[\[([^\|]+)\|([^\]]+)\]\]/[$2]($1)/;
    print;
}
