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

my $nargv= @ARGV;
my %exists_many_wmo;
my %station_wmo;

if ( $nargv > 0 ){
  my $fromfile= $ARGV[0];

  my %many_wmo;

my $splitter='\|';
open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";
my $line;
while( defined($line=<MYFILE>) ){
      $line=trim($line);

      if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
	    if($len > 2 ){
	      my $stationid=trim($sline[0]);
	      my $wmonr=trim($sline[6]);
	      my $fromtime=$sline[13];
              my $terminated=$sline[14];
	      if( defined $wmonr && $wmonr != "\\N" ) {
		print "$stationid, $fromtime har wmonr:$wmonr\n";
		$station_wmo{$wmonr}{$stationid}{$fromtime}=$terminated;
		
		if( exists $many_wmo{$wmonr} ){
		   print "MANGE EKSISTERER $stationid, $fromtime, wmonr:$wmonr\n";
		   $many_wmo{$wmonr}++;
		   $exists_many_wmo{$wmonr}=$many_wmo{$wmonr};
		}else{
		  $many_wmo{$wmonr}=1;
		}
	      }else{
		print "$stationid, $fromtime\n";
	      }
	    }
       }

}
close (MYFILE);


foreach my $wmonr ( keys %many_wmo ){
  if( $many_wmo{$wmonr} > 1 ){
    print "mange eksisterer: $many_wmo{$wmonr} \n";
  }else{
    print "en \n";
  }
}



my %stationid_fromtime;


foreach my $wmonr ( keys %exists_many_wmo ){
   print "eksisterer: $exists_many_wmo{$wmonr} \n";
   my $newesttime="1500-01-01";
   my $neweststationid;
   my $newestfromtime;
   foreach my $stationid ( keys %{$station_wmo{$wmonr}} ){
     #print "$wmonr,$stationid:\n";
     foreach my $fromtime ( keys %{$station_wmo{$wmonr}{$stationid}} ){
        print "  $wmonr,$stationid,$fromtime :  $station_wmo{$wmonr}{$stationid}{$fromtime}\n";
        my $terminated= $station_wmo{$wmonr}{$stationid}{$fromtime};
        if ( greater_than ($terminated, $newesttime )){
	  $newesttime    = $terminated;
	  $neweststationid = $stationid;
	  $newestfromtime= $fromtime;
	}
        if(  $station_wmo{$wmonr}{$stationid}{$fromtime}=="\\N" ){
	  $stationid_fromtime{$stationid}{$fromtime}=1;
	}else{
	 $stationid_fromtime{$stationid}{$fromtime}=0; 
	}
     }
   }
   $stationid_fromtime{$neweststationid}{$newestfromtime}=1;
 }





sub greater_than{
  my $terminated=shift;
  my $newesttime=shift;
  if( $terminated eq $newesttime ){
    return 0;
  }
  #my @sline=split /$splitter/,$line;
  #split  /\\s+/,$terminate
  if( $terminated gt  $newesttime ){
    print "$terminated gt  $newesttime\n";
    return 1;
  }

  return 0;

}
