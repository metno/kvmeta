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


#language        : 1
#checkname       : rainshower_noshowerclouds
#signature       : obs;WW,CL;;
#skript          : se nedenfor



# Av det internasjonale skyatlaset kan det se ut til at de to typene bygeskyer: CL=3 og 9 
# dekker praktisk talt alle værsituasjoner med bygenedbør, men at det åpnes for CL=2, 
# dvs. skyer som ikke gir nevneverdig nedbør på våre breddegrader. 
# Da er det naturlig å åpne for at også CL=8 kan gi meget lett nedbør.
#
########## Revidert 20/5-2005 Gabriel Kielland  ########################

#
# $WW, kontrollverdi1
# $CL, kontrollverdi2
#

sub check {
    
    #sjekk for manglende data
    if ($WW_missing[0]>0){
      #aborter..
      return 0;
  }
    if ($CL_missing[0]>0){
    #aborter..
    return 0;
  }
  my $flag = 1;

  if ($WW[0] <= 90 && $WW[0] >= 80 && $CL[0] != 2 && $CL[0] != 3 && $CL[0] != 8 && $CL[0] != 9)
  {
	$flag = 3;
    }
 

  my @retvector;
  push(@retvector, "WW_0_0_flag");
  push(@retvector, $flag);
  push(@retvector, "CL_0_0_flag");
  push(@retvector, $flag);
  my $numout = @retvector;
 
  return(@retvector,$numout); 

}

