#!/usr/bin/perl
# Send information on Slovak public procurement by email.
# Since they don't work on weekends (of course not! :), 
# a crontab entry could look like this:
# 55 02 * * 2-6   /root/scripts/pub_proc.pl foo@bar.com bar@foo.org
use strict;
use warnings;
use XML::Feed;
use LWP::Simple;
use Data::Dumper;
use utf8;

# Mail related variables
my $sender     = 'root@openhouse.sk';
my @recipients = @ARGV;

die "Usage: $0 rcp\@foo.com [ rcp2\@foo.com .. rcpN\@bar.org ]\n" unless @ARGV;

my $feed =
  XML::Feed->parse( URI->new('http://www.uvo.gov.sk/evestnik/-/vestnik/RSS'),
    ( 'RSS', version => 2.0 ) )
  or die XML::Feed->errstr;

# Parse XML files gathered via RSS
my %data;
for my $entry ( $feed->entries ) {
    my $link = $entry->link;
    my $id   = $entry->id;
    $link =~ s/;.*//;    # remove unnecessay suffix
    my $xml_link = "http://www.uvo.gov.sk/evestnik/-/vestnik/save/$id.xml";
    my $xml      = get($xml_link);
    $xml =~ s/\r//g;     # remove DOS newlines
    my ( $typ, $predmet, $lehota, $hodnota ) = qw(- - - -);
    #<<<  do not let perltidy touch this
    $typ = $1 if $xml =~ /<ZovoForm Version=".*" Category=".*" Type=".*" Title="([^"]+)">/;
    $predmet = $1 if $xml =~ /FormComponentId="nazovPredmetuObstaravania" Value="([^"]+)"/;
    $lehota = $1 if $xml =~ /FormComponentId="dtDatumaCas1" Value="([^"]+)"/;
    $hodnota = $1 if $xml =~ /FormComponentId="stHodnotaOd11" CssClass="NoBr PDF_beginline" Value="([^"]+)"/;
    #>>>
    push @{ $data{$id} }, $typ, $predmet, $lehota, $hodnota, $link
      unless $typ =~ /(sledku)|(predbe)/i
      ;   # I don't care about:
          #   OZNÁMENIE O VÝSLEDKU VEREJNÉHO OBSTARÁVANIA
          #   Predbežné oznámenie
}

# Create mail body
my $mail;    # mail body
my @sent_ids;
( my $prog_name = $0 ) =~ s/(\.pl)?$//;
my $ids_file = "${prog_name}_sent_ids.txt";  # file storing the already sent IDs
for my $id ( sort keys %data ) {
    next if id_sent($id);
    push @sent_ids, $id;
    $mail .= "Typ: " . $data{$id}->[0] . "\n";
    $mail .= "Predmet: " . $data{$id}->[1] . "\n";
    $mail .= "Lehota: " . $data{$id}->[2] . "\n";
    $mail .= "Hodnota: " . $data{$id}->[3] . "\n";
    $mail .= "Viac: " . $data{$id}->[4] . "\n";
    $mail .= "-" x 80 . "\n";
}

for my $recipient (@recipients) {

    # Create mail message
    use Email::MIME;
    my $message = Email::MIME->create(
        header_str => [
            From    => $sender,
            To      => $recipient,
            Subject => 'Verejné obstarávanie' . ' (' . scalar @sent_ids . ')',
        ],
        attributes => {
            encoding => 'quoted-printable',
            charset  => 'UTF-8',
        },
        body_str => $mail,
    );

    # Send the message
    use Email::Sender::Simple qw(sendmail);
    sendmail($message);
}

# Store sent IDs to a file
open my $ids, '>>', $ids_file;
print $ids "$_\n" for @sent_ids;
close $ids;

# Check whether ID has been sent before
sub id_sent {

    my $id = shift;

    return 0 unless -f $ids_file;

    open my ($fh), $ids_file;
    while ( my $id_sent = <$fh> ) {
        $id_sent =~ s/^(\d+).*$/$1/;
        return 1 if $id == $id_sent;
    }
    close $fh;

    return 0;
}
