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



#qcx            : QC1-2-101


use POSIX;
use strict;
#use DBI;
use base_station_param;


my $control = "";

my $argn = @ARGV;
$control = $ARGV[0];


my $counter=0;

my $stationid = 0;
my $paramid;
my $level=0;
my $sensor='0';
my $fromday = 1;
my $today = 365;
my $qcx;
my $metadata;
my $desc_metadata="\\N";
my $fromtime= "2002-01-01 00:00:00+00";


  my $is_metadata=0;
     
  $paramid=$ARGV[1];                     
  $counter++;
  print "paramid=$paramid  counter= $counter";  print "\n";
   
  $qcx=$ARGV[2];
  $counter++;
  print "qcx=$qcx  counter= $counter";  print "\n";

  $metadata=$ARGV[3];
  $counter++;
  $metadata =~ s/_/;/g;
  print "metadata=$metadata  counter= $counter";  print "\n";
	
  my $metdata2 =  $ARGV[4];
  $metdata2 =~ s/_/;/g;
  $metadata .= "\\n" . $metdata2;
  print "metadata=$metadata  counter= $counter";  print "\n";

  execute_program();

sub execute_program{
  my $row= "$stationid~$paramid~$level~$sensor~$fromday~$today~$qcx~$metadata~$desc_metadata~$fromtime\n";
  print $row;

   insert_DB( $control, $stationid, $paramid, $level, $sensor, $fromday, $today, $qcx, $metadata, $desc_metadata, $fromtime );
}











