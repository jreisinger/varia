#!/usr/bin/perl
# Get n random lines from a file.
use strict;
use warnings;
use 5.010;

sub get_rand_lines {

    # Return $n random lines
    my $file = shift;
    my $n = shift // 1;    # defaults to 1

    open my $fh, $file or die "$file: $!\n";
    chomp( my @lines = <$fh> );

    my @rand_lines;
    while ( @rand_lines < $n ) {
        my $rand_line = @lines[ rand @lines ];
        push @rand_lines, $rand_line;
    }

    close $fh;

    return @rand_lines;
}

die "Usage: $0 <file> [n]\n" unless @ARGV >= 1;

my $file = shift;
my $n    = shift;
say for get_rand_lines( $file, $n );
