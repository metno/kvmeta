#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: hp.pl 1 2010-04-16 16:21:15Z terjeer $
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
use st_time;
use Date::Calc qw( check_date check_time Delta_Days );

my $len=@ARGV;

if( $len == 0 ){
    print STDERR "scriptet krever minst ett argument som er et tall som er lik -2 eller større\n";
    exit 0;
}

my $null='\N';
my $max_stationid=99999;
my $Kvalobsintl=32;

if( $len > 1 ){
    $null=$ARGV[0];#måten null kan presenteres på
    if( $null eq  "N" ){
        $null = '\N';
    }elsif( $null eq "b" ){
        $null= "";
    } 
}

  my $days_back=$ARGV[0];

  my $stname=  st_name();
  my $sthost=  st_host();
  my $stport=  st_port();
  my $stuser=  st_user();
  my $stpasswd=st_passwd();

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";


my $product;
#my $home=$ENV{"HOME"};
#open(LOG,">$home/st_hp.log");
#print LOG "null=$null\n";

my $sth;

my $cmst_ref = make_cmst( );
$dbh->disconnect;
#######################################################################################################

sub make_cmst{
    my @where_arr;

if( $days_back == -1 ){;
}elsif( $days_back == -2 ){
    push( @where_arr,"totime is NULL" );
}else{
    push( @where_arr,"( totime>=( now() - '$days_back days'::INTERVAL )  or totime is NULL)");
}

    push(  @where_arr, "( stationid <= $max_stationid or stationid in ( select stationid from network_station where networkid=$Kvalobsintl ) )" );

    push(  @where_arr, "ontologyid=0" );
    push(  @where_arr, "hp is not NULL" );
    push(  @where_arr, "fromtime < now()" );

my $where_clause=join(" AND ",@where_arr);
my $cols="stationid,hp,fromtime,totime";

    my $sth=$dbh->prepare("select $cols from station where $where_clause order by $cols") or die "Can't prep\n";

    $sth->execute;

    my %mst;
    while (my @row = $sth->fetchrow()) {
        my $stationid=$row[0];  
        my $hp=$row[1]; 
        my $fromtime=$row[2];
        my $totime=$row[3];
        if (! defined $totime) {
           $totime=$null;
        }

	if (! defined $hp) {
           $hp=$null;
        }
        
	my $mid=$null;
        if( defined $hp and $hp ne $null and $hp ne "" ){
	   $mid=$hp;
        }

	if( exists $mst{$mid}{$stationid}{$fromtime} ){# this situation will never occure here
	   if( greater_than($totime,$mst{$mid}{$stationid}{$fromtime}) ) {# the largest totime shall be set
	       $mst{$mid}{$stationid}{$fromtime}=$totime;
	   }
	}else {
	    $mst{$mid}{$stationid}{$fromtime}=$totime;
	}

        

        #print "$mid :: $stationid :: $fromtime :: $totime \n";	
    }
    $sth->finish;
    

  my %cmst;
  foreach my $MF ( keys %mst ){
     # print LOG "MF=$MF \n";
     foreach my $stationid ( keys %{ $mst{$MF}} ) {
	my ($lfromtime,$rtotime);
	my $first=1;
        #print "HEI 0\n";
        foreach my $fromtime ( sort keys %{ $mst{$MF}{$stationid} } ) {
	    my $totime=$mst{$MF}{$stationid}{$fromtime};#$mst
            #print "HEI 1\n";
	    if( $first ){
	        $lfromtime=$fromtime;
		$rtotime=$totime; 
	        $first=0;
		#print "lfromtime=$lfromtime \n";
                #print "rtotime=$rtotime \n";
		              #if(  $stationid eq "46610" and $MF eq "308" ){print LOG "first=$lfromtime,$rtotime\n";}
	    }else {
		my $new_totime= lunion($lfromtime,$rtotime,$fromtime,$totime);
		if( $new_totime eq "-1" ){
		    $cmst{$MF}{$stationid}{$lfromtime}=$rtotime;
		    $lfromtime=$fromtime;
		    $rtotime=$totime;
		              #if(  $stationid eq "46610" and $MF eq "308" ){ print LOG "cmst-new=$lfromtime,$rtotime\n"; }
	        }else{
		    $rtotime=$new_totime;
		    #if(  $stationid eq "46610" and $MF eq "308" ){ print LOG "rt=$lfromtime,$rtotime\n";}
	        }
	    }
	 }
	                      #if(  $stationid eq "46610" and $MF eq "308" ){print LOG "cmst-last=$lfromtime,$rtotime\n";}
	 #print "lfromtime=$lfromtime \n";
         #print "rtotime=$rtotime \n";
	 $cmst{$MF}{$stationid}{$lfromtime}=$rtotime;
     }
  }
  return \%cmst;
}


sub lunion{
   my ($lfromtime,$rtotime,$fromtime,$totime)=@_;
   # print LOG "lll $lfromtime,$rtotime,$fromtime,$totime\n";

   # return greatest totime if matches
   # else return "-1"

   if( greaterDate_policy( $fromtime,$rtotime ) ){
       return "-1";
   }elsif( greater_than( $totime,$rtotime ) ){
       return $totime;
   }else {
       return $rtotime;
   }

}


sub greaterDate_policy{
  my $l=shift;
  my $r=shift;
  
  if( (defined $l ) && (defined $r) ){
     if( $r ne $null ) {
        if( $l eq $r ){
           return 0;
        }
        if( $l eq $null ){
            return 1;
        }

        my ($lyear,$lmonth,$lday)=getDate($l);
        my ($ryear,$rmonth,$rday)=getDate($r);      

        if( Delta_Days($ryear,$rmonth,$rday, $lyear,$lmonth,$lday) > 1 ){
           return 1;
        }   
     }
  }
  return 0;
}

my %cmst=%{$cmst_ref};
foreach my $MF ( sort keys %cmst ){
    foreach my $stationid ( sort keys %{ $cmst{$MF}} ) {
         # print LOG "#################################### stationid=$stationid MF=$MF\n";
         #if( not exists $org_station{$stationid} ) {
	    foreach my $fromtime ( sort keys %{ $cmst{$MF}{$stationid} } ) {
	        # print LOG "fromtime=$fromtime\n";
	        my $totime=$cmst{$MF}{$stationid}{$fromtime};#$cmst
                print_data($stationid,$MF,$fromtime,$totime);
	     }# end foreach my $fromtime
      }# end foreach my $stationid
}# end foreach my $MF


sub print_data{
    my ($stationid,$MF,$fromtime,$totime)=@_;

    my $hp=$MF;
    print "$stationid|$null|$null|$null|$null|hp|$hp|$fromtime|$totime\n";
}


sub get_date{
  my $timestamp=shift;
  if ($timestamp eq $null) {
      return $timestamp;
  }
  my @sline=split /\s+/, $timestamp;
  return $sline[0];
}


sub greater_than{
  my $l=shift;
  my $r=shift;
  if( (defined $l ) && (defined $r) ){
     if( $r ne $null ) {
        if( $l eq $null ){
	   return 1;
        }
        if( $l gt  $r ){
	   return 1;
        }
     }
  }
  return 0;
}


sub greater_than_equal{
  my $l=shift;
  my $r=shift;
  if( (defined $l ) && (defined $r) ){
     if( $r ne $null ) {
        if( $l eq $null ){
	   return 1;
        }
        if( $l ge  $r ){
	   return 1;
        }
     }
     if( ($r eq $null) and ($l eq $null) ){
       return 1;
     }
  }
  return 0;
}

# close(LOG);

