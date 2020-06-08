#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations
#
# $Id: stinfosys2QC1-1-112.pl 1 2018-12-07 terjeer $
#
# Copyright (C) 2007 met.no
#
# Contact information:
# Norwegian Meteorological Institute
# Box 43 Blindern
# 0313 OSLO
# NORWAY
# email: kvalobs-dev@met.no
#
# This file is part of KVALOBS_METADATA
#
# KVALOBS_METADATA is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# KVALOBS_METADATA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with KVALOBS_METADATA; if not, write to the Free Software Foundation Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


####
# Description: This script prints station_param format files based on information from stinfosys. The select returns heights with metadata from sensor_info where measurement_methodid=217701 and paramid=112.
# For further information of measurement_methodid and paramid contact stinfosys.
#
# Usage: ./stinfosys2QC1-1-112.pl
#
# Arguments: none
#
# Example:
# $BINDIR/stinfosys2QC1-1-112.pl > $DUMPDIR/station_param_QCX.out

use strict;
use DBI;
use stinfosys;
use trim;
# use dbQC;

# CONST
my $paramid = 112; # snow depth
my $measurement_methodid =217701; # Ultrasonic method
my $measurement_methodid_list = "217701,217703";
my $default_min_clear_factor=50;
# END CONST

# my %hfromday = fhfromday(); # from dbQC.pm
# my %htoday   = fhtoday();   # from dbQC.pm

my $len = @ARGV;

my $stname   = st_name();
my $sthost   = st_host();
my $stport   = st_port();
my $stuser   = st_user();
my $stpasswd = st_passwd();

# my $outfile = ">checks_QCX.out";
# open( CHECKS, $outfile ) or die "Can't open $outfile: $!\n";

my $dbh = DBI->connect( "dbi:Pg:dbname=$stname;host=$sthost;port=$stport",
    "$stuser", "$stpasswd", { RaiseError => 1 } )
  or die "Cant't connect";
my $sth;

$sth =
  $dbh->prepare(
"select max(physical_height) from sensor_info_default where measurement_methodid =$measurement_methodid"
  );
$sth->execute;
my $default_physical_height;
if ( my $val = $sth->fetchrow() ) {
    $default_physical_height = $val;
}
$sth->finish;



#$sth =
#  $dbh->prepare(
#"select stationid, hlevel, sensor, physical_height,fromtime from sensor_info where measurement_methodid=$measurement_methodid and paramid=$paramid"
#  ) or die "Can't prep\n";
#$sth->execute;
###########################################################

$sth =
  $dbh->prepare("
select si.stationid, si.hlevel, si.sensor, MAX(si.fromtime) from sensor_info si where si.measurement_methodid in ( $measurement_methodid_list ) and paramgroupid=$paramid and si.operational is true group by si.stationid, si.hlevel, si.sensor") or die "Can't prep\n";
$sth->execute;

my $sthval =
  $dbh->prepare(
"select si.physical_height,em.description from equipmentmodel em ,equipment eq, sensor_info si where si.stationid=? and si.hlevel=? and si.sensor=? and si.fromtime=? and eq.modelname=em.modelname and eq.equipmentid=si.equipmentid and si.measurement_methodid in ( $measurement_methodid_list ) and paramgroupid=$paramid and si.operational is true"
    ) or die "Can't prep\n";
# $sth_values->execute;

my %station_param_operational;

while ( my @row = $sth->fetchrow() ) {
    my $stationid       = $row[0];
    my $hlevel          = $row[1];
    my $sensor          = $row[2];
    my $fromtime        = $row[3];

    $station_param_operational{"$stationid,$paramid,$hlevel"}=1;

    $sthval->execute($stationid,$hlevel,$sensor,$fromtime);        
    if ( my @rowval = $sthval->fetchrow() ) {
	my $physical_height=$rowval[0];
	my $description=$rowval[1];
        
        print_station_param( $stationid, $paramid, $hlevel, $sensor,
			     $physical_height, $fromtime, $description );
    }

}
$sth->finish;
$sthval->finish;
####################
$sth =
  $dbh->prepare("
select si.stationid, si.hlevel, si.sensor, MAX(si.fromtime) from sensor_info si where si.measurement_methodid in ( $measurement_methodid_list ) and paramgroupid=$paramid and si.operational is false group by si.stationid, si.hlevel, si.sensor") or die "Can't prep\n";
$sth->execute;

$sthval =
  $dbh->prepare(
"select si.physical_height,em.description from equipmentmodel em ,equipment eq, sensor_info si where si.stationid=? and si.hlevel=? and si.sensor=? and si.fromtime=? and eq.modelname=em.modelname and eq.equipmentid=si.equipmentid and si.measurement_methodid in ( $measurement_methodid_list ) and paramgroupid=$paramid and si.operational is false"
    ) or die "Can't prep\n";


# print "Operational is false: \n";

while ( my @row = $sth->fetchrow() ) {
    my $stationid       = $row[0];
    my $hlevel          = $row[1];
    my $sensor          = $row[2];
    my $fromtime        = $row[3];

    if( ! exists $station_param_operational{"$stationid,$paramid,$hlevel"} ){
	$sthval->execute($stationid,$hlevel,$sensor,$fromtime); 
	if ( my @rowval = $sthval->fetchrow() ) {
	    my $physical_height=$rowval[0];
	    my $description=$rowval[1];
	    #if( $stationid==13655 ){
            #    print "Operational is false : $stationid :  $physical_height"; 
	    #}
	    
	    print_station_param( $stationid, $paramid, $hlevel, $sensor,
				 $physical_height, $fromtime, $description );
	}
    }

}
$sth->finish;
$sthval->finish;

$dbh->disconnect;


sub print_station_param {
    my ( $stationid, $paramid, $level, $sensor, $physical_height, $fromtime, $description ) =
      @_;

    # INPUT: Physical height for a sensor with metadata.
    # SIDE_EFFECT: Print one line formatted as the station_param format for QC1-1-112.
    # RETURN VALUE: none

    my $min_clear_factor;
    if( $description =~ "min_klaring" ){   
        my @a=split /=/,$description;
        $min_clear_factor=trim($a[1]);
    }else{
	$min_clear_factor= $default_min_clear_factor;
    }
    #print "$description|$min_clear_factor\n";
    my $desc_metadata = "\\N";
    my $fromday       = 1;
    my $today         = 366;

    my $h;
    if ( ( !defined $physical_height ) or $physical_height eq "" ) {
        $h = ( $default_physical_height ) * 100 -  $default_min_clear_factor;

	#if( $stationid==13655 ){
        #   print "not defined : $stationid : $h"; 
	#}
    }
    else {
        $h = ( $physical_height ) * 100 - $min_clear_factor; # $min_clear_factor is something that was originally given in cm in Stinfosys, 
                                                             # $physical_height is in meter
	#if( $stationid==13655 ){
        #   print "DEFINED : $stationid : $h"; 
	#}
	
    }

    my $metadata = "max;highest;high;low;lowest;min\\n$h;$h;$h;-3.0;-3.0;-3.0";
    my $QCX      = "QC1-1";
    print
"$stationid|$paramid|$level|$sensor|$fromday|$today|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";

}
