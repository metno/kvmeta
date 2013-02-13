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


# QC1-1 er testen dette gjelder for
# formatet paa filen rangeLimits_QC1-1 er folgende:
# stationid paramid høyeste høy lav laveste
# $stationid $paramid highest high low lowest
# i tillegg saa er maanedene i sykler paa 12 rader nedover, der en rad representerer en maaned.
# Det vil si de 12 
# forste radene representerer tiden maanedsvis for 12 maaneder der
# den forste raden er maaned 1(januar), neste rad er maaned 2(februar) osv. 
# Deretter saa representerer de 12 neste radene 12 maaneder, slik fortsetter det i grupper paa
# 12 og 12 rader nedover filen rangeLimits_QC1-1.
# 
# $## betyr en kolonne vi kan se bort i fra
# QCX=QC1-1
# time=roling // den kan ogsaa vaere month eller 0 eller fromto
# splitter="\\s+"
# $stationid $paramid highest high low lowest
                                             
use POSIX;
use strict;
use dbQC;  

my $fromtime='2002-01-01 00:00:00+00';

my $fromfile=$ARGV[0];

my $arg2="QC1-1";

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my %m_station;
my %m_param;
%m_station = fill_station();
%m_param = fill_param();

my $auto=1;

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

#my $line_counter=0;

my $counter=0;
my $line;
my $splitter="\\s+";
my %station_param;

while( defined($line=<MYFILE>) ){
      $line =~ s/^\s*(.*)\s*$/$1/;#Her utføres en trim
      
      if( length($line)>0 ){
            if( $counter == 12 ){
	      $counter=1;
            }else{$counter++}

	    my @sline=split /$splitter/,$line;
	    my $len=@sline;
            my $stationid = trim($sline[0]);
	    my $paramid = trim($sline[1]);
	    my $fromday = $hfromday{"$counter"};
            my $today   = $htoday{"$counter"};
	    my $level = 0;
	    my $sensor = '0';
	    my $QCX = $arg2;

	    if(!$auto){
                if( !exists $m_station{"$stationid"} ) {print "NOT EXISTS stationid=$stationid\n";}
                if( !exists $m_param{"$paramid"} ) {print "NOT EXISTS paramid=$paramid\n";}
		if( exists $station_param{"$stationid,$paramid,$counter"} ){ 
                    print "DUPLIKATE rader: stationid=$stationid paramid=$paramid month=$counter\n";
                } 
            }
	    if($auto && exists $m_station{"$stationid"} && exists $m_param{"$paramid"} &&
	       !exists $station_param{"$stationid,$paramid,$counter"} ) {
		  $station_param{"$stationid,$paramid,$counter"}=1;
                  my $highest = trim($sline[2]);
                  my $high = trim($sline[3]);
                  my $low = trim($sline[4]);
                  my $lowest = trim($sline[5]);
                  my $desc_metadata = "\\N";          
		  my $metadata = "highest;high;low;lowest\\n$highest;$high;$low;$lowest";
		  print "$stationid|$paramid|$level|$sensor|$fromday|$today|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";
	          #$line_counter++;
	    }
	}
  }

#print $line_counter;




















