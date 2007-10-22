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


#checkname:		tendency
#signature:		obs;pp,P;;-180
# Konsistenskontroll_Check
# kontrollerer at trykktenden samsvarer med forskjellen i trykkverdiene
# Gabriel Kielland Wed Dec 01 12:45:00 2004

sub check {
#tolererer ingen manglende observasjoner:
	if ($pp_missing[0] > 0 || $P_missing[0] > 0) {
		return 0;
	}

	my $flag = 1;
	my $i=0;
        my $Pprev;
	my $previndex;
	while ($i < $obs_numtimes) {
		if ($obs_timeoffset[$i] == -180) {
			if ($P_missing[$i] > 0) { return 0; }
			$Pprev = $P[$i];
			$previndex = $i;
		}
		$i++;
	}

# Retur hvis verdien for 3 timer tilbake ikke forkommer
	if (!$previndex) {
		return 0;
	}

# Tolererer avrundingsfeil
	if ( abs ($pp[0] - abs ($P[0] - $Pprev)) > 0.3 ) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "pp_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "P_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "P_".$previndex."_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
