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


#checkname:	calm_waves
#signature: obs;FF,HWA,HW;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
# Siva Navaratnam  Wed Jun 11 11:28:27 2003

sub check {
#tolererer ingen manglende observasjoner:
	if ($obs_missing > 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;

	if ($FF[0] <= 3 && ($HWA[0] > 9.7 || $HW[0] > 9.7)) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "FF_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "HWA_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "HW_0_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
