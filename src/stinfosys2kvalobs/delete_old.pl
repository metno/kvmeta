#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id$
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



# Denne "tidsstyringen" er farlig og konsekvensene er per i dag uanede, 
# sletting av gamle stasjoner må gjøres manuelt inntil videre

# Kan midlertidig brukes på den måten å skrive ut forslag som kan vurderes av kyndig bruker/debugger av scriptet

use strict;
use DBI;
use trim;
use dbQC;
use intodb;

my @tt=    gmtime();
my $year=  1900 +  $tt[5];
my $month= $tt[4] + 1;
my $day=   $tt[3];

my $kvpasswd=get_passwd();

my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";


#my $outfilename= "old_stations." . $year . "-" . $month . "-" . $tt[3];
my $line;

while( defined($line=<old_stations.*>) ){
    print "$line \n";

    my $splitter='\.';
    my @sline=split /$splitter/,$line;
    my $len=@sline;
    #print "$sline[0] =  $len \n";
    if( $len > 1 ){
     my $oldtime = trim($sline[1]);
     my @sline2=split /-/,$oldtime;
     my $oldyear= $sline2[0];
     my $oldmonth= $sline2[1];
     my $oldday= $sline2[2];
      
     if((( $year - $oldyear )*365 +  ( $month - $oldmonth ))*30 + $day - $oldday > 180 ){
         my $oldstation = $line;
	 print "oldstation= $oldstation \n";
	 my $fromfile=$line;
	 open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

	 while( defined($line=<MYFILE>) ){
	     $line=trim($line);

	     if( length($line)>0 ){
		 my @sline=split /$splitter/,$line;
		 my $len=@sline; 
		 if( $len > 0 ){
		     my $stationid = trim($sline[0]);
		     print "$stationid \n";
		     #my $sth= $dbh->prepare("delete from station where stationid= $stationid");
		     #$sth->execute;
		     #$sth->finish;
		 }
	     }
	 }
	 close(MYFILE);
	 system("rm  $oldstation");

     }#if((( year - oldyear )*365 ...

     }
}



$dbh->disconnect;



