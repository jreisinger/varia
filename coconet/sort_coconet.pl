#!/usr/bin/perl
# Sort hosts by total bytes sent and bytes sent to different hosts.
use strict;
use warnings;
use v5.10;

my %total;

while (<>) {
    my ( $src, $dst, $bytes ) = split /\s+/;
    $total{$src}{$dst} += $bytes;
}

my %total_from;
for my $src ( keys %total ) {
    my $src_total;
    for ( keys %{ $total{$src} } ) {
        $src_total += $total{$src}{$_};
    }
    $total_from{$src} = $src_total;
}

for my $src ( sort { $total_from{$b} <=> $total_from{$a} } keys %total_from ) {
    say "$src: $total_from{$src}";
    for my $dst ( sort { $total{$src}{$b} <=> $total{$src}{$a} }
        keys %{ $total{$src} } )
    {
        say "\t" . "=> $dst: $total{$src}{$dst}";
    }
}
