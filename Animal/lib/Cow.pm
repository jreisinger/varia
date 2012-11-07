package Cow;

use 5.006;
use strict;
use warnings;

use Animal;
our @ISA = qw(Animal);

our $VERSION = '0.01';

sub sound {
	"mooo";
}

1; # End of Cow
