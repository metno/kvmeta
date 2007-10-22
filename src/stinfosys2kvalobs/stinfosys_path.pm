package stinfosys_path;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(st_host st_name st_user st_port st_passwd);

use strict;
use conf;


my $conf= "st-info-sys.conf";    #"kro.conf";
my $confpath;                    #"/metno/kro/etc/";


if( defined( $ENV{"ST_INFO_SYS"}) ){
    $confpath= $ENV{"ST_INFO_SYS"} . "/etc/";
}else{
    $confpath=$ENV{"HOME"} . "/etc/";
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
















