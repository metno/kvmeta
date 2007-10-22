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


#checkname:		RANGE_CHECK
#signature:		obs;X;;|meta;X_1,X_2,X_3,X_4,X_5,X_6;;
# Grenseverdikontroll
# gjør noen tester og returner en ny verdi for flag

sub check {
#tolererer ingen manglende observasjoner:
   if ( $X_missing[0] > 0 ) {
      return 0;
    }

    my $flag = 1;

    if ( $X[0] < $X_6[0] || $X[0] > $X_1[0] ) {
        $flag = 6;
        $X_missing[0] = 2;
    }
    elsif ( $X[0] <= $X_1[0] && $X[0] > $X_2[0] ) {
        $flag = 4;
    }
    elsif ( $X[0] <= $X_2[0] && $X[0] > $X_3[0] ) {
        $flag = 2;
    }
    elsif ( $X[0] < $X_4[0] && $X[0] >= $X_5[0] ) {
        $flag = 3;
    }
    elsif ( $X[0] < $X_5[0] && $X[0] >= $X_6[0] ) {
        $flag = 5;
    }
    
    my @retvector;
    push(@retvector,"X_0_0_flag");
    push(@retvector,$flag);

    if ( $X_missing[0] > 0 ) {
       push(@retvector,"X_0_0_missing");
       push(@retvector,$X_missing[0]);
   }

    my $numout = @retvector;

    return (@retvector, $numout);
}
