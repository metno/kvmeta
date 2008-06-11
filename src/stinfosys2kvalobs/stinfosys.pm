package stinfosys;
require Exporter;
@ISA = qw(Exporter);
@EXPORT
    = qw( st_host st_name st_user st_port st_passwd st_bin st_gui st_html st_station_info st_url_station_info st_historylog st_distribution st_rootdir st_rooturl st_rootcgi st_admission st_connect );

use strict;
use conf;
use DBI;

my $conf = "stinfosys.conf";
my $confpath;    #"/metno/stinfosys/etc/";

if ( defined( $ENV{"STINFOSYS"} ) ) {
    $confpath = $ENV{"STINFOSYS"} . "/etc/";
}
elsif ( defined( $ENV{"HOME"} ) ) {
    $confpath = "$ENV{HOME}/etc/";
}
elsif ( defined( $ENV{"USER"} ) ) {
    $confpath = "/home/$ENV{USER}/etc/";
}
else {
    $confpath = "/metno/stinfosys/etc/";
}

my $h = new conf( $conf, $confpath )
    or die
    "Cannot find stinfosys.conf file in config search path (see stinfosys.pm for details)\n";

#exit 0;

sub st_host {
    return $h->get("PGHOST");
}

sub st_name {
    return $h->get("PGNAME");
}

sub st_user {
    return $h->get("PGUSER");
}

sub st_port {
    return $h->get("PGPORT");
}

sub st_passwd {
    return $h->get("PGPASSWD");
}

sub st_bin {
    return $h->get("ST_bin");
}

sub st_gui {
    return $h->get("ST_GUI");
}

sub st_html {
    return $h->get("ST_html");
}

sub st_station_info {
    return $h->get("ST_station_info");
}

sub st_url_station_info {
    return $h->get("ST_url_station_info");
}

sub st_historylog {
    return $h->get("HISTORYLOG");
}

sub st_distribution {
    return $h->get("DISTRIBUTION");
}

sub st_rootdir {
    return $h->get("ROOTDIR");
}

sub st_rooturl {
    return $h->get("ROOTURL");
}

sub st_rootcgi {
    return $h->get("ROOTCGI");
}

sub st_connect {
    my $stname   = st_name();
    my $sthost   = st_host();
    my $stport   = st_port();
    my $stuser   = st_user();
    my $stpasswd = st_passwd();

    my $dbh = DBI->connect( "dbi:Pg:dbname=$stname;host=$sthost;port=$stport",
        "$stuser", "$stpasswd", { RaiseError => 1 } )
        or die "Connect failed: $DBI::errstr";
    return $dbh;
}


sub st_admission {
    my $dbh = shift;

    my $userid = $ENV{'REMOTE_USER'};
    if( $userid =~ /,/ ) { #this is apache 2
        my @s = split (/,/,$userid);
        my ( $name, $value ) = split ( /=/, $s[0] );
        $userid= $value;
        # print "userid=$userid";
    }


    my %person = fill_person($dbh);
    if ( !( exists $person{$userid} ) ) {
        return 0;
    }

    return $person{$userid};
}


sub fill_person {
    my $dbh = shift;
    my $sth = $dbh->prepare(
        "select username,personid from person where username is not null");
    $sth->execute;
    my %person;

    while ( my @row = $sth->fetchrow_array ) {

        #print "{$row[0]}:$row[1] <br>";
        $person{ $row[0] } = $row[1];
    }
    $sth->finish;

    return %person;
}

1;

