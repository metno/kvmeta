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


#checkname:	sleetnational
#signature: obs;TA,V1,V2,V3;;
# Konsistenskontroll_Check
# gjør noen tester og returner en ny verdi for flag
# Siva Navaratnam  Wed Jun 11 11:28:25 2003
# Versjon 2 Øystein Lie 14/6-2004

sub check {

  #TA og minst en av V1/V2/V3 må foreligge:
  if ($TA_missing[0]==0 && ($V1_missing[0]==0 || $V2_missing[0]==0 || $V3_missing[0]==0)) 
    {
      my $TAflag = 1;
      my $V1flag = 1;
      my $V2flag = 1;
      my $V3flag = 1;
      
      if (($TA[0] < -1 || $TA[0] > 5) && ($V1[0] == 1 || $V2[0] == 1 || $V3[0] == 1)) {
	$TAflag = 3;
	if ($V1[0] == 1) {
	  $V1flag = 3;
	}
	if ($V2[0] == 1) {
	  $V2flag = 3;
	}
	if ($V3[0] == 1) {
	  $V3flag = 3;
	}

      }
      
      my @retvector;
      push(@retvector, "TA_0_0_flag");
      push(@retvector, $TAflag);
      push(@retvector, "V1_0_0_flag");
      push(@retvector, $V1flag);
      push(@retvector, "V2_0_0_flag");
      push(@retvector, $V2flag);
      push(@retvector, "V3_0_0_flag");
      push(@retvector, $V3flag);
      my $numout = @retvector; # antall returverdier

      return (@retvector, $numout);
    }
    
    else {
      # aborter..
      return 0;
    }
    
    
  }
