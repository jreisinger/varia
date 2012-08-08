#!/usr/bin/perl
use strict;
use warnings;
# Create folder hierarchy based on MP3 tags.
# Based on: http://www.perlmonks.org/?node_id=985820
# To get mp3 files from directories
#   find /path/to/mp3_dirs/ -iname '*.mp3' -exec cp "{}" . \;
use MP3::Tag;
use File::Copy::Recursive qw(fmove);

foreach my $file (<*.mp3>) {
    my $mp3 = MP3::Tag->new($file);
    my ( $song, $track, $artist, $album ) = $mp3->autoinfo();
    $mp3->close();
    $song   = $song   eq '' ? 'uknown_song'   : $song;
    $track  = $track  eq '' ? 'uknown_track'  : $track;
    $artist = $artist eq '' ? 'uknown_artist' : $artist;
    $album  = $album  eq '' ? 'uknown_album'  : $album;

    # Debug.
    #print "### $file ###\n";
    #for ( $song, $track, $artist, $album ) {
    #    print "===> |$_|\n";
    #}

    s/[\\\/:*?"<>|]//g for $artist, $album;
    fmove( $file, "$artist/$album/$file" ) or die "Can't fmove '$file': $!";
}
