#!/usr/bin/perl
# Mail quotes.
use strict;
use warnings;
use open qw(:std :utf8);    # undeclared streams in UTF-8
use LWP::Simple qw(get);
use Email::MIME;

my @recipients = @ARGV;
die "Usage: $0 email [ email2, email3, .. emailN ]\n" unless @recipients;

my $quotes_link =
  "https://raw.github.com/jreisinger/blog/master/publish/quotes.txt";

my @quotes = split /\n\n/, get($quotes_link);
my $quote = $quotes[ rand @quotes ];

for my $recipient (@recipients) {

    # first, create your message
    my $message = Email::MIME->create(
        header_str => [
            From    => sender(),
            To      => $recipient,
            Subject => 'QOTD',
        ],
        attributes => {
            encoding => 'quoted-printable',
            charset  => 'UTF-8',
        },
        body_str => "$quote\n",
    );

    # send the message
    use Email::Sender::Simple qw(sendmail);
    sendmail($message);
}

sub sender {
    my $login = getlogin || getpwuid($<) || "root";
    use Sys::Hostname;
    my $host = hostname;
    return "$login\@$host";
}
