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
    print STDERR "scriptet krever ett argument som er et tall som er lik -2 eller stÃ¸rre\n";
    exit 0;
}
my $kvname="metno";
if( $len == 2 ){
    my $kvname=$ARGV[1];
}


    my $days_back=$ARGV[0];
    #my $days_back=365;

    my @tt=    gmtime(time);
    my $year=  1900 +  $tt[5];
    my $month= $tt[4] + 1;
    my $day=   $tt[3];
    #print "$year,$month,$day\n";


    my $stname= st_name();
    my $sthost= st_host();
    my $stport= st_port();
    my $stuser= st_user();
    my $stpasswd= st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";
my $sth;

my %NOT_METNO;
if( $kvname eq "metno" ){
    $sth=$dbh->prepare("select stationid,message_formatid,kvalobsid from message_in where kvalobsid != 1") or die "Can't prep\n"; 
    $sth->execute;
    while (my @row = $sth->fetchrow()) {
        $NOT_METNO{$row[0]}{$row[1]}=$row[2];
    }
}else{
   $sth=$dbh->prepare("select stationid,message_formatid,kvalobsid from message_in where kvalobsid=( select kvalobsid from kvalobs where name=$kvname");
   $sth->execute;
   while (my @row = $sth->fetchrow()) {
        $NOT_METNO{$row[0]}{$row[1]}=$row[2];
   }
}


my $base_sql="select stationid,paramid,hlevel,nsensor,message_formatid,priority_message,anytime,array_to_string(hour,'|'),totime,fromtime,edited_by,edited_at from obspgm_h";

if( $days_back == -1 ){# fullstendig historisk med alle data 
   $sth=$dbh->prepare("$base_sql") or die "Can't prep\n";
}elsif( $days_back == -2 ){# bare nåtid
   $sth=$dbh->prepare("$base_sql where totime is NULL") or die "Can't prep\n";
}else{# fullstendig historisk $days_back dager bakover
   $sth=$dbh->prepare("$base_sql where ( totime>=( now() - '$days_back days'::INTERVAL )  or totime is NULL)") or die "Can't prep\n";
}

$sth->execute;

my $week="t|t|t|t|t|t|t";

while (my @row = $sth->fetchrow()) {
    my $hour=$row[7];
    $hour =~ s/[\s{}]//g;
    #print "hour=$hour\n";
    my  @ahour=split /,/,$hour;
    my $outhour=join("|",@ahour);
    my $totime=$row[8];

    if( ! defined $totime ){
	#print "Totime IKKE DEFINERT \n";
	$totime="\\N";
    }
    if( $kvname eq "metno" ){
        if( not exists $NOT_METNO{$row[0]}{$row[4]} ){
            print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|$row[5]|$row[6]|$outhour|$week|$row[9]|$totime\n";
        }
    }else{
        if( exists $NOT_METNO{$row[0]}{$row[4]} ){
            print "$row[0]|$row[1]|$row[2]|$row[3]|$row[4]|$row[5]|$row[6]|$outhour|$week|$row[9]|$totime\n";
        }
    }
}

$sth->finish;
$dbh->disconnect;
