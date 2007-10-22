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
use stinfosys;
use trim;
use wmonr_stinfosys2kvalobs;

my $len=@ARGV;

if( $len == 0 ){
    print STDERR "scriptet krever minst ett argument som er et tall som er lik -2 eller større\n";
    exit 0;
}


my $defdump=0;
my $null="none";
my $max_stationid=99999;
my $Kvalobsintl=32;

my %stationf;
my %station_counter;


if( $len > 1 ){
    $null=$ARGV[1];#måten null kan presenteres på
    if( $null eq  "N" ){
        $null = '\N';
    }elsif( $null eq "b" ){
	$null= "";
    } 
}


    my $days_back=$ARGV[0];
    #my $days_back=365;

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

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";
my $sth;
my $sth2;

my %time_hash;

my @where_arr;


if( $days_back == -1 ){;
}elsif( $days_back == -2 ){
    push( @where_arr,"totime is NULL" );
}else{
    push( @where_arr,"( totime>=( now() - '$days_back days'::INTERVAL )  or totime is NULL)");
}

#if( $Kvalobs-intl ){
    push(  @where_arr, "( stationid <= $max_stationid or stationid in ( select stationid from network_station where networkid=$Kvalobsintl ) )" );
#}

    push(  @where_arr, "ontologyid=0" );

my $where_clause=join(" AND ",@where_arr);

#print "$where_clause\n";



if( scalar(@where_arr) == 0 ){
    $sth=$dbh->prepare("select * from station") or die "Can't prep\n";
}else{
    $sth=$dbh->prepare("select * from station where $where_clause") or die "Can't prep\n";
}

$sth->execute;

my @row_list;
   while (my @row = $sth->fetchrow()) {
       my $len=@row;
       for( my $i=0; $i <$len; $i++ ){
	   if(!defined($row[$i])){
                     $row[$i]="\\N";
           }

           $row[$i]= trim($row[$i]);
           if( length($row[$i]) == 0 ){
               $row[$i]="\\N"; 
           } 
       }
       #print "$row[0]|$row[1]|$row[2]|$row[5]|$row[8]|$row[9]|$row[11]|$row[0]|$row[12]|$row[13]|\N|$row[14]|$t|$row[16]\n";
       push( @row_list, \@row );

       $stationf{$row[0]}{$row[16]}=1;

       if( not exists $station_counter{$row[0]}){
           $station_counter{$row[0]}=1;
       }else{
           $station_counter{$row[0]} ++;
       }
   }


$sth->finish;
$dbh->disconnect;

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


foreach my $ref_row ( @row_list ){
   my @row=@{$ref_row};
   my $len=@row;

   if( exists $stationid_fromtime{$row[0]}{$row[16]} ){
       if ( $stationid_fromtime{$row[0]}{$row[16]} == 0 ){
            $row[11]="\\N";
       }
   }

   if( exists $wmono_filter{$row[0]} ) {
       $row[11]="\\N";
   }

   if ( exists $pstationid{$row[0]} ){
       if( $pstationid{$row[0]} ne $row[16] ){ next; }
   }

   print "$row[0]|$row[1]|$row[2]|$row[5]|$row[8]|$row[9]|$row[11]|$row[0]|$row[12]|$row[13]|\\N|$row[14]|t|$row[16]\n";

}

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
