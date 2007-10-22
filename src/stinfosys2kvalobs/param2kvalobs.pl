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

    my $stname=  st_name();
    my $sthost=  st_host();
    my $stport=  st_port();
    my $stuser=  st_user();
    my $stpasswd=st_passwd();


 #print " $stname,$sthost,$stuser,$stpasswd\n";


my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Vi får ikke forbindelse med databasen";

my $sth=$dbh->prepare("select * from param") or die "Can't prep\n";
$sth->execute;

  

while (my @row = $sth->fetchrow()) {
    my $len=@row;
    for( my $i=0; $i <$len; $i++ ){
          if(!defined($row[$i])){
               $row[$i]="\\N";
          }

          $row[$i]= trim($row[$i]);
          if(length($row[$i]) == 0 ){
               $row[$i]="\\N";
          }
    }
   
      print "$row[0]|$row[1]|$row[2]|$row[4]|$row[5]|$row[8]\n";
  }

$sth->finish;

$dbh->disconnect;


