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


#checkname:  FREEZE_CHECK
#signature:  obs;X;;|meta;X_NO;;

sub check {

    my $i;
    if ($obs_numtimes < $X_NO[0] ) {
	return 0;
    }
    for ( $i = 0; $i < $X_NO[0]; $i++ ) {
	if ( $X_missing[$i] > 0 ) {
	    return 0;
	}
    }

    my $flag = 1;

    my $eps = 0.001;
    my $diff = 0;

    for ( $i = 0; $i < $X_NO[0]; $i++ ) {
        if ( abs($X[$i] - $X[$i+1]) > $eps ) {
            $diff = 1;
        }
    }
    if ( !$diff ) {
        $flag = 3;
    }

    my @retvector = ("X_0_0_flag",$flag);

    my $numout = @retvector;

    return (@retvector, $numout);
}
