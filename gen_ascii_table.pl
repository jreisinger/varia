#!/usr/bin/perl
# Generate simple ASCII table.
use strict;
use warnings;
use Text::ASCIITable;
use Getopt::Long;
use autodie;

my $data = "data.csv";    # default input file
my $title;
my $orig = 0;             # print original table data

usage()
  unless GetOptions(
    "title=s" => \$title,
    "file=s"  => \$data,
    "orig"    => \$orig,
  );

sub usage {
    die
"Usage: $0 --title 'Title of the table' --file <file_with_table_data> --orig";
}

# Field separator for split (PATTERN)
#my $fs = qr(\s*\|\s*);  # |
my $fs = qr(\s*;\s*);    # ;

my %fields;              # Hasf of arrays (HoA)
my $line;

# Process and store input data
open my ($fh), $data;
for (<$fh>) {
    chomp;
    my @fields = split $fs;

    # store data into a HoA
    push @{ $fields{ $line++ } }, @fields;
}

# Print ASCII table
my $t = Text::ASCIITable->new( { headingText => $title } );
for my $line ( sort keys %fields ) {
    if ( $line == 0 ) {
        $t->setCols( @{ $fields{$line} } );
    } else {
        $t->addRow( @{ $fields{$line} } );
    }
}
print $t;

# Print original table data as CSV inside an HTML comment
if ($orig) {
    print "<!-- Original table data:\n";
    for my $line ( sort keys %fields ) {
        print join( ";", @{ $fields{$line} } ) . "\n";
    }
    print "-->\n";
}
