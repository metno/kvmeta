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
use trim;
use dbQC;
use intodb;

my $narg=@ARGV;
print "narg= $narg\n";


my $fromfile;
if ( $narg>0){
  $fromfile=$ARGV[0];

}
my %new_station=();

my $kvpasswd=get_passwd();

my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";

my $line;
my $splitter='\|';

if ( $narg>0){
    open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

    while( defined($line=<MYFILE>) ){
      $line=trim($line);

      if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
	    #print "$sline[0] =  $len \n";
	    if( $len > 1 ){
		my $stationid = trim($sline[0]);
		$new_station{$stationid}=1;
		my $sth= $dbh->prepare("delete from station where stationid= $stationid");
		$sth->execute;
		$sth->finish;
	    }
	}
  }
}else{
    while( defined($line=<STDIN>) ){
      $line=trim($line);

      if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
	    #print "$sline[0] =  $len \n";
	    if( $len > 1 ){
		my $stationid = trim($sline[0]);
		$new_station{$stationid}=1;
		my $sth= $dbh->prepare("delete from station where stationid= $stationid");
		$sth->execute;
		$sth->finish;
	    }
	}
}
}


# Poenget er at en sletter de en har noe på i fila først, det som da er igjen er gamle stasjoner 
# som offisielt ikke eksisterer lenger
#

my @tt=gmtime();
my $year=1900 +  $tt[5];
my $month=  $tt[4] + 1;
my $outfilename= "old_stations." . $year . "-" . $month . "-" . $tt[3];
my $outfile= '>'.$outfilename;
open(MYFILEOUT,$outfile) or die "Can't open  $outfile: $!\n";
  #print "$outfilename \n";


my $sth=$dbh->prepare("select stationid from station where static=true") or die "Can't prep\n";
$sth->execute;

select(MYFILEOUT);
while (my @row = $sth->fetchrow()) {
    print "$row[0]\n";
}


$sth->finish;

#$sth=$dbh->prepare("\\copy station from $fromfile USING DELIMITERS '|'") or die "Can't prep\n";
#$sth->execute;
#$sth->finish;

$dbh->disconnect;

select(STDOUT);


dtodb( "station", $fromfile, '|' );
















