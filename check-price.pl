#!/usr/bin/perl
# Watch price and send mail on change.
# Run daily from cron.
use strict;
use warnings;
use LWP::Simple;
use autodie;
use Sys::Hostname qw(hostname);

## CONFIGURATION

my @products = qw(
  garmin-nuvi-2595lmt
  garmin-nuvi-2597lmt
  garmin-nuvi-2455lmt
);
my $file     = "/tmp/last_price.txt";
my $base_url = 'http://gps-navigacie.heureka.sk/';

## CONFIGURATION END

# Usage
my $recipient = shift;
die "Usage: $0 foo\@bar.com\n" unless $recipient;

my %price;

# get products' price from web
for my $product (@products) {
    my $url     = "$base_url/$product/";
    my $content = get $url;

    if ( $content =~ /<title>(.*?)<\/title>/ ) {
        my $title = $1;
        if ( $title =~ /\s+od\s+([\d,]+)\s+/ ) {
            my $price = $1;
            $price =~ s/,/./;    # change to numnber
            $price{$product} = $price;
        }
    }
}

# did prices change?
if ( -e $file and -s _ ) {       # file does not exist yet (first check)
    open my $in, "<", $file;
    while (<$in>) {
        chomp;
        my ( $product, $last_price ) = split /\t\t/;
        #<<<
        if ( $price{$product} > $last_price ) {
            send_mail("Price of $product increased ($last_price => $price{$product}) - $base_url/$product");
        } elsif ( $price{$product} < $last_price ) {
            send_mail("Price of $product decreased ($last_price => $price{$product}) - $base_url/$product");
        }
        #>>>
    }
    close $in;
}

# store actual prices
open my $out, ">", $file;
for ( keys %price ) {
    print $out "$_\t\t$price{$_}\n";
}
close $out;

###################
sub send_mail {
###################
    my $mail_body = shift;

    use Email::MIME;

    # from
    my $host  = hostname;
    my $login = getlogin || getpwuid($<) || "uknown";
    my $from  = "$login\@$host";

    my $message = Email::MIME->create(
        header_str => [
            From    => $from,
            To      => $recipient,
            Subject => 'product price',
        ],
        attributes => {
            encoding => 'quoted-printable',
            charset  => 'UTF-8',
        },
        body_str => $mail_body,
    );

    # send the message
    use Email::Sender::Simple qw(sendmail);
    sendmail($message);
}
