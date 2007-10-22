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


#checkname:  combiseverity
#signature:  obs;X;;

sub check {
  if ( $X_missing[0] > 0 ) {
    return 0;
  }
  my $flag = 1;

  if ( $X_controlinfo[1] == 4 ) {
     if ( $X_controlinfo[3] == 2 ) {
	if ( $X_controlinfo[4] == 4 ) {
	   $flag = 11;
           $X_missing[0] = 2;
        }
	else {
	   $flag = 10;
           $X_missing[0] = 2;
	}
     }
     else {
	if ( $X_controlinfo[4] == 4 ) {
	$flag = 9;
        $X_missing[0] = 2;
	}
	else {
	   $flag = 2;
	}
     }
  }

  if ( $X_controlinfo[1] == 5 ) {
     if ( $X_controlinfo[3] == 2 ) {
	if ( $X_controlinfo[4] == 5 ) {
	   $flag = 11;
           $X_missing[0] = 2;
        }
	else {
	   $flag = 10;
           $X_missing[0] = 2;
	}
     }
     else {
	if ( $X_controlinfo[4] == 5 ) {
	$flag = 9;
        $X_missing[0] = 2;
	}
	else {
	   $flag = 2;
	}
     }
  }

  my @retvector = ("X_0_0_flag",$flag);

  if ( $X_missing[0] > 0 ) {
       push(@retvector,"X_0_0_missing");
       push(@retvector,$X_missing[0]);
  }

  my $numout = @retvector;
  return (@retvector,$numout);
}
