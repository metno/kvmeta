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


# checkname : warm_afternoon
# signature : obs;TA,TAX;;|meta;R1;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
# Siva Navaratnam  Fri May 27 13:42:32 2003
# Bjørn Nordin  Fri Dec 01 18:34:00 2006

sub check {
#tolererer ingen manglende observasjoner:

	if ($TA_missing[0] > 0 && $obs_numtimes == 1) {
		# aborter..
		return 0;
	}

	for (my $i=0; $i < $obs_numtimes; $i++) {
	if ($TA_missing[$i] > 0 && $obs_timeoffset[$i] == -360) {
		# aborter..
		return 0;
	}
	}

	if ($TAX_missing[0] > 0) {
		# aborter..
		return 0;
	}

    my $flag = 1;

	for (my $i=0; $i < $obs_numtimes; $i++) {
	if ($TAX[0] + $R1[0] > $TA[$i] && $obs_timeoffset[$i] == -360) {
		$flag = 4;
		my $IN = $i
	}
	}

	my @retvector;
	my $TA_tidIndex = "TA_$IN" . "_0_flag";
	push(@retvector, $TA_tidIndex);
	push(@retvector, $flag);
	push(@retvector, "TAX_0_0_flag");
	push(@retvector, $flag);
	my $numout= @retvector; # antall returverdier

	return (@retvector, $numout);
}
