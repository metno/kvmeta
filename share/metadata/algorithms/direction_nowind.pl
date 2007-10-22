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


#checkname:		direction_nowind
#signature:		obs;DD,FF;;

# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
########     Øystein Lie  14/1 2004 #####################
########     versjon2  4/5-2004
sub check {
#tolererer ingen manglende observasjoner:
#	if ($obs_missing > 0) {
	if ($FF_missing[0] > 0 || $DD_controlinfo(13) == 6 || $DD_controlinfo(13) == 7) {
		# aborter..
		return 0;
	}

	my $flag = 1;

	if ($DD[0] != 0 && $FF[0] == 0) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "DD_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "FF_0_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
