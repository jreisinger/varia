#!/usr/bin/perl
# Process RSS feeds and mail their entries.
use strict;
use warnings;
use XML::Feed;
use LWP::Simple;
use autodie;

my $feeds = [    # aref
    qw(
      http://www.modernperlbooks.com/mt/atom.xml
      http://www.root.cz/rss/clanky/
      http://www.root.cz/rss/zpravicky/
      http://www.ibm.com/developerworks/views/linux/rss/libraryview.jsp
      )
];

my $home      = glob "~";
my $sent_file = "$home/.rss_reader.sent";    # File keeping the entries already sent

my $recipient = shift;
die "Usage: $0 foo\@bar.com\n" unless $recipient;

#
# Create mail body in HTML
#
my $mail_body;
for my $feed (@$feeds) {
    my $entries = get_entries($feed);

    filter_out_old_entries($entries);

    my ($title) = $feed =~ /http:\/\/(?:www\.)?(\w+\.\w+)\//;
    $mail_body .= "<a href=$feed>$title</a>";
    $mail_body .= "<ul>";
    for my $link ( keys %$entries ) {
        $mail_body .= "<li>" . $entries->{$link} . " (<a href=$link>link</a>)" . "</li>";
    }
    $mail_body .= "</ul>";

    store_links_to_file( $sent_file, [ keys %$entries ] );
}

#
# Send email
#
send_mail($mail_body);

########################
sub get_entries {
########################
    my %entry;

    my $string_containing_feed = get( $_[0] );
    my $feed                   = XML::Feed->parse( \$string_containing_feed );

    foreach ( $feed->entries ) {
        $entry{ $_->link } = $_->title;
    }

    return \%entry;
}

########################
sub filter_out_old_entries {
########################
    my $entry = shift;    # href

    for my $link ( keys %$entry ) {
        last unless -f $sent_file;    # no old entries yet
        open my $fh, "<", $sent_file;
        chomp( my @sent = <$fh> );
        if ( grep { $link eq $_ } @sent ) {
            delete $entry->{$link};
        }
        close $fh;
    }
}

########################
sub store_links_to_file {
########################
    my $file  = shift;
    my $links = shift;    # aref

    open my $fh, ">>", $file;    # append new links
    print $fh "$_\n" for @$links;
    close $fh;
}

########################
sub send_mail {
########################
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
            encoding     => 'quoted-printable',
            charset      => 'UTF-8',
            content_type => 'text/html', # HTML email
          },
        body_str => $mail_body,
    );

    # Send the message
    use Email::Sender::Simple qw(sendmail);
    sendmail($message);
}
