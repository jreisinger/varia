#!/usr/bin/perl
# Clone all GitHub repositories.
use strict;
use warnings;
use Net::GitHub;
use Data::Dumper;

print "GitHub login> ";
chomp(my $login = <STDIN>);
system "stty -echo";
print "GitHub password> ";
chomp(my $pass = <STDIN> );
system "stty echo";
print "\n";

# default to v3
my $github = Net::GitHub->new(  # Net::GitHub::V3
    login => $login, pass => $pass
);

my @repos = $github->repos->list;

#print Dumper \@repos;

for my $repo (@repos) {
    system "git clone $repo->{ssh_url}";
}
