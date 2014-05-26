#!/usr/bin/perl
# Change mtime of files so they sort on TV.
use strict;
use warnings;
use 5.010;
use File::Find;

die "Usage: $0 <dir(s)>\n" unless @ARGV;

my @files;
find( sub { push @files, $File::Find::name }, @ARGV );

my $month = 1;
my $day   = 1;
for ( sort @files ) {    # sort ASCIIbetically
    next if /$0/;        # don't change myself
    system "touch", "--date=2000-$month-$day", "$_";
    if ( $day > 27 ){    # don't mess up the number of days in month
        $day = 1;
        $month++;
    } else {
        $day++;
    }
}

print "You should rebuild miniDLNA DB: sudo service minidlna force-reload\n";
