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

my $len=@ARGV;

my $stname=  st_name();
my $sthost=  st_host();
my $stport=  st_port();
my $stuser=  st_user();
my $stpasswd=st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";
 my $sth;

 $sth=$dbh->prepare("select stationid,year,description from station_info where code='Tl' and docformatid='0' order by stationid,year") or die "Can't prep\n";
 $sth->execute;

my %PH;
   $PH{"Um"}=284;
   $PH{"Tm"}=285;

while (my @row = $sth->fetchrow()) {
    my $stationid=$row[0];
    my $year=$row[1];
    my $description=$row[2];
    my $fromtime="$year-01-01 00:00:00";

        my $Tm;
        my $Um;        
        my $exist_key=0;

	if ( $description =~ /^\s*Tm/ ){
               if( $description =~ /^\s*Tm\s*=\s*(.*)Um\s*=\s*(.*)/ ){
	           # print "not exist alias2:: $stationid :: $year :: $1 :: $2 \n";
                   $Tm=$1;
                   $Um=$2;
                   $exist_key=1;
               }
        }

        if ( $description =~ /^\s*Um/ ){
               if( $description =~ /^\s*Um\s*=\s*(.*)Tm\s*=\s*(.*)/ ){
	           # print "not exist alias2:: $stationid :: $year :: $1 :: $2 \n";
	           $Um=$1;
                   $Tm=$2;
		   $exist_key=1;
		}
        }

        if( ! $exist_key ){ next; }
	    
        if( $Tm =~ /^\s*(-?\d*[\.,]?\d*).*$/ ){
           $Tm=$1;
           $Tm =~ s/,/\./g;
	   # print "not exist alias3 Tm::$Tm  \n";
           my $paramid=$PH{"Tm"};
           my $value=$Tm;
           if( length($value) > 0 ){
             print "$stationid|$paramid|\\N|\\N|\\N|VS|$value|$fromtime|\\N\n";
           }
        }

        if( $Um =~ /^\s*(\d?\d?)\s*%.*$/ ){
           $Um=$1;
           # print "not exist alias3 Um::$Um  \n";
           my $paramid=$PH{"Um"};
           my $value=$Um;
           if( length($value) > 0 ){
	     print "$stationid|$paramid|\\N|\\N|\\N|VS|$value|$fromtime|\\N\n";
           }
        }  
}
$sth->finish;


$dbh->disconnect;
