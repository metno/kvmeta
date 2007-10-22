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
#checkname       : windysnowsand_slowwind
#signature       : obs;X,Y;;|meta;R1,R2,R3,R4;;
#skript          : se nedenfor




# Utfører konsistenskontroll og returnerer kontrollflagg.
# Denne kontrollen returnerer verdien 1 ved ok kontroll og verdien 3 ved feil.
########## Revidert 13/1-2004 Øystein Lie  ########################
#
# $X, kontrollverdi1
# $Y, kontrollverdi2
#
# Returverdi: 
# $flag: Beregnet flaggverdi
# 
# Setter returverdi til 1=OK.

sub check {
    
    #sjekk for manglende data
    if ($X_missing[0]>0){
      #aborter..
      return 0;
  }
    if ($Y_missing[0]>0){
    #aborter..
    return 0;
  }
  my $flag = 1;

  if (($X[0] == $R1[0] || ($X[0] <= $R3[0] && $X[0] >= $R2[0])) && $Y[0] < $R4[0])
 
  {
	$flag = 3;
    }
 

  my @retvector;
  push(@retvector, "X_0_0_flag");
  push(@retvector, $flag);
  push(@retvector, "Y_0_0_flag");
  push(@retvector, $flag);
  my $numout = @retvector;
 
  return(@retvector,$numout); 

}





 



