#!/usr/bin/perl
# Process RSS feeds and mail their entries.
use strict;
use warnings;
use XML::Feed;
use LWP::Simple;

my @feeds = qw(
  http://www.root.cz/rss/clanky/
  http://www.root.cz/rss/zpravicky/
  http://www.ibm.com/developerworks/views/linux/rss/libraryview.jsp
  http://www.modernperlbooks.com/mt/atom.xml
);

my $recipient = shift;
die "Usage: $0 foo\@bar.com\n" unless $recipient;

# Get and process feeds.
my $mail_body;
for my $feed (@feeds) {
    $mail_body .= "\n== $feed ==\n";
    my $string_containing_feed = get($feed);
    my $feed                   = XML::Feed->parse( \$string_containing_feed );

    binmode STDOUT, ":utf8";
    foreach ( $feed->entries ) {
        $mail_body .= "* " . $_->title . " => " . $_->link . "\n";
    }

}

send_mail($mail_body);

sub send_mail {
    my $mail_body = shift;

    my $login = getlogin || getpwuid($<) || "root";
    use Sys::Hostname;
    my $host = hostname;

    # Create mail message
    use Email::MIME;
    my $message = Email::MIME->create(
        header_str => [
            From    => "$login\@$host",
            To      => $recipient,
            Subject => 'RSS feeds',
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
