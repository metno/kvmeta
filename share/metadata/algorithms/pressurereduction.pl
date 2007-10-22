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
#checkname       : pressurereduction
#signature       : obs;PO,PR,TA;;|meta;HP,Ci;;
#skript          : se nedenfor



#### Appendix 1. Reduksjon av lufttrykket 
#### fra stasjonsnivå til havets nivå. Kontroll ##########
################################################################
################### Av Øystein Lie, 3/6-2003, versjon 1.01 ####### 
  ########### Revidert 13/1-2004 ###### versjon 1.02 #########


# Utfører konsistenskontroll og returnerer kontrollflagg.
# Denne kontrollen returnerer verdien 1 ved ok kontroll og verdien 3 ved feil.


#####################################################################
sub check {
    
    #sjekk for manglende data
    if ($PO_missing[0]>0){    ###########Evn PB
      #aborter..
      return 0;
  }
    if ($PR_missing[0]>0){
      #aborter..
      return 0;
  }
    if ($TA_missing[0]>0){
      #aborter..
      return 0;
  }

    my $PRflag=1;


#############  Verdien til konstanten a   ##########################
    if ($TA[0]<=0) {
	$a=0.5;
	}
    elsif ($TA[0]<=10) {
	$a=1.0;
	}
    elsif (10<$TA[0] && $TA[0]<=20) {
	$a=1.7;
	}
    elsif (20<$TA[0] && $TA[0]<=40) {
	$a=3.0;
	}
####################  METADATA  ##################
######## HP er barometerhøyde og metadata for hver stasjon.
######## Ci er konstanten som varierer etter om stasjonen har 
######## hyppige inversjonsforhold eller ikke #####


    my $P1;
#### Utregning av trykket ved havsnivå, etter algoritme  
    $P1=$PO[0]*exp{$HP[0]/[29.29*($a+0.00325*$HP[0]+($Ci[0]*$TA[0]+273.16))]};

############ Avvikskonstanten  #####################
    my $epsilon; 
    if ($HP[0]<600) {
	$epsilon=0.5;
    }
    elsif ($HP[0]>=600) {
	$epsilon=0.8;
    }
#####################################################

#########  Selve testen  ############################
    if (($PR[0]-$P1) > (abs ($epsilon))) {
	$PRflag=3;
    }

  my @retvector;
  push(@retvector, "PR_0_0_flag");
  push(@retvector, $flag);
  my $numout = @retvector;
 
return(@retvector,$numout); 

} # end sub check
