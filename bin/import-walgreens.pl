#!/usr/bin/env perl

use strict;
use warnings;
use Cwd 'abs_path';
use File::Spec::Functions qw(catpath splitpath);
use local::lib catpath((splitpath(abs_path $0))[0, 1], '../local');
use lib catpath((splitpath(abs_path $0))[0, 1], '../lib');
use IO::All;
use Text::CSV_XS;
use DBI;
use JSON::XS;
use Data::Printer;
use Geo::Coder::Google;
use List::MoreUtils qw/any/;
use Try::Tiny;
use DateTimeX::Easy;
use feature qw/say/;
no warnings qw/uninitialized/;

my $db_host = 'localhost';
my $db_user = 'el';
my $db_name = 'empirelogistics';

my $dsn = "dbi:Pg:dbname=$db_name;host=$db_host";

my $dbh = DBI->connect(
    $dsn, $db_user, '3mp1r3',
    {   RaiseError    => 1,
        AutoCommit    => 0,
        on_connect_do => ['set timezone = "America/Los Angeles"']
    }
) || die "Error connecting to the database: $DBI::errstr\n";

my $geocoder = Geo::Coder::Google->new( apiver => 3 );

my $dir  = "data/warehouses";
my $file = "$dir/walgreens.csv";

my $io  = io($file);

my $csv = Text::CSV_XS->new( { allow_loose_quotes => 1, binary => 1, auto_diag => 1 } );
my $cols = $csv->column_names("address","city","state","zip","type","type2");

my @warehouse_types = ("Walgreens Distribution Center");
my @warehouses;

sub trim {
    my ($string) = @_;
    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;
    return $string;
}

while ( my $row = $csv->getline_hr($io) ) {
    my $owner = 'walgreens';
    my $name = "Walgreen's Distribution Center";
    my $location;
    my $address = $row->{address}, ", ", $row->{city}, ", ", $row->{state}, " ", $row->{zip};
    my @types = @{$row}{qw/type type2/};
    my $description = join("; ", @types);
    try {
        $location = $geocoder->geocode( $address );
    }
    catch {
        say "Couldn't geocode ", $address, ": $_";
    };
    my ($street_number) = map { $_->{long_name} } grep {
        any {/street_number/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my ($street) = map { $_->{long_name} } grep {
        any {/route/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my $street_address = $street_number . " " . $street;
    my ($city) = map { $_->{long_name} } grep {
        any {/locality/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my ($state) = map { $_->{short_name} } grep {
        any {/administrative_area_level_1/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my ($country) = map { $_->{short_name} } grep {
        any {/country/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my ($postal_code) = map { $_->{short_name} } grep {
        any {/postal_code/}
        @{ $_->{types} }
    } @{ $location->{address_components} };
    my $lat         = $location->{geometry}{location}{lat};
    my $lon         = $location->{geometry}{location}{lng};
    my $geom = "$lon $lat";
    $street_address = trim($street_address);
    my $warehouse = [
        $name, $owner,$description,$lat,$lon,
        {   street_address => $street_address,
            city           => $city,
            state          => $state,
            postal_code    => $postal_code,
            country        => $country
        },
        $geom,
    ];
    push @warehouses, $warehouse;
    say "    Processed Walgreen's warehouse ", $street_address;

    # Sleep for google.
    sleep 1;

}

my $warehouse_type_command = "insert into warehouse_type (name) values (?)";
my $sth = $dbh->prepare($warehouse_type_command);

for my $warehouse_type (@warehouse_types) {
    $sth->execute($warehouse_type) or die $sth->errstr;
}

my $warehouse_command
    = "insert into warehouse (name,owner,description,latitude,longitude) values (?,?,?,?,?)";
$sth = $dbh->prepare($warehouse_command);

my @geom_commands;
my @geoms;
my @addresses;
for my $warehouse (@warehouses) {
    my $geom = pop @$warehouse;
    my $address = pop @$warehouse;
    $sth->execute(@$warehouse) or die $sth->errstr;
    my $newid = $dbh->last_insert_id( undef, undef, "warehouse", undef );
    push @geoms, { geometry => $geom, warehouse => $newid };
    push @addresses, { address  => $address, warehouse => $newid };
    my $geom_command;
    my ($lon,$lat) = split(" ",$geom);
    $geom_command = "update warehouse set geometry = ST_Transform(ST_SetSRID(ST_MakePoint($lon, $lat),4326),900913) where id = $newid" if $geom =~ /\d/;
    push @geom_commands, $geom_command if $geom_command;
}

for my $geom_command (@geom_commands) {
    $sth = $dbh->prepare($geom_command);
    $sth->execute();
}

for my $address (@addresses) {
    my $address_insert
        = "insert into address (street_address,city,state,postal_code,country) values (?,?,?,?,?)";
    my $warehouse_address_insert
        = "insert into warehouse_address (warehouse,address) values (?,?)";
    $sth = $dbh->prepare($address_insert);
    $sth->execute( @{ $address->{address} }
            {qw/street_address city state postal_code country/} );
    my $newid = $dbh->last_insert_id( undef, undef, "address", undef );
    $sth = $dbh->prepare($warehouse_address_insert);
    $sth->execute( $address->{warehouse}, $newid );
}

$dbh->commit or die $dbh->errstr;

1;
