#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: dbQC1-1 4409 2013-04-16 21:40:44Z terjeer $
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
use DBI;
use dbQC;

my $kvpasswd=get_passwd();
my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs;host=localhost;port=5432',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
        die "Connect failed: $DBI::errstr";

my $sth = $dbh->prepare("select count(*) from station_param where paramid=? and level=?");

my $fromfile = station_param_name($ARGV[0]);
open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my $line;
my $splitter2=";";
while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*)\s*$/$1/;#Her utf?res en trim
      #last unless $line;

        if( length($line)>0 ){
            my @sline=split /$splitter2/,$line;
            my $len=@sline;

            my $paramid = trim($sline[0]);
            my $level = trim($sline[1]);
            my $min    = trim($sline[2]);
            my $max    = trim($sline[3]);
            $sth->execute($paramid,$level);
	    my @row = ();
	    my $count;
	    if ( @row = $sth->fetchrow_array ) {
		$count = $row[0];
	    }
	    $sth->finish;
	    if( $count == 0 ){
                my $qcx="QC1-1-$paramid";
                my $metadata= make_metadata( $max, $min );
		#print "INSERT INTO station_param VALUES(0,'$paramid','$level',0,1,366, -1,'$qcx',E'$metadata',NULL,'1500-01-01 00:00:00') \n";
		my $sth2 = $dbh->prepare(
		"INSERT INTO station_param VALUES(0,'$paramid','$level',0,1,366,\
                                                  -1,'$qcx',E'$metadata',NULL,'1500-01-01 00:00:00')"
                );
                $sth2->execute;
	    }
	                    
        }
}


sub make_metadata{
    my ($max, $min )=@_;
    my $highest=$max;
    my $high=$max;
    my $low=$min;
    my $lowest=$min;

    return "max;highest;high;low;lowest;min\\n$max;$highest;$high;$low;$lowest;$min";
}
