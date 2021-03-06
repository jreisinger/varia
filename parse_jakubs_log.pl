#!/usr/bin/perl
# Go through log file and get total values of parameters of certain section.
use strict;
use warnings;

# Open file given as command line parameter
my $file = shift or die "Usage: $0 FILE\n";
open my $filehandle, '<', $file or die "Could not open '$file': $!\n";

my $in_section;    # scalar
my @lines;         # array
my %values;        # hash

# Process line by line
while ( my $line = <$filehandle> ) {

    # Start of section
    if (
        $line =~ /^       # beginning of line
                  Energ   # literal string
                  .*      # any number of anything except for newline
                  between # literal string
                 /ix      # ignore case and allow comments and whitespace in regex
      )
    {
        $in_section = 1;
        next;
    }

    # End of section
    if (
        $line =~ /^            # beginning of line
                  \s*          # any number of whitespace characters
                  Total Energy # literal string
                  .*           # any number of anything except for newline
                  kJ           # literal string
                  \/           # literal forward slash
                  mol          # literal string
                  $            # end of line
                 /ix           # ignore case and allow comments and whitespace in regex
      )
    {
        $in_section = 0;
        process_lines(@lines);
        next;
    }

    # We are in section
    if ($in_section) {
        push @lines, $line;
        next;
    }
}

sub process_lines {

    return if not @lines;
    for my $line (@lines) {
        # Match line like: Parameter = number
        if ( $line =~ /\s+(.*)\s+=\s*(-?[0-9\.]+)/ ) {
            my $parameter = $1;
            my $num       = $2;
            # Accumulate values
            $values{$parameter} += $num;
        }
    }

    # Empty array
    @lines = ();
}

close $filehandle;

# Generate output
for my $parameter ( sort keys %values ) {
    print "Total of '$parameter': $values{$parameter}\n";
}
