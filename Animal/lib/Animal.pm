package Animal;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

sub speak {
	my $class = shift;
	print "A $class goes ", $class->sound, "!\n";
}

sub sound {
	die 'You have to define sound() in a subclass';
}

1; # End of Animal
