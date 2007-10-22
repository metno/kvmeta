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


# QC2d-4 er testen dette gjelder for
# formatet paa filen QC2d-4 er folgende:
# $stationid $month  'kolonner med metadata'

#scriptet brukes slik:
#perl dbQC2d-4.pl $paramid $metafile $fromfile
#perl dbQC2d-4.pl 262 QC2d-4-262metadata QC2d-4-262


use POSIX;
use strict;
use intodb;
use dbQC;
use logdbQC;


my $QCX = "QC2d-4";
my $fromtime = get_fromtime();

my $arg       = $ARGV[0];
my $outfilename= $QCX.".out";


if( $arg eq "gen" || $arg eq "all" ){   
my $obj= new logdbQC;

my $splitter="\\s+";

my $paramid  = $ARGV[1];
my $metafile = station_param_name($ARGV[2]);
my $fromfile = station_param_name($ARGV[3]);


my %m_station;
%m_station = fill_station();
my %m_param;
%m_param = fill_param();
my %m_obs_pgm;
%m_obs_pgm = fill_obs_pgm();

my $line;

open(MYFILE,$metafile) or die "Can't open $metafile: $!\n";

my  @list_metadata;
while( defined($line=<MYFILE>) ){
        trim($line);

	if( length($line)>0 ){
	    @list_metadata=split /$splitter/,$line;
	    last;
	}
}

close(MYFILE);


my $string_metadata="";
foreach ( @list_metadata ){
       $string_metadata .= $_ . ";";
} chop $string_metadata;


my %hfromday=fhfromday();
my %htoday=fhtoday();


my $outfile= '>'.$outfilename;
open(MYFILEOUT,$outfile) or die "Can't open  $outfile: $!\n";
  #print "$outfilename \n";


open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";
my %m_station_param=();
while( defined($line=<MYFILE>) ){
        $line = trim($line);

	if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
            my $len=@sline;
	    
	    my $stationid = trim($sline[0]);
            $stationid = trim_lzero($stationid);
            my $level = 0;
	    my $sensor =  '0';
	    my $month = trim($sline[1]);
	    my $fromday = $hfromday{"$month"};;
	    my $today = $htoday{"$month"};
            my $hour = -1;

	    $obj->not_auto( $stationid, $paramid, $month, \%m_param, \%m_station, \%m_obs_pgm, \%m_station_param );
	   

	    if( exists $m_param{"$paramid"} &&
               !exists $m_station_param{"$stationid,$paramid,$month"} ) {
               my $b=1;
	       
               if( $stationid != 0 ){
                   if( exists $m_station{"$stationid"} ){ 
                       if(!exists $m_obs_pgm{"$stationid,$paramid"} ){
                           $b=0;
			   #print $stationid; print ":obs_pgm not exist \n";
                       }
                   }else{
		       #print $stationid; print ":stationid not exist \n";
                       $b=0;
                   }
               }
               if( $b ) {
                   $m_station_param{"$stationid,$paramid,$month"}=1;

		   my $meta;
		   my $len_list_metadata = @list_metadata;
		   my $i;
		   for( $i=2; $i<($len_list_metadata + 2); $i++ ){
		       $meta .= trim($sline[$i]) . ";";
		   }chop $meta;
	       
		   my $metadata = $string_metadata . "\\n" . $meta;
		  
		   my $desc_metadata = "\\N";
		   
		   select(MYFILEOUT);
		   print "$stationid|$paramid|$level|$sensor|$fromday|$today|$hour|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";
	       }
	   }
	}
    }
 
  $obj->print_log($QCX);
}




if( $arg eq "ins" || $arg eq "all" ){
    select(STDOUT);
    fintodb( ".","station_param", $outfilename, $QCX, '|' );
}














