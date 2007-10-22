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


#
# oppdatering av tabellen station i Kvalobs, først på rime så på warm.
#Vi legger til EWGLAM-stasjoner (flere utenlandske stasjoner
#Øystein Lie, 19/11-2004.
# listen er hentet fra filen ewglam og putter direkte inn i station_tabellen.
use strict;
#use DBI;
#use Pg;


#my $conn = DBI->connect("dbi:Pg:dbname=kvalobs;host=warm.oslo.dnmi.no;port=5432",
#"kvalobs","*******") or die $DBI::errstr;




my $stationid;
my $wmo;
my $sth;


open(FILE, "ewglam") || die;

while (<FILE>) {
  $wmo=$_;
  chop($wmo);
  $stationid=$wmo*100;

print "$stationid|\\N|\\N|\\N|0|\\N|$wmo|\\N|\\N|\\N|\\N|\\N|'t'|'2004-11-22 12:00:00'\n";


 # $sth = $conn->prepare("INSERT INTO station (stationid,maxspeed,wmonr,static,fromtime) values ($stationid,0,$wmo,'t','2004-11-22 12:00:00')") || die "Feil ved prepinsert";

#$sth->execute || die "Feil ved execinsert";
       
}

close (FILE) || die;
#$conn->disconnect;




