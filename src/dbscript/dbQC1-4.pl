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
# $paramid $stationid $month metadatakolonne1 ...metadatakolonneN


use POSIX;
use strict;
use intodb;
use logdbQC;
use dbQC;


my $QCX = $ARGV[2];
my $fromtime = get_fromtime();

my %m_station;
my %m_param;
my %m_obs_pgm;

my %meta_param;
my %meta_param_values;

my $arg       = $ARGV[0];
my $outfilename = $QCX.".out";


if( $arg eq "gen" || $arg eq "all" ){
my $splitter="\\s+";
my $line;


my $metadatafile = station_param_name($ARGV[1]);
open(METADATA,$metadatafile) or die "Can't open $metadatafile: $!\n";

while( defined($line=<METADATA>) ){
      $line=trim($line);   
      if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
	    my $len=@sline;
            if($len>1){
	      my $paramid = trim($sline[0]);
	      my $meta = trim($sline[1]);
	      $meta_param{$paramid}= $meta;
              if($len>2){
		my ( $pa,$me,@val )= @sline;
		$meta_param_values{$paramid}=\@val; 
	      }
	    }else{
	      $meta_param{"def"}=trim($sline[0]);
	   }
      }
    }
close(METADATA);

my $obj= new logdbQC;
my $fromfile=station_param_name($ARGV[2]);

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my $outfile= '>'.$outfilename;
open(MYFILEOUT,$outfile) or die "Can't open  $outfile: $!\n";
#print "$outfilename \n";



%m_station = fill_station();
%m_param   = fill_param();
%m_obs_pgm = fill_obs_pgm();


my %hfromday=fhfromday();
my %htoday=fhtoday();


my @aline=();




my %m_station_param;
while( defined($line=<MYFILE>) ){
      $line=trim($line);   
      if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
	    my $len=@sline;

	    my $stationid = trim($sline[1]);
	    $stationid = trim_lzero($stationid);
	    my $paramid = trim($sline[0]);
	    my $level = 0;
	    my $sensor = '0';
	    my $month = trim($sline[2]);
	    my $fromday = $hfromday{"$month"};
	    my $today   = $htoday{"$month"};
            my $hour = -1;
	    #print "$counter|$fromday|$today\n";
	    
	    $obj->not_auto( $stationid, $paramid, $month, \%m_param, \%m_station, \%m_obs_pgm, \%m_station_param );
  
	    #me sde min.err max.err
	    if( exists $m_param{"$paramid"} &&
               !exists $m_station_param{"$stationid,$paramid,$month"} ) {
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
		   $m_station_param{"$stationid,$paramid,$month"}=1;
		   #my $highest = trim($sline[3]);
		   #my $high = trim($sline[4]);
		   #my $low = trim($sline[5]);
		   #my $lowest = trim($sline[6]);
		   my $metadata = make_metadata(@sline);
		   my $desc_metadata = "\\N";
		   #put into database er en fremtidig mulighet

		   #print to file på et format som senere enkelt kan importeres
		   #i databasen, da må vi i tilfelle bruke tabseparert fil.
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
    fintodb( ".", "station_param", $outfilename, $QCX, '|' );
}


sub make_metadata{
    my ($p,$s,$m,@valmetadata) = @_;

    my $metadata_txt;
    my $valmetadata=join(";",@valmetadata);
    my $paramvalmetadata;
    if( exists $meta_param{$p} ){
      $metadata_txt=$meta_param{$p};
      my $valref=$meta_param_values{$p};
      my @val=@{$valref};
      $paramvalmetadata = join(";",@val);
      $valmetadata="$valmetadata;$paramvalmetadata";
    }else{
      $metadata_txt=$meta_param{"def"};
    }
    my $metadata =  "$metadata_txt\\n$valmetadata";

    return $metadata;
}

