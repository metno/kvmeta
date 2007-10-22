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


#checkname:  PROGNOSTIC SPACE_CHECK_PP
#signature:  obs;X,Y;;|model;mX;;|meta;X_1,X_2,X_3,X_4;;

# PROGNOSTIC SPACE_CHECK_PP

sub check {

    my $flag1 = 1;
    my $flag2 = 1;

    if ( $X_missing[0] == 2 || $X_missing[0] == 3 ) {
       $X[0] = abs($mX[0]);
       $flag1 = 6;
       $X_missing[0]-=2;
    }

    elsif ( $X_missing[0] < 2 ) {

	if ( ($X[0] - abs($mX[0])) >= $X_1[0] ) {
	    $flag1 = 4;
	}
	elsif ( ($X[0] - abs($mX[0])) < $X_1[0] && ($X[0] - abs($mX[0])) >= $X_2[0] ) {
	    $flag1 = 2;
	}
	elsif ( ($X[0] - abs($mX[0])) < $X_3[0] && ($X[0] - abs($mX[0])) >= $X_4[0] ) {
	    $flag1 = 3;
	}
	elsif ( ($X[0] - $mX[0]) < $X_4[0] ) {
	    $flag1 = 5;
	}
    }

    if ( $Y_missing[0] == 2 || $Y_missing[0] == 3 ) {
	if ( ($mX[0] - $mX[1]) > 0 ) {
	    $Y[0] = 2;
	}
	elsif ( ($mX[0] - $mX[1]) == 0 ) {
	    $Y[0] = 4;
	}
	if ( ($mX[0] - $mX[1]) < 0 ) {
	    $Y[0] = 7;
	}
	$flag2 = 6;
	$Y_missing[0] -= 2;
    }
    my @retvector = ("X_0_0_flag", $flag1);
    push(@retvector, "X_0_0_corrected");
    push(@retvector, $X[0]);
    push(@retvector, "X_0_0_missing");
    push(@retvector, $X_missing[0]);
    push(@retvector, "Y_0_0_flag");
    push(@retvector, $flag2);
    push(@retvector, "Y_0_0_corrected");
    push(@retvector, $Y[0]);
    push(@retvector, "Y_0_0_missing");
    push(@retvector, $Y_missing[0]);
    my $numout = @retvector;

    return (@retvector, $numout);
}


