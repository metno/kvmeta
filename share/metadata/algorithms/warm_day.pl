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


# checkname : warm_day
# signature : obs;TA,TAX;;|meta;R1,R2,R3;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
# Siva Navaratnam  Fri May 27 13:42:32 2003

sub check {
#tolererer ingen manglende observasjoner:
	my $AtLeastOne = 0; 
	foreach my $missing (@TA_missing) {
		if ($missing == 0) {
			$AtLeastOne++;
		}
	}

	if($AtLeastOne == 0) {
		# aborter..
		return 0;
	}
	if ($TAX_missing[0] > 0) {
		# aborter..
		return 0;
	}
	my $index = 0;
	for my $i ( 0 .. $#TA ) {
		if ($TA[$index] < $TA[$i]) {
			$index = $i;
		}
	}
	my $flag = 1;
	
	if ((($TAX[0] < $R1[0]) && ($TAX[0] > $TA[$index] + $R2[0])) || (($TAX[0] >= $R1[0]) && ($TAX[0] > $TA[$index] + $R3[0]))) {
		$flag = 3;
	}

	my @retvector;
	my $TA_tidIndex = "TA_$index" . "_0_flag";

	push(@retvector, $TA_tidIndex);
	push(@retvector, $flag);
	push(@retvector, "TAX_0_0_flag");
	push(@retvector, $flag);
	my $numout= @retvector; # antall returverdier

	return (@retvector, $numout);
}