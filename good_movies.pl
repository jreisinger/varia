#!/usr/bin/perl
# Search through IMDB movies to find the good ones.
use strict;
use warnings;
use IMDB::Film;

# User configuration
my $ids_file    = 'seen_ids.txt';
my $movies_file = 'good_movies.txt';
my $min_rating  = 7;
my $min_raters  = 1000;

# Let's handle interrupts (Ctrl+C)
my $int_count;
sub my_int_handler { $int_count++ }
$SIG{'INT'} = 'my_int_handler';

sub id_seen {
    my $id = shift;

    return 0 unless -f $ids_file;

    open my ($fh), $ids_file;
    while ( my $id_seen = <$fh> ) {
        $id_seen =~ s/^(\d+).*$/$1/;
        return 1 if $id == $id_seen;
    }
    close $fh;

    return 0;
}

my ( $good_movies, $bad_movies, $no_rating, $errors ) = qw(0 0 0 0);

sub interrupt_seen {
    print "[ program interrupted... ]\n";

    # Print report
    print "-" x 79 . "\n";
    print "Good movies: $good_movies\n";
    print "Bad movies: $bad_movies\n";
    print "No rating: $no_rating\n";
    print "Errors: $errors\n";
    exit 1;
}

while (1) {
    sleep int rand(10);    # lets be decent and wait for some random time

    my $id = sprintf "%07d", int rand(2000000);
    print "--> Looking up $id\n";
    if ( id_seen($id) ) {
        if ($int_count) { interrupt_seen }
        print "$id already seen, skipping ...\n";
        next;
    }
    open my $ids, '>>', $ids_file;
    print $ids $id . "\n";
    close $ids;

    my $film;
    eval { $film = new IMDB::Film( crit => $id ); };
    my $error = $@;
    if ($error) {
        $errors++;
        print "Error: $error";
        if ($int_count) { interrupt_seen }
        next;
    }

    if ( $film->status ) {
        my ( $rating, $vnum, $awards ) = $film->rating();
        if ( defined $rating and $rating > $min_rating and $vnum > $min_raters )
        {
            $good_movies++;
            print "[" . $film->title() . "] is a good movie\n";
            open my $movies, '>>', $movies_file;
            select $movies;
            print "Id: " . $id . "\n";
            print "Title: " . $film->title() . "\n";
            print "Year: " . $film->year() . "\n";
            print "Genres: " . "@{ $film->genres() }" . "\n";
            print "Plot Symmary: " . $film->plot() . "\n";
            print "Rating: " . $rating . " ($vnum)" . "\n";
            print "\n";
            close $movies;
            select STDOUT;
        } elsif ( defined $rating ) {
            $bad_movies++;
            print "["
              . $film->title()
              . "] has only "
              . $rating
              . " ($vnum)" . "\n";
        } else {
            $no_rating++;
            print "[" . $film->title() . "] has no rating " . "\n";
        }
    } else {
        $errors++;
        print "Something wrong: " . $film->error;
    }

    if ($int_count) { interrupt_seen }
}

