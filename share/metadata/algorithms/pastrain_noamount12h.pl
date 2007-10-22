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


#checkname:		pastrain_noamount12h
#signature:		obs;RR_12,W1,W2;;
# Konsistenskontroll_Check
# Siva Navaratnam  Wed Jun 11 11:21:07 2003
# Endret av Gabriel Kielland 12. april 2005:
# Sjekken slår ikke til når RR_12 mangler, bare når det er meldt tørt. 

sub check {
#tolererer minst en ikke manglende observasjon:
	my $AtLeastOne = 0; 
	foreach my $missing (@W1_missing) {
		if ($missing == 0) {
			$AtLeastOne++;
		}
	}
	foreach my $missing (@W2_missing) {
		if ($missing == 0) {
			$AtLeastOne++;
		}
	}
	if($AtLeastOne == 0) {
		# aborter..
		return 0;
	}
	
	my $flag = 1;
	my @retvector;
	for (my $i=0; $i < @W1; $i++) {
		if ($RR_12[0]==-1 && ($W1[$i] >= 5 && $W1[$i] <= 8)) {
			$flag = 3;
			push(@retvector, "W1_$i" . "_0_flag");
			push(@retvector, $flag);
		}
	}

	for (my $i=0; $i < @W2; $i++) {
		if ($RR_12[0]==-1 && ($W2[$i] >= 5 && $W2[$i] <= 8)) {
			$flag = 3;
			push(@retvector, "W2_$i" . "_0_flag");
			push(@retvector, $flag);
		}
	}

	push(@retvector, "RR_12_0_0_flag");
	push(@retvector, $flag);
	if ($flag == 1) {
		push(@retvector, "W1_0_0_flag");
		push(@retvector, $flag);
		push(@retvector, "W2_0_0_flag");
		push(@retvector, $flag);
	}
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
