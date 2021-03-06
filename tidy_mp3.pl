#!/usr/bin/perl
# Create folder hierarchy based on MP3 tags.
# Based on: http://www.perlmonks.org/?node_id=985820
# To get mp3 files from directories
#   find /path/to/mp3_dirs/ -iname '*.mp3' -exec cp "{}" . \;
use strict;
use warnings;
use MP3::Tag;
use File::Copy::Recursive qw(fmove);
use utf8;

my $Debug = 1;    # 1 - don't move files just print the new path

foreach my $file (<*.mp3>) {
    my $mp3 = MP3::Tag->new($file);
    my ( $title, $track, $artist, $album ) = ( $mp3->autoinfo() )[ 0, 1, 2, 3 ];
    $mp3->close();

    # Check/customize tags
    $track = $track =~ /^([0-9]+)/ ? sprintf "%02d", $1 : undef;
    $title  = 'unknown_title'    if $title  !~ /\S/;
    $artist = 'unknown_artist'   if $artist !~ /\S/;
    $album  = 'unknown_album'    if $album  !~ /\S/;
    s/[\\\/:*?"<>|]//g for $artist, $album;

    # Set the new path
    my $path =
      defined $track
      ? "$artist/$album/$track $title.mp3"
      : "$artist/$album/$title.mp3";

    if ($Debug) {
        binmode STDOUT, ":utf8";
        print "$path\n";
    } else {
        fmove( $file, $path ) or warn "Can't fmove '$file': $!";
    }
}
