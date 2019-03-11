#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations
#
# $Id: stinfosys2autosnow.pl 1 2018-12-07 00:00:00Z terjeer $
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
# Description: This script prints station_param format files based on information from stinfosys. 
# For further information of measurement_methodid and paramid contact stinfosys.
#
# MAIN input from stinfosys.sensor_info where operational is true is the main source, stinfosys.obspgm_h is secondary source.
# OUTPUT into kvalobs.station_param
#
# Usage: ./stinfosys2autosnow.pl
#
# Arguments: none
#
# Example:
# $BINDIR/stinfosys2autosnow.pl > $DUMPDIR/station_param_QCX.out

use strict;
use DBI;
use stinfosys;
use trim;
# use dbQC;

# CONST
my $paramid = 112; # snow depth
my $measurement_methodid_list = "217701,217703";
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


$sth = $dbh->prepare("select distinct stationid from obspgm_h where paramid=$paramid and message_formatid in (select message_formatid from message_format where read='M') and totime is NULL"); 
$sth->execute;
my %isM;
while ( my @row = $sth->fetchrow() ) {
    $isM{$row[0]}=1;
}
$sth->finish;


$sth = $dbh->prepare("select stationid, hlevel, message_formatid, MAX(fromtime) from obspgm_h where paramid=112  and message_formatid in (select message_formatid from message_format where read='A')  group by stationid, hlevel, message_formatid order by stationid, hlevel, message_formatid"); 
$sth->execute;

my %statm;
while ( my @row = $sth->fetchrow() ) {
    $statm{$row[0]}{$row[1]}{$row[2]}=$row[3];
}
$sth->finish;


###########################################################
# print "sensor_info and operational is true: \n";

$sth =
  $dbh->prepare("
select si.stationid, si.hlevel, si.sensor, MAX(si.fromtime) from sensor_info si where si.measurement_methodid in ( $measurement_methodid_list ) and paramgroupid=$paramid and si.operational is true group by si.stationid, si.hlevel, si.sensor") or die "Can't prep\n";
$sth->execute;


my %station_param_operational;

while ( my @row = $sth->fetchrow() ) {
    my $stationid       = $row[0];
    my $hlevel          = $row[1];
    my $sensor          = $row[2];
    my $fromtime        = $row[3]; # We have here chosen to base all fromtimes on the fromtime from sensor_info

    $station_param_operational{"$stationid,$paramid,$hlevel"}=1;
    if( ! exists $isM{$stationid} ){
	my $qcx = "QC1-0-autosnow";
        print_station_param( $stationid, $paramid, $hlevel, $sensor, $fromtime, $qcx );
    }else{
	foreach my $mf ( keys %{$statm{$stationid}{$hlevel}} ){
	    my $qcx = "QC1-0-autosnow" . "_" . $mf;
	    print_station_param( $stationid, $paramid, $hlevel, $sensor, $fromtime, $qcx );
	}
    }

}
$sth->finish;

#######################################
# print "CASE1: Only in obspgm_h \n";
########
# 1) First the case where stationid not in $isM{$stationid}

$sth = $dbh->prepare("
select stationid, hlevel, MAX(fromtime) from obspgm_h where paramid=? and message_formatid in (select message_formatid from message_format where read='A') group by stationid, hlevel") or die "Can't prep\n";
$sth->execute($paramid);

my $sth_sensor = $dbh->prepare("select MAX(nsensor) from obspgm_h where paramid=? and stationid=? and hlevel=? and fromtime=? group by paramid, stationid, hlevel, fromtime");

while ( my @row = $sth->fetchrow() ) {
    my $stationid       = $row[0];
    my $hlevel          = $row[1];
    my $fromtime        = $row[2];

    if( ! exists $station_param_operational{"$stationid,$paramid,$hlevel"}){
	if( ! exists $isM{$stationid} ){
	    $sth_sensor->execute( $paramid, $stationid, $hlevel, $fromtime);
	    if(  my @row_sensor = $sth_sensor->fetchrow() ){
		my $nsensor=$row_sensor[0];
	        my $qcx = "QC1-0-autosnow";
                for( my $sensor=0; $sensor < $nsensor; $sensor++ ){
	            print_station_param( $stationid, $paramid, $hlevel, $sensor, $fromtime, $qcx );
		}
	    }
        }  
    }

}
$sth->finish;
$sth_sensor->finish;

########
# 2) Then the case where stationid is in $isM{$stationid}
# print "CASE2: Only in obspgm_h \n";
    
my $sth_m = $dbh->prepare("
select stationid, hlevel, message_formatid, MAX(fromtime) from obspgm_h where paramid=? and message_formatid in (select message_formatid from message_format where read='A') group by stationid, hlevel, message_formatid") or die "Can't prep\n";
$sth_m->execute($paramid);

my $sth_m_sensor= $dbh->prepare("select nsensor from obspgm_h where paramid=? and stationid=? and hlevel=? and message_formatid=? and fromtime=?");

while ( my @row_m = $sth_m->fetchrow() ) {
    my $stationid       = $row_m[0];
    my $hlevel          = $row_m[1];
    my $message_formatid = $row_m[2];
    my $fromtime        = $row_m[3];

    if( ! exists $station_param_operational{"$stationid,$paramid,$hlevel"}){
	if( exists $isM{$stationid} ){
	    $sth_m_sensor->execute( $paramid, $stationid, $hlevel, $message_formatid, $fromtime);
	    if(  my @row_m_sensor = $sth_m_sensor->fetchrow() ){
		my $nsensor=$row_m_sensor[0];
		my $qcx = "QC1-0-autosnow" . "_" . $message_formatid;
		for( my $sensor=0; $sensor < $nsensor; $sensor++ ){
		   print_station_param( $stationid, $paramid, $hlevel, $sensor, $fromtime, $qcx );
		}
	    }
	}
    }
}	    	    
$sth_m->finish;
$sth_m_sensor->finish; 
    
$dbh->disconnect;

sub print_station_param {
    my ( $stationid, $paramid, $level, $sensor, $fromtime, $qcx ) =
      @_;

    # INPUT: 
    # SIDE_EFFECT: Print two lines formatted as the station_param format for QC1-0-autosnow.
    # RETURN VALUE: none

    my $desc_metadata = "\\N";
    my $fromday       = 1;
    my $today         = 366;
    my $metadata = "R1\\n2";
    
    print "$stationid|$paramid|$level|$sensor|$fromday|$today|$qcx|$metadata|$desc_metadata|$fromtime\n";
    
}



