#!/usr/bin/perl
# Watch cameras' price and send mail on change.
# Run daily from cron.
use strict;
use warnings;
use LWP::Simple;
use autodie;

my $recipient = shift;
die "Usage: $0 foo\@bar.com\n" unless $recipient;

my @cameras = qw(
  panasonic-lumix-dmc-lx3
  panasonic-lumix-dmc-lx5
  panasonic-lumix-dmc-lx7
);
my $file     = "last_camera_price.txt";
my $base_url = 'http://digitalne-fotoaparaty.heureka.sk';

my %price;

for my $camera (@cameras) {
    my $url     = "$base_url/$camera/";
    my $content = get $url;

    if ( $content =~ /<title>(.*?)<\/title>/ ) {
        my $title = $1;
        if ( $title =~ /\s+od\s+([\d,]+)\s+/ ) {
            my $price = $1;
            $price =~ s/,/./;    # change to numnber
            $price{$camera} = $price;
        }
    }
}

if ( -e $file and -s _ ) {       # file does not exist yet (first check)
    open my $in, "<", $file;
    while (<$in>) {
        chomp;
        my ( $camera, $last_price ) = split /\t\t/;
        #<<<
        if ( $price{$camera} > $last_price ) {
            send_mail("Price of $camera increased ($last_price => $price{$camera}) - $base_url/$camera");
        } elsif ( $price{$camera} < $last_price ) {
            send_mail("Price of $camera decreased ($last_price => $price{$camera}) - $base_url/$camera");
        }
        #>>>
    }
    close $in;
}

open my $out, ">", $file;
for ( keys %price ) {
    print $out "$_\t\t$price{$_}\n";
}
close $out;

sub send_mail {
    my $mail_body = shift;

    # Create mail message
    use Email::MIME;
    my $message = Email::MIME->create(
        header_str => [
            From    => 'root@openhouse.sk',
            To      => $recipient,
            Subject => 'Camera price',
        ],
        attributes => {
            encoding => 'quoted-printable',
            charset  => 'UTF-8',
        },
        body_str => $mail_body,
    );

    # Send the message
    use Email::Sender::Simple qw(sendmail);
    sendmail($message);
}
