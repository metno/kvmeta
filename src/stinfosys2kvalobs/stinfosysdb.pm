package stinfosysdb;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(st_host st_name st_user st_port st_passwd);

use strict;
use conf;


my $conf= "stinfosys.conf";
my $confpath;

if( defined( $ENV{"ST_INFO_SYS"}) ){
    $confpath= $ENV{"ST_INFO_SYS"} . "/etc/";
}elsif ( defined( $ENV{"HOME"} ) ) {
    $confpath=$ENV{"HOME"} . "/etc/";
}
elsif ( defined( $ENV{"USER"} ) ) {
    $confpath = "/home/$ENV{USER}/etc/";
}
else {
    $confpath = "/metno/kvalobs/etc/";
}



my $h=new conf ($conf,$confpath);

#exit 0;

sub st_host {
    return $h->get("PGHOST"); }

sub st_name {
    return $h->get("PGNAME"); }

sub st_user {
    return $h->get("PGUSER"); }

sub st_port {
    return $h->get("PGPORT"); }

sub st_passwd {
    return $h->get("PGPASSWD"); }


1;
















