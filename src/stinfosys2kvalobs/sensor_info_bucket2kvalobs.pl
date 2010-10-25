#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: station_info_avg2kvalobs.pl 1 2010-03-16 16:21:15Z terjeer $
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



use strict;
use DBI;
use stinfosys;
use trim;
use dbQC;

my %hfromday=fhfromday();
my %htoday=fhtoday();

my $len=@ARGV;

my $stname=  st_name();
my $sthost=  st_host();
my $stport=  st_port();
my $stuser=  st_user();
my $stpasswd=st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

#my $checks_path=get_checks_path();
my $DUMPDIR=".";
if( scalar( @ARGV ) > 0 ){
    $DUMPDIR=$ARGV[0];
}

my $outfile=">checks_QCX_bucket.out";
open(CHECKS,$outfile) or die "Can't open $outfile: $!\n";

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";
my $sth;


$sth=$dbh->prepare("select stationid, hlevel, sensor, sensor_info.fromtime, equipmentmodel.description from sensor_info, equipment, equipmentmodel where measurement_methodid=217502 and sensor_info.paramid=104 and sensor_info.equipmentid=equipment.equipmentid and equipment.modelname=equipmentmodel.modelname") or die "Can't prep\n";
$sth->execute;

my $paramid=104;
while (my @row = $sth->fetchrow()) {
    my $stationid=$row[0];
    my $hlevel=$row[1];
    my $sensor=$row[2];
    my $fromtime=$row[3];
    my $description=$row[4];
    # print "$description\n";
    
    if( $description =~ /^\d+/ ){ 
         my $V = $description;
         $V =~ s/^(\d+)(.*)/$1/;
         # print "V=$V\n";
         # print "$description\n";
    	 	
         print_station_param($stationid,$paramid,$hlevel,$sensor,$V,$fromtime );
    }
}
$sth->finish;
$dbh->disconnect;

print_checks($paramid);

sub print_checks{ 
   my ($paramid)=@_;

   my $QCX = "QC1-1";
   print CHECKS "0~$QCX-$paramid~$QCX~1~RANGE_CHECK~obs;RA;;|meta;RA_max,RA_highest,RA_high,RA_low,RA_lowest,RA_min;;~* * * * *~1500-01-01\n";
}


sub print_station_param{
    my ($stationid,$paramid,$level,$sensor,$V,$fromtime)=@_;

    my $desc_metadata = "\\N";
    my $fromday=1;
    my $today=365;

    my $qcx="QC1-1-104";
    my $maxV=$V + 115;
    my $metadata="max;highest;high;low;lowest;min\\n$maxV;$V;$V;50.0;0.0;-3.0";
    my $QCX = "QC1-1";
    print "$stationid|$paramid|$level|$sensor|$fromday|$today|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";
}

