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


#checkname:		pastrain_noamount6h
#signature:		obs;X1,X2,X3;;
# Konsistenskontroll_Check
# Siva Navaratnam  Thu Jun 12 14:24:04 2003
# Endret av Gabriel Kielland 12. april 2005:
# Sjekken slår ikke til når RR_6 (dvs. X1) mangler, bare når det er meldt tørt. 

sub check {
#tolererer ingen manglende observasjoner:
	if ($X2_missing[0] > 0) {
		# aborter..
		return 0;
	}

	if ($X3_missing[0] > 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;

	if ($X1[0]==-1 && (($X2[0] >= 5 && $X2[0] <= 8) || ($X3[0] >= 5 && $X3[0] <= 8))) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "X1_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "X2_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "X3_0_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
