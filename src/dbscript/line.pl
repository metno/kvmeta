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


# folgende:
# 'kolonner først'  'plass for å sette inn nye kolonner'  'kolonner sist'

use POSIX;
use strict;
use DBI;

my $place =2;
my @new_col=(0,1);
my $len_new_col=@new_col;


my $splitter='\|';

my $fromfile = $ARGV[0];
my $line;

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";
while( defined($line=<MYFILE>) ){
        $line = trim($line);

	if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
	    
	    splice(@sline,$place,0,@new_col);
	    my $len=@sline;
		   my $i;
	           

	    for( $i=0; $i<$len -1; $i++ ){
		 print trim($sline[$i]) . "|";
	    }print trim($sline[$len -1]);
	    print "\n";
	       
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


sub trim_lzero{
    my  $line = shift;
    if(defined($line)){
	if( length($line) > 0 ){
	    $line =~ s/^0*//; #Her utfores en ltrim
	    if(length($line) == 0){
		return 0;
	    }
	    return $line;
	}
    }
    return "";
} 















