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



use POSIX;
use strict;
use dbQC;


# Denne er litt rar, hvorfor tester vi i forhold til m_station_klima?
# og ikke bare i forhold til stasjoner i kvalobs.

my $splitter="\\s+";

my $fromfile = $ARGV[0];
my $paramsetid = $ARGV[1];

my $control="";
my $argn = @ARGV;
if( $argn>2){
    $control="D";
}

my %m_station_test = fill_station_test();
my %m_station_klima = fill_station_klima();

#print "paramid=$paramid \n";

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my $line;
#my $count=0;
while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*)\s*$/$1/;#Her utfores en trim

    if( length($line)>0 ){
	my @sline=split /$splitter/,$line;
	my $len=@sline;

        my $stationid = trim($sline[0]);
        my $reference;
        for( my $i=1; $i<$len - 1; $i++ ){
	    my $ref=trim($sline[$i]);
	    if( exists $m_station_klima{$ref} ){
		$ref = $m_station_klima{$ref};
		if( $control eq "D" ){
		    print $m_station_test{$ref};
		}
	    }
	    $reference .= $ref.","; 
	}   $reference .= trim($sline[$len - 1]);
   
	if( $control ne "D" ){
	    print "$stationid|$paramsetid|$reference\n";
	}
    }
    #$count++;
    #if($count>10){last;}
}


sub fill_station_klima{
   use DBI;

   #my @driver_names = DBI->available_drivers;
   #print @driver_names;

   my $kvpasswd=get_passwd();
   my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
        die "Connect failed: $DBI::errstr";

    my $sth = $dbh->prepare('select stationid, klima from stationid_klima where klima IS NOT NULL');

    $sth->execute;

    my @row;
    my %station_klima;

    while (@row = $sth->fetchrow_array) {
        $station_klima{"$row[1]"}=$row[0];
	
    }

    $sth->finish;
    $dbh->disconnect;

    return %station_klima;
}


sub fill_station_test{
    use DBI;

  #my @driver_names = DBI->available_drivers;
  #print @driver_names;

    my $kvpasswd=get_passwd();
    my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
	die "Connect failed: $DBI::errstr";

    my $sth = $dbh->prepare('select stationid, name, wmonr from station');

    $sth->execute;

    my @row;
    my %station;

    while (@row = $sth->fetchrow_array) {
        my $row1=1;
        my $row2=2;
        if(defined($row[1])){
	    $row1=$row[1];
	}
	if(defined($row[2])){
	    $row2=$row[2];
        }  
	$station{"$row[0]"}="name: $row1; wmonr: $row2";
    }

    $sth->finish;
    $dbh->disconnect;

    return %station;
}












