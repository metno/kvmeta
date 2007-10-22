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


#checkname:  PROGNOSTIC SPACE_CHECK_RR
#signature:  obs;X;;|model;mX;;|meta;X_1,X_2,X_3,X_4,X_dry;;

# PROGNOSTIC SPACE_CHECK OF PRECIPITATION
# Dry conditions added 27 May 2005 by Gabriel Kielland


sub check {

    my $flag = 1;

    if ( $X_missing[0] == 2 || $X_missing[0] == 3 ) {
       if ( $mX[0] < $X_dry[0] ) {
	    $X[0] = -1;
       }
       else {
	    $X[0] = $mX[0];
       }
       $flag = 6;
       $X_missing[0]-=2;
    }

    elsif ( $X_missing[0] < 2 ) {

	if ( ($X[0] - $mX[0]) >= $X_1[0] ) {
	    $flag = 4;
	}
	elsif ( ($X[0] - $mX[0]) < $X_1[0] && ($X[0] - $mX[0]) >= $X_2[0] ) {
	    $flag = 2;
	}
	elsif ( ($X[0] - $mX[0]) < $X_3[0] && ($X[0] - $mX[0]) >= $X_4[0] ) {
	    $flag = 3;
	}
	elsif ( ($X[0] - $mX[0]) < $X_4[0] ) {
	    $flag = 5;
	}
    }

    my @retvector = ("X_0_0_flag", $flag);
    push(@retvector, "X_0_0_corrected");
    push(@retvector, $X[0]);
    push(@retvector, "X_0_0_missing");
    push(@retvector, $X_missing[0]);
    my $numout = @retvector;

    return (@retvector, $numout);
}

