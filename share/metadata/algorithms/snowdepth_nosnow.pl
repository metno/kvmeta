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


#checkname:	snowdepth_nosnow
#signature: obs;SA,V1,V2,V3,V4,V5,V6,V7;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
# Siva Navaratnam  Wed May 28 10:23:09 2003

sub check {
#tolererer ingen manglende observasjoner:
	my @V_param = ($V1[0],$V2[0],$V3[0],$V4[0],$V5[0],$V6[0],$V7[0]);
	my @V_data = (2,5,6,28,30); 
	my @retvector;
	if ($V1_missing[0] > 0 && $V2_missing[0] > 0 && $V3_missing[0] > 0 && $V4_missing[0] > 0
		 &&	$V5_missing[0] > 0 && $V6_missing[0] > 0 && $V7_missing[0] > 0 ) {
		# aborter..
		return 0;
	}
	if ($SA_missing[$#SA] > 0) {
		# aborter..
		return 0;
	}
	if ($SA_missing[0] > 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;
	my $snow = -1;

	if (($SA[0] != 0 && $SA[$#SA] == 0) || ($SA[0] > $SA[$#SA])) {
		$snow = 0;
		foreach my $V_P (@V_param) { 
    		foreach my $V_D (@V_data) {
    			if ($V_P == $V_D) {
    				$snow = 1;
    			}
    		}
		}
	}
	if ($snow == 0) {
		$flag = 3;
	}

	push(@retvector, "V1_0_0_flag", $flag, "V2_0_0_flag", $flag, "V3_0_0_flag", $flag, 
		"V4_0_0_flag", $flag, "V5_0_0_flag", $flag, "V6_0_0_flag", $flag, "V7_0_0_flag", $flag, );
	my $SAf_tidIndex = "SA_$#SA" . "_0_flag";
	push(@retvector, $SAf_tidIndex);
	push(@retvector, $flag);
	push(@retvector, "SA_0_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}

