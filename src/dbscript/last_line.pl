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

#my $splitter="\\s+";
#my $splitter=";";

my $fromfile=$ARGV[0];

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

#?gmtime;
my $value='2002-01-01 00:00:00+00';

my $line;

while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*)\s*$/$1/;#Her utf?res en trim
      #last unless $line;

       if( length($line)>0 ){
           #my $rep='\x5C\x5C'.'N';
           #my $name="\\N";
           #$line =~ s/$rep/$name/g;
           #print "$line\n";
	   print "$line|$value\n";
       }
}







