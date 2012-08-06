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

#my $cols="stationid,lat,lon,countryid,municipid,hs,hv,hp,maxspeed,name,short_name,wmono,ontologyid,fromtime,totime,edited_by,edited_at";
my $cols="stationid,lat,lon,hs,maxspeed,name,wmono,fromtime";

if( scalar(@where_arr) == 0 ){
    $sth=$dbh->prepare("select $cols from station") or die "Can't prep\n";
}else{
    $sth=$dbh->prepare("select $cols from station where $where_clause") or die "Can't prep\n";
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
       push( @row_list, \@row );

       $stationf{$row[0]}{$row[7]}=1;

       if( not exists $station_counter{$row[0]}){
           $station_counter{$row[0]}=1;
       }else{
           $station_counter{$row[0]} ++;
       }
   }

$sth->finish;

my %network_station_icao=      fill_network_station($dbh, 101);
my %network_station_call_sign= fill_network_station($dbh, 6);


my %pstationid;

foreach my $stationid ( keys %station_counter ){
  if( $station_counter{$stationid} > 1 ){
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

   if( exists $stationid_fromtime{$row[0]}{$row[7]} ){
       if ( $stationid_fromtime{$row[0]}{$row[7]} == 0 ){
            $row[6]="\\N";
       }
   }

   if( exists $wmono_filter{$row[0]} ) {
       $row[6]="\\N";
   }

   if ( exists $pstationid{$row[0]} ){
       if( $pstationid{$row[0]} ne $row[7] ){ next; }
   }
 
   my $environmentid = get_environmentid( $dbh, $row[0] );

   my $icaoid = "\\N";
   if ( exists $network_station_icao{$row[0]} ){
        $icaoid = $network_station_icao{$row[0]};
	if( length($icaoid) > 4 ){ 
	    #my $len=length($icaoid);print "length = $len \n";
            $icaoid =~ s/'//g;
            #$len=length($icaoid); print "new length = $len \n";
	}
        while( length($icaoid) > 4 ){
            #my $len=length($icaoid);print "clength = $len \n"; 
            chop $icaoid;
            #$len=length($icaoid); print "new clength = $len \n";
        }
   }
   my $call_sign = "\\N";
   if ( exists $network_station_call_sign{$row[0]} ){
        $call_sign = $network_station_call_sign{$row[0]};
        if( length($call_sign) > 7 ){ 
	    #my $len=length($call_sign);print "length = $len \n";
            $call_sign =~ s/'//g;
            #$len=length($call_sign); print "new length = $len \n";
	}
        while( length($call_sign) > 7 ){
            #my $len=length($call_sign);print "clength = $len \n"; 
            chop $call_sign;
            #$len=length($call_sign); print "new clength = $len \n";
        }
   }
       
   print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|$row[5]|$row[6]|$row[0]|$icaoid|$call_sign|\\N|$environmentid|t|$row[7]\n";
}

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


sub get_environmentid {
  my ( $dbh, $stationid ) = @_;

  my $sth = $dbh->prepare(
   "select environmentid from  environment_station where  stationid=$stationid and fromtime = ( select max(fromtime) from environment_station where stationid=$stationid)"
   );
   $sth->execute;
    
   my $environmentid;
   if ( $environmentid = $sth->fetchrow_array ) {
    
   }else{
     $environmentid=0;   
   }

   $sth->finish;

  return $environmentid;
}


sub fill_network_station {
    my ( $dbh, $networkid ) = @_;
    my $sth;

    $sth = $dbh->prepare(
        "select stationid, external_stationcode from network_station where totime IS NULL and networkid=$networkid"
    );

    $sth->execute;
    my %s;

    while ( my @row = $sth->fetchrow_array ) {
        $s{"$row[0]"} = $row[1];
    }

    $sth->finish;

    return %s;
}
