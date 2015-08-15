#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: QC1-1manual.pl 4409 2015-08-04 21:40:44Z terjeer $
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

use POSIX;
use strict;
use dbQC;

# CONST
my $QCX = "QC1-1";
my $hour=-1;
my $default_level = 0;
my $default_sensor = '0';

# get & fill
my $fromtime= get_fromtime();
my %m_param = fill_param();
my %m_station = fill_station();
my %m_obs_pgm = fill_obs_pgm();

my $log='>' . "/var/log/kvalobs/QC1-1manual.log";
open(LOG,$log) or die "Can't open $log: $!\n";
my $arrlen=@ARGV;
if( $arrlen == 0 ){
    print "This script needs at least one argument \n";
    print LOG "This script needs at least one argument \n";
    exit 1; 
}

my $spm_path=get_station_param_manual_path();
my $fromfile=$spm_path . "/QC1-1" . "/" . $ARGV[0];
#my $fromfile = station_param_name($ARGV[0]);
open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my $splitter="\\s+";
while( defined(my $line=<MYFILE>) ){
      $line=trim($line);
      
      if( length($line)>0 ){
	   # print $line . "\n";
	   my @sline=split /$splitter/,$line;
	   my $len=@sline;

           my $stationid = trim($sline[0]);
	   my $paramid = trim($sline[1]);
	   my $fromday = 1;
           my $today   = 366;
           my $sensor = $default_sensor;
           my $level;
           if( $len > 3 ){
		$level = trim($sline[3]);
           }else{
		$level = $default_level;
	   }
           my $metadata = "max;highest;high;low;lowest;min\\n".trim($sline[2]);
           my $desc_metadata = "\\N";
	    
          if( exists $m_param{"$paramid"} ){ 
	      #print $line . "\n";
              my $b=1;
              if( $stationid != 0 ){
		 if( exists $m_station{"$stationid"} ){ 
		    # print LOG "bs=$b \n";
                    if(! exists $m_obs_pgm{"$stationid,$paramid"} ){
			$b=0;
			print LOG "bo2=$b :: row in obs_pgm does not exist \n";
	            }
		 }else{
		    print LOG "bs2=$b :: stationid does not exist \n";
		    $b=0;
		 }   
              }
              # print "b=$b \n";
              if( $b ) {
                 print "$stationid|$paramid|$level|$sensor|$fromday|$today|$hour|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";

	      }
       
	  }else{
	      print LOG "bp=0 ::  paramid does not exist\n";
	  }
      }
}
  
