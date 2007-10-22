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


#checkname:		min_lt
#signature:		obs;X1,X2;;|meta;R1;;
# Konsistenskontroll_Check
# Flagger hvis en observasjon X1 er mindre enn den minste av et sett X2
# Siva Navaratnam  Wed Jun 11 11:21:07 2003
# Gabriel Kielland Thu Oct 25 07:59:00 2004

sub check {
#tolererer ingen manglende observasjoner:
	if ($X1_missing[0] > 0) {
		# aborter..
		return 0;
	}

#tolererer minst en ikke manglende observasjon i settet
	my $AtLeastOne = 0; 
	foreach my $missing (@X2_missing) {
		if ($missing == 0) {
			$AtLeastOne++;
		}
	}

	if($AtLeastOne == 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;
#
# hopper over manglende verdier i X2-arrayet
	my @X2less;
	my $i;
	my $j=0;
	for ($i=0; $i<$obs_numtimes; $i++) {
		if ($X2_missing[$i] == 0) { 
			$X2less[$j] = $X2[$i];
			$j++;
		}
	}

	@X2less = sort{$a <=> $b} @X2less;

	if ($X1[0] > $X2less[0] + $R1[0]) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "X1_0_0_flag");
	push(@retvector, $flag);
#
# flagger den minste verdien i settet
	for ($i=0; $i<$obs_numtimes; $i++) {
		if ($X2[$i] == $X2less[0]) {
			push(@retvector, "X2_".$i."_0_flag");
			push(@retvector, $flag);
		}
	}
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
