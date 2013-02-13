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


# QC1-4 er testen dette gjelder for
# formatet på filen er følgende:
# $stationid $paramid $month highest high low lowest
                                             
use POSIX;
use strict;
use dbQC;

my $fromtime='2002-01-01 00:00:00+00';

my $fromfile=$ARGV[0];
my $arg2 = "QC1-4"; # $ARGV[1];

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my %m_station;
%m_station = fill_station();
my %m_param;
%m_param = fill_param();
my %m_obs_pgm;
%m_obs_pgm = fill_obs_pgm();

my %param_zero;

my $auto=0;


my %hfromday;
$hfromday{"1"}=1;
$hfromday{"2"}=32;
$hfromday{"3"}=60;
$hfromday{"4"}=91;
$hfromday{"5"}=121;
$hfromday{"6"}=152;
$hfromday{"7"}=182;
$hfromday{"8"}=213;
$hfromday{"9"}=244;
$hfromday{"10"}=274;
$hfromday{"11"}=305;
$hfromday{"12"}=335;

my %htoday;
$htoday{"1"}=31;
$htoday{"2"}=59;
$htoday{"3"}=90;
$htoday{"4"}=120;
$htoday{"5"}=151;
$htoday{"6"}=181;
$htoday{"7"}=212;
$htoday{"8"}=243;
$htoday{"9"}=273;
$htoday{"10"}=304;
$htoday{"11"}=334;
$htoday{"12"}=366;

my @aline=();
my $line;

my $splitter="\\s+";
my %station_param;
while( defined($line=<MYFILE>) ){
      trim($line);   
      if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
	    my $len=@sline;

	    my $stationid = trim($sline[0]);
	    $stationid = trim_lzero($stationid);
	    my $paramid = trim($sline[1]);
	    my $level = 0;
	    my $sensor = '0';
	    my $month = trim($sline[2]);
	    my $fromday = $hfromday{"$month"};
	    my $today   = $htoday{"$month"};
            my $hour = -1;
	    #print "$counter|$fromday|$today\n";
	    my $QCX = $arg2;
	    #me sde min.err max.err
            if(! $auto){
            
    #print "stationid=$stationid paramid=$paramid month=$month \n";
            if( !exists $m_param{"$paramid"} ) {print "NOT EXISTS paramid=$paramid\n";}
            else{
                if( $stationid==0){
                    #print "STATIONID paramid=$paramid\n ";
                    if( !exists $param_zero{$paramid} ){
                         $param_zero{$paramid}=1;
                    }else{
                       if( $param_zero{$paramid} != 1 ){
                           $param_zero{$paramid} = 3;
                       }
                    }
                }else{
                    if( !exists $m_station{"$stationid"} ){
                        print "NOT EXISTS stationid=$stationid paramid=$paramid\n ";
                    }else{                      
                        if( !exists $param_zero{$paramid} ){
                             $param_zero{$paramid}=2;
                        }else{
                             if( $param_zero{$paramid} == 1 ){
                                 $param_zero{$paramid} = 3;
                             }
                        }
                
                        if( !exists  $m_obs_pgm{"$stationid,$paramid"} ){
                            print "NOT EXISTS m_obs_pgm: $stationid,$paramid \n";   
                        }
                    }
                }
            }

                if( exists $station_param{"$stationid,$paramid,$month"} ){
                    print "DUPLIKATE rader: stationid=$stationid paramid=$paramid month=$month\n";
                }
            }#end if(!$auto)


	    if( exists $m_param{"$paramid"} &&
               !exists $station_param{"$stationid,$paramid,$month"} ) {
               my $b=1;
               if( $stationid != 0 ){
		   if( exists $m_station{"$stationid"} ){ 
		       if(!exists $m_obs_pgm{"$stationid,$paramid"} ){
			   $b=0;
		       }
		   }else{
		       $b=0;
		   }
	       }
               if( $b ) {
		   $station_param{"$stationid,$paramid,$month"}=1;
		   my $highest = trim($sline[3]);
		   my $high = trim($sline[4]);
		   my $low = trim($sline[5]);
		   my $lowest = trim($sline[6]);
		   my $metadata = make_metadata($highest,$high,$low,$lowest);
		   my $desc_metadata = "\\N";
		   #put into database er en fremtidig mulighet

		   #print to file på et format som senere enkelt kan importeres
		   #i databasen, da må vi i tilfelle bruke tabseparert fil.
		   print "$stationid|$paramid|$level|$sensor|$fromday|$today|$hour|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n"; 
	       }    
           } 
       }
  }


sub make_metadata{
    my ($highest,$high,$low,$lowest) = @_;
    my $metadata =  "highest;high;low;lowest\\n$highest;$high;$low;$lowest";
    return $metadata;
}



















