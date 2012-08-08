#!/usr/bin/perl
use strict;
use warnings;

# Create folder hierarchy based on MP3 tags.
# Based on: http://www.perlmonks.org/?node_id=985820
# To get mp3 files from directories
#   find /path/to/mp3_dirs/ -iname '*.mp3' -exec cp "{}" . \;
use MP3::Tag;
use File::Copy::Recursive qw(fmove);

my $Debug = 1;    # 1 - don't move files just print the new path

foreach my $file (<*.mp3>) {
    my $mp3 = MP3::Tag->new($file);
    my ( $title, $track, $artist, $album ) = ( $mp3->autoinfo() )[ 0, 1, 2, 3 ];
    $mp3->close();

    # Check/customize tags
    $track = $track =~ /^([0-9]+)/ ? sprintf "%02d", $1 : undef;
    $title  = $title  eq '' ? 'uknown_title'  : $title;
    $artist = $artist eq '' ? 'uknown_artist' : $artist;
    $album  = $album  eq '' ? 'uknown_album'  : $album;
    s/[\\\/:*?"<>|]//g for $artist, $album;

    my $path;
    if ( defined $track ) {    # track number tag present
        $path = "$artist/$album/$track $title.mp3";
    }
    else {                     # no track number tag
        $path = "$artist/$album/$title.mp3";
    }

    if ($Debug) {
        print "$path\n";
    }
    else {
        fmove( $file, $path )
          or warn "Can't fmove '$file': $!";
    }
}
