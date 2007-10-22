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


#checkname:		difflowclouds
#signature:		obs;X1,X2,X3,X4;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag

sub check {
#tolererer ingen manglende observasjoner:
	if ($X1_missing[0] > 0) {
		# aborter..
		return 0;
	}

	if ($X2_missing[0] > 0) {
		# aborter..
		return 0;
	}

	if ($X3_missing[0] > 0) {
		# aborter..
		return 0;
	}

	if ($X4_missing[0] > 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;

	if ($X1[0]>0 && $X2[0]<$X3[0] && $X4[0]>=6) {
		$flag= 3;
	}

	my @retvector;
	push(@retvector, "X1_0_0_flag");
	push(@retvector, $flag);
	my $numout= @retvector; # antall returverdier

	return (@retvector, $numout);
}
