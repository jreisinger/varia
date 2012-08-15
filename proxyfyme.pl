#!/usr/bin/env perl
# Get through proxy that requires authentication.
use strict;
use warnings;

die "Usage: $0 <linux command>\n" unless @ARGV;

my $wpad_url = 'http://wpad/wpad.dat';
my %conf;

# Automatic proxy configuration.
my $html     = `curl -s $wpad_url`;
$conf{server} = $html =~ /Node\("?([0-9\.]+)"?/      ? $1 : "";
$conf{port}   = $html =~ /HttpPort="?([0-9]{1,5})"?/ ? $1 : "";
$conf{user}   = $ENV{USER} ? $ENV{USER} : "";

# Check automatic proxy configuration succeeded.
my $count = grep $conf{$_} =~ /\S+/, keys %conf;
if ( $count != 3 ) {    # not all parameters set
    for (qw( user server port )) {
        print "Enter proxy $_ [defaults to: '$conf{$_}']> ";
        chomp( my $input = <STDIN> );
        next if $input =~ /^\s*$/;    # keep the previous value
        $conf{$_} = $input;
    }
}

# Get proxy password from user
system "stty -echo";
print "Enter password for '$conf{user}'> ";
chomp( my $pass = <STDIN> );
system "stty echo";
print "\n";

# Set proxy and run command(s)
$ENV{http_proxy}  = "http://$conf{user}:$pass\@$conf{server}:$conf{port}";
$ENV{https_proxy} = "http://$conf{user}:$pass\@$conf{server}:$conf{port}";
exec "@ARGV";
