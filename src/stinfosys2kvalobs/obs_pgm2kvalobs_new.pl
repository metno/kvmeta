#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: obs_pgm2kvalobs.pl 27 2007-10-22 16:21:15Z paule $
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
# use trim;

my $len=@ARGV;

if( $len == 0 ){
    print STDERR "scriptet krever ett argument som er et tall som er lik -2 eller større\n";
    exit 0;
}


    my $days_back=$ARGV[0];
    #my $days_back=365;

    my @tt=    gmtime(time);
    my $year=  1900 +  $tt[5];
    my $month= $tt[4] + 1;
    my $day=   $tt[3];
    #print "$year,$month,$day\n";


    my $stname=  st_name();
    my $sthost=  st_host();
    my $stport=  st_port();
    my $stuser=  st_user();
    my $stpasswd=st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";
my $sth;
my $sth2;

my %time_hash;

if( $days_back == -1 ){# fullstendig historisk med alle data 
   $sth=$dbh->prepare("select * from obs_pgm") or die "Can't prep\n";
   $sth2=$dbh->prepare("select * from obs_pgm where totime is not NULL") or die "Can't prep\n";
}elsif( $days_back == -2 ){# bare nåtid
   $sth=$dbh->prepare("select * from obs_pgm where totime is NULL") or die "Can't prep\n";
}else{# fullstendig historisk $days_back dager bakover
   $sth=$dbh->prepare("select * from obs_pgm where ( totime>=( now() - '$days_back days'::INTERVAL )  or totime is NULL)") or die "Can't prep\n";
   $sth2=$dbh->prepare("select * from obs_pgm where totime>=( now() - '$days_back days'::INTERVAL )") or die "Can't prep\n";
}


$sth->execute;

 my $week="t|t|t|t|t|t|t";
while (my @row = $sth->fetchrow()) {
    my $hour=$row[6];
    $hour =~ s/[\s{}]//g;
    #print "hour=$hour\n";
    my  @ahour=split /,/,$hour;
    my $outhour=join("|",@ahour);
    my $totime=$row[7];

    if( ! defined $totime ){
	#print "Totime IKKE DEFINERT \n";
	$totime="\\N";
    }

    #if($row[5] eq "t" or $row[5] eq "T" or $row[5]  eq = "1"

    $time_hash{"$row[0]|$row[1]|$row[2]|$row[8]$totime"}=1;
    print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|$row[5]|$outhour|$week|$row[8]|$totime\n";
}

$sth->finish;

if( $days_back > -2 ){
  $sth2->execute;
  while (my @row = $sth2->fetchrow()) {
     my $outhour="f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f|f";
     my $totime=$row[7];
	
     if( ! defined $totime ){
	#print "Totime IKKE DEFINERT \n";
	$totime="\\N";
     }


     if( ! exists  $time_hash{"$row[0]|$row[1]|$row[2]|$row[7]$totime"} ){
	     print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|f|$outhour|$week|$row[8]|$totime\n";	 
     }
  }
  $sth2->finish;
}

$dbh->disconnect;
