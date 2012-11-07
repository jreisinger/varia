package Mouse;

use 5.006;
use strict;
use warnings;

our @ISA = qw(Animal);

our $VERSION = '0.01';

sub sound {
	"squeak";
}

sub speak {
	my $class = shift;
	$class->SUPER::speak;
	print "[but you can barely hear it]\n";
}

1; # End of Mouse
