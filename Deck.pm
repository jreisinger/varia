package Deck;
use 5.014;
use warnings;
use charnames ':full';
use List::Util;

sub new {
    my $class = shift;

    my $n_cards = 52;

    my @suit = (
        "\N{BLACK HEART SUIT}",
        "\N{BLACK SPADE SUIT}",
        "\N{BLACK DIAMOND SUIT}",
        "\N{BLACK CLUB SUIT}",
    );
    my @rank = ((2 .. 10), qw(J Q K A));

    my @deck;
    my $i = 0;
    while (@deck < $n_cards) {
        for my $s (@suit) {
            for my $r (@rank) {
                $deck[$i++] = "$r$s";
            }
        }
    }

    return bless \@deck, $class;
}

sub shuffle {
    my $deck = shift;
    
    #  list context (eg: @shuffled = $deck->shuffle()) will return a new list
    #  and leave $deck as is, but scalar or void context (eg: ;
    #  $deck->shuffle();) will shuffle $deck itself
    
    my $out = wantarray ? [] : $deck;
    @$out = List::Util::shuffle(@$deck);

    return wantarray ? @$out : $out;
}

sub deal {
    my $deck    = shift;
    my $args    = shift;
    my $n_cards = $args->{cards} // 5;
    my $hands   = $args->{hands} // 1;

    for (1 .. $hands) {
        my @hand;
        for (1 .. $n_cards) {
            die "no more cards in deck ...\n" unless @$deck;
            push @hand, shift @$deck;
        }
        binmode STDOUT, ':utf8';
        say(join " ", @hand);
    }
}

1;
