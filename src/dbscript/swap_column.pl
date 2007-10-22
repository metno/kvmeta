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

my $fromfile=$ARGV[0];

#my $column = $ARGV[1];
#my $split =  $ARGV[2];

my $columnr1=0;
my  $columnr2=1;
my $splitter='\s+';
my $split=" ";

my $colmax=$columnr1;
if( $columnr2 > $columnr1 ){ $colmax= $columnr2; }
    

if( $columnr1 < 0 || $columnr2 < 0 ){ 
    print #error columnr er mindre eller lik 0"; exit 0;
}

my $line;
#print "split= "; print $split; print "\n";



open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";
while( defined($line=<MYFILE>) ){
    $line=trim($line);
    if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
            if($colmax < $len ){
            my $tmp = $sline[$columnr1];
            $sline[$columnr1] = $sline[$columnr2];
	    $sline[$columnr2]= $tmp;
	    my $i=0;
	    for( $i=0; $i<$len-1; $i++ ){
		print $sline[$i]; print $split;
	    }print $sline[$len-1]; print "\n";
	}else{
	    print "error ";
	}
	}
}


sub trim{
    my  $line = shift;
    if(defined($line)){
        $line =~ s/^\s*//; #Her utfores en ltrim
        $line =~ s/\s*$//; #Her utfores en rtrim
        return $line;
    }
    return "";
} 





