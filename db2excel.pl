#!/usr/bin/perl
# Get some data from database and store then to Excel file.
use strict;
use warnings;
use DBI;
use Excel::Writer::XLSX;
use Encode 'decode';

# User configuration
my $host     = 'localhost';
my $database = 'MYDB';
my $username = 'foo';

my $out_file = shift;
die "Usage: $0 <follow_up_YYYY_MM_DD.xls>\n" unless $out_file;
my $password = get_passwd($username);

# Connect to the database.
my $dbh = DBI->connect( "DBI:mysql:$database;host=$host",
    $username, $password, { 'RaiseError' => 1 } );

my $query = qq{ SELECT title, author, comment
                FROM books
                WHERE topic="Java" };

# Retrieve data.
my $sth = $dbh->prepare($query);
$sth->execute();

# Check for errors
die "Error:" . $dbh->errstr . "\n" if !$sth;
die "Error:" . $sth->errstr . "\n" if !$sth->execute;

my $names     = $sth->{'NAME'};            # header names
my $numFields = $sth->{'NUM_OF_FIELDS'};

# Create a new Excel workbook and add a worksheet
my $workbook  = Excel::Writer::XLSX->new($out_file);
my $worksheet = $workbook->add_worksheet();

# Create table header
my $header_format = $workbook->add_format();
$header_format->set_bold();
$worksheet->write_row( 0, 0, $names, $header_format );

my $j = 1;                                 # start after header
while ( my $ref = $sth->fetchrow_arrayref ) {

    # convert encodings of each field
    for ( my $i = 0 ; $i < $numFields ; $i++ ) {
        $$ref[$i] = decode( 'cp1250', $$ref[$i] );
    }

    # write row to worksheet
    $worksheet->write_row( $j++, 0, $ref );
}

$sth->finish();

# Disconnect from the database;
$dbh->disconnect();

sub get_passwd {
    my $user = shift;
    my $pass;

    system "stty -echo";
    print "Enter password for '$user'> ";
    chomp( $pass = <STDIN> );
    system "stty echo";
    print "\n";

    return $pass;
}
