#!/usr/bin/env perl
# Get your command through proxy that requires authentication.
# Installation
#     Place proxyfyme.pl in ~/bin.
#     Change mode: chmod 755 ~/bin/proxyfyme.pl
#     Add this to ~/.bashrc: alias proxyfyme="~/bin/proxyfyme.pl"
# Sample usage:
#     proxyfyme cpanm Nmap::Parser
use strict;
use warnings;
use autodie;

#########################
# User editable variables
my $wpad_url  = 'http://wpad/wpad.dat';
my $conf_file = "$ENV{HOME}/.proxyfyme";

######
# Main
die "Usage: $0 <linux command>\n" unless @ARGV;

my %conf;
my $pass;

if ( -s $conf_file ) {    # do we have config file?
    get_conf_from_file();
} else {
    get_conf_via_wpad();
    confirm_conf();
    store_conf();
}

get_passwd();

# Set proxy and run command
$ENV{http_proxy}  = "http://$conf{user}:$pass\@$conf{server}:$conf{port}";
$ENV{https_proxy} = "http://$conf{user}:$pass\@$conf{server}:$conf{port}";
exec "@ARGV";

###########
# Functions
sub get_conf_via_wpad {

    # Automatic proxy configuration using WPAD

    my $html;
    if ( !system "which wget > /dev/null" ) {    # do we have wget installed?
        $html = `wget -q -O - $wpad_url`;
        ##$html = `curl -s $wpad_url`;
    } else {
        $html = "";
    }
    $conf{server} = $html =~ /Node\("?([0-9\.]+)"?/      ? $1 : "";
    $conf{port}   = $html =~ /HttpPort="?([0-9]{1,5})"?/ ? $1 : "8080";
    $conf{user} = $ENV{USER} ? $ENV{USER} : "";
}

sub confirm_conf {

    # Confirm values with the user

    for (qw( user server port )) {
        print "Enter proxy $_ [defaults to: '$conf{$_}']> ";
        chomp( my $input = <STDIN> );
        next if $input =~ /^\s*$/;    # keep the previous value
        $conf{$_} = $input;
    }
}

sub store_conf {

    # Store proxy configuration to a file

    open my $fh, ">", $conf_file;
    for (qw( user server port )) {
        print $fh "$_ = $conf{$_}\n";
    }
    close $fh;

    print "\nProxy configuration stored to '$conf_file'.\n";
    print "Check it is ok, it will be used from now on\n\n";
}

sub get_conf_from_file {

    # Get configuration from file

    open my $fh, "<", $conf_file;
    while (<$fh>) {
        chomp;
        for my $param (qw( user server port )) {
            $conf{$param} = $1 if /^\s*$param\s*=\s*(\S+)\s*$/;
        }
    }
    close $fh;
}

sub get_passwd {

    # Get proxy password from user

    system "stty -echo";
    print "Enter password for '$conf{user}'> ";
    chomp( $pass = <STDIN> );
    system "stty echo";
    print "\n";
}
