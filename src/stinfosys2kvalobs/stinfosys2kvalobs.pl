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




use strict;
use DBI;
use stinfosys_path;
use trim;
use kvTime;
use wmonr_stinfosys2kvalobs;

my %stationf;
my %station_counter;

my $days_back=365;

    my @tt=    gmtime(time);
    my $year=  1900 +  $tt[5];
    my $month= $tt[4] + 1;
    my $day=   $tt[3];
#print "$year,$month,$day\n";


    my $stname=  st_name();
    my $sthost=  st_host();
    my $stport=  st_port();
    my $stuser=  st_user();
    my $stpasswd=st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Vi får ikke forbindelse med databasen";

my $sth=$dbh->prepare("select * from station") or die "Can't prep\n";
$sth->execute;

while (my @row = $sth->fetchrow()) {
    my $len=@row;
    my $b=0;

    if(!defined($row[14])){
      $b=1;       
    }else{
	#print "$row[0]\n";
	$row[14]= trim($row[14]);
	if(length($row[14]) == 0 ){
	    $b=1;
	}
	else{
	    my ( $oldyear, $oldmonth, $oldday )= getDate($row[14]);
            #print "$oldyear,$oldmonth,$oldday\n";

	    if( ( $year - $oldyear )*365 +  ( $month - $oldmonth )*30 + $day - $oldday < $days_back ){
		$b=1;
	    }
	}
    }

    if( $b && ( $row[12] == 0 ) ){ #If less than 6 months since closed and ontology==0
      $stationf{$row[0]}{$row[13]}=1;

      if( not exists $station_counter{$row[0]}){
	$station_counter{$row[0]}=1;
      }else{ 
	$station_counter{$row[0]} ++;
      }
    }
  }

$sth->finish;

my %pstationid;

foreach my $stationid ( keys %station_counter ){
  if( $station_counter{$stationid}>1 ){
    my $maxtime='1500-01-01';
    foreach my $fromtime ( keys %{$stationf{$stationid}} ){
      if( greater_than($fromtime,$maxtime) ){
	$maxtime=$fromtime;
      }
    }
    $pstationid{$stationid}= $maxtime;
  }
}



$sth=$dbh->prepare("select * from station") or die "Can't prep\n";
$sth->execute;


while (my @row = $sth->fetchrow()) {   
    my $len=@row;
    my $b=0;

    if(!defined($row[14])){
      $b=1;       
    }else{
	#print "$row[0]\n";
	$row[14]= trim($row[14]);
	if(length($row[14]) == 0 ){
	    $b=1;
	}
	else{
	    my ( $oldyear, $oldmonth, $oldday )= getDate($row[14]);
            #print "$oldyear,$oldmonth,$oldday\n";

	    if( ( $year - $oldyear )*365 +  ( $month - $oldmonth )*30 + $day - $oldday < $days_back ){
		$b=1;
	    }
	}
    }

    if( $b && ( $row[12] == 0 ) ){ #If less than 6 months since closed and ontology==0
        my $call_sign;
	for( my $i=0; $i <$len; $i++ ){
	         if(!defined($row[$i])){
                     $row[$i]="\\N";
                 }

		 if($i == 9 ){
                    #print "call_sign=$row[9] length=",length($row[$i]), "\n";
		    $call_sign=$row[9];
		  }

	         $row[$i]= trim($row[$i]);
                 if(length($row[$i]) == 0 ){
		     $row[$i]="\\N";
                     if( $i == 9 ){
		        $call_sign= "\\N";
		     }
		 }

		 

	 }

	if( exists $stationid_fromtime{$row[0]}{$row[13]} ){
	  if  ( $stationid_fromtime{$row[0]}{$row[13]} == 0 ){
	    $row[6]="\\N";
	  }
	}

        if( exists $wmono_filter{$row[0]} ) {
	     $row[6]="\\N";
        }

  if ( exists $pstationid{$row[0]} ){
    if( $pstationid{$row[0]} ne $row[13] ){ next; }
  }
    
	
print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|$row[5]|$row[6]|$row[7]|$row[8]|$call_sign|$row[10]|$row[11]|t|$row[13]\n";
    }
  }

$sth->finish;

$dbh->disconnect;


sub greater_than{
  my $l=shift;
  my $r=shift;
  if((defined $l ) && (defined $r) ){
    if( $l eq $r ){
      return 0;
    }
    #my @sline=split /$splitter/,$line;
    #split  /\\s+/,$terminate
    if( $l gt  $r ){
      #print "$l gt  $r\n";
      return 1;
    }
  }

  return 0;
}
