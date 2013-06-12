#!/usr/bin/perl
# Generate simple ASCII table.
use strict;
use warnings;
use Text::ASCIITable;
use Getopt::Long;
use autodie;

my $data = shift;
usage() unless $data;

my $title;
my $orig = 0;    # print original table data

usage()
  unless GetOptions(
    "title=s" => \$title,
    "file=s"  => \$data,
    "orig"    => \$orig,
  );

sub usage {
    die
"Usage: $0 [ Option(s) ] <table_data.csv>\n" .
"\n" .
"Options\n" .
"\t--title 'Title of the table'\tadd title to the table\n" .
"\t--orig\t\t\t\tpreserve original table data as HTML comment\n" .
"\n";
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
        print join( " ; ", @{ $fields{$line} } ) . "\n";
    }
    print "-->\n";
}
