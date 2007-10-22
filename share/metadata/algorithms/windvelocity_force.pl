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
#checkname       : windvelocity_force
#signature       : obs;FF;;
#skript          : se nedenfor




###################################################################
########  Samsvar mellom vindhastighet og vindstyrke  #############
####  Kontroll av tillatte verdier  ###############################
#########  Av Øystein Lie, 26/5-2003  #############################


# Utfører konsistenskontroll og returnerer kontrollflagg.
# Denne kontrollen returnerer verdien 1 ved ok kontroll og verdien 3 ved feil.

#
# $X, kontrollverdi1
# $Y, kontrollverdi2
#
# Returverdi: 
# $FFflag: Beregnet flaggverdi
# 
# Setter returverdi til 1=OK.

sub check  {
    
    #sjekk for manglende data
    if ($FF_missing[0]>0){
      #aborter..
      return 0;
  }
    
    my $FFflag = 1;

if ((0<$FF[0] && $FF[0]<1) || (1.1<$FF[0] && $FF[0]<2.5) || (2.6<$FF[0] && $FF[0]<4.6) || (4.7<$FF[0] && $FF[0]<6.6) || (6.7<$FF[0] && $FF[0]<9.7) || (9.8<$FF[0] && $FF[0]<12.3) || (12.4<$FF[0] && $FF[0]<15.4) || (15.5<$FF[0] && $FF[0]<19) || (19.1<$FF[0] && $FF[0]<22.6) || (22.7<$FF[0] && $FF[0]<26.7) || (26.8<$FF[0] && $FF[0]<30.8) || (30.9<$FF[0] && $FF[0]<34.9) || $FF[0]>35)  
{
    $FFflag = 3;
    my @retvector;
    push(@retvector, "FF_0_0_flag");
    push(@retvector, $FFflag);
    my $numout = @retvector;
 
    return(@retvector,$numout); 

}
} # end sub check

