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


#language : 1
#checkname: geok09_card_snowdepth_decrease_toomuch_rain
#signature: obs;RR,SA,V4,V5,V6;;


# Konsistenskontroll check Appendix 5
# Kode hentet fra "snowdepth_precip_weather.pl", subcheck 9 (geok)
# Original laget av Per Ove Kjensli i fortran.
# Siva konverterte koden til perl.
# Rettet på av Øystein Lie 14/12-2004
# Ny versjon Terje Reite og Bjørn Nordin 17.6.2005
# Ny versjon Bjørn Nordin 02.12.2005
# Ny versjon Bjørn Nordin 02.01.2006 - Geok splittet opp.



sub check {


my @index_list;
my @index_list2;

my @XRR;
my @XSA;
my @XV4;
my @XV5;
my @XV6;
# my @XX_1;
my @XSA_missing;
my @XV4_missing;
my @XV5_missing;
my @XV6_missing;
my @retvector;


# Tester om controlinfo(4)=6: Skal ikke teste, avbryter.

	if ($RR_controlinfo[4] == 6) {
	  return 0;
	}

# Tester om SA mangler: Skal ikke teste, avbryter.

   for(my $i=0; $i< $obs_numtimes; $i++) {
	if ($SA_missing[$i] > 0 && ($obs_timeoffset[$i] == 0 || $obs_timeoffset[$i] == -1440)) {
	  return 0;
	}
  }

# Hvis alle parametre mangler: Avbryt, Returverdi-flag=0.
   my $b=1;
   for(my $i=0; $i< $obs_numtimes; $i++) {
    if( $RR_missing[$i] > 0 &&
        $SA_missing[$i] > 0 &&
        $V4_missing[$i] > 0 &&
        $V5_missing[$i] > 0 &&
        $V6_missing[$i] > 0 ){
        ;
      }else{
	$b=0;
	last;
      }
  }


    if( $b == 1 ){
     return 0;
    }


# Initierer parameter-arrayene:

  for(my $i=0; $i<=3; $i++) {
    $XRR[$i] = -32767;
    $XSA[$i] = -32767;
    $XV4[$i] = -32767;
    $XV5[$i] = -32767;
    $XV6[$i] = -32767;
    $XSA_missing[$i] = -32767;
    $XV4_missing[$i] = -32767;
    $XV5_missing[$i] = -32767;
    $XV6_missing[$i] = -32767;
  }

# Lager indeks-tabell.

  my $N = $obs_numtimes;

  for(my $i=0; $i<$N; $i++) {

    if($obs_timeoffset[$i]==0) {
      push(@index_list,0);
      push(@index_list2,$i);
    }
    if($obs_timeoffset[$i]==-780) {
      push(@index_list,1);
      push(@index_list2,$i);
    }
    if($obs_timeoffset[$i]==-1140) {
      push(@index_list,2);
      push(@index_list2,$i);
    }
    if($obs_timeoffset[$i]==-1440) {
      push(@index_list,3);
      push(@index_list2,$i);
    }

  }

  $N = @index_list;


# Sorterer parametrene på rett plass i tid i parameterarrayene.

  for(my $i=0; $i<$N; $i++) {

    $XRR[$index_list[$i]] = $RR[$index_list2[$i]];
    $XSA[$index_list[$i]] = $SA[$index_list2[$i]];
    $XV4[$index_list[$i]] = $V4[$index_list2[$i]];
    $XV5[$index_list[$i]] = $V5[$index_list2[$i]];
    $XV6[$index_list[$i]] = $V6[$index_list2[$i]];
    $XSA_missing[$index_list[$i]] = $SA_missing[$index_list2[$i]];
    $XV4_missing[$index_list[$i]] = $V4_missing[$index_list2[$i]];
    $XV5_missing[$index_list[$i]] = $V5_missing[$index_list2[$i]];
    $XV6_missing[$index_list[$i]] = $V6_missing[$index_list2[$i]];
  }



	my $sst;
	my $regn = "N"; my $sne = "N"; my $sludd = "N"; 
	my $duri = "N"; my $hagl = "N";	my $tord = "N";
	my $tosym;
	my $hosym;
	my $bisym;
	my $dk;
	my $tolerans;
	my @retvector;
	my @vx =($XV4[2],$XV5[2],$XV6[2],$XV4[1],$XV5[1],$XV6[1],$XV4[0],$XV5[0],$XV6[0]);
	#my @vx_missing =( $V4_missing[2],$V5_missing[2],$V6_missing[2],
	#                  $V4_missing[1],$V5_missing[1],$V6_missing[1],
        #                  $V4_missing[0],$V5_missing[0],$V6_missing[0]); 

    # the following convention for the hours is used::
    # $VX[0] is 0600 today, $VX[1] is 1800 yesterday,$VX[2] is 1200 yesterday, $VX[3] is 0600 yesterday, where X={4,5,6}
    # to make this comparison possible @SA is made such that:
    # $SA[0] is 0600 today, $SA[1] and $SA[2] is not defined, $SA[3] is 0600 yesterday

        $dk = "INGEN";

    if ($XSA_missing[0]>0 || $XSA_missing[3]>0) {
	    $sst = undef;
    }else{
      if ($XSA[0] ne undef && $XSA[3] ne undef ) {
	 if ($XSA[3] < 0) {
	   $XSA[3] = 0;
	 }
	 if ($XSA[0] < 0) {
	   $XSA[0] = 0;
	 }	
	 $sst = $XSA[0] - $XSA[3];
	 # $XSA[3] = $XSA[0];
      }else{
	$sst = undef;
      }
    }


     for(my $i=0; $i<=8; $i++) {
       # if( $vx[$i] ne undef && $vx_missing[$i] == 0 ){
	    if ($vx[$i]==3 || $vx[$i]==7 || $vx[$i]==8) {
				$regn = "J";
			}
            if ($vx[$i]==2 || $vx[$i]==5 || $vx[$i]==6) {
				$sne = "J";
			}
            if ($vx[$i]==1 || $vx[$i]==4) {
				$sludd = "J";
			}
            if ($vx[$i]==17 || $vx[$i]==12 || $vx[$i]==31) {
				$duri = "J";
			}
            if ($vx[$i]==10) {
				$hagl = "J";
			}
      }

      $tosym = $regn . $sludd . $sne . $duri . $hagl;
	if ($tosym eq "NNNNN") {
		$dk = "INGEN";
	}
	else {
                
		$hosym = $regn . $sludd . $sne;
		$dk = "MIKS";
		if ($hosym eq "JNN") {
			$dk = "REGN";
		}
		if ($hosym eq "NNJ") {
			$dk = "SNE";
		}
		if ($hosym eq "NNN") {
			$bisym = $duri . $hagl;
			if ($bisym eq "JN") {
				$dk = "DURI";
			}
			if ($bisym eq "NN") {
				$dk = "INGEN";
			}
		}
		if ($dk eq "MIKS") {
			if ($sst > 0) {
				$dk = "SNE";
			} else {
				$dk = "REGN";
			}
		}
	}

	my $flag = 1;
	my $RRfla3 = 1;
	my $RRfla4 = 1;

       # Check no. 72.9 Snow depth decreasing too much ---------------------
	if (($sst*$sst)>($XRR[0]*100 + 225) && $sst<0 && $XRR[0]>0 && $dk eq "REGN") {
	  $flag = 4;

	if ($XV4_missing[0]==0) {
            if ($XV4[0]==3 || $XV4[0]==7 || $XV4[0]==8) {
		    push(@retvector, "V4_0_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V4_0_0_flag", "1");
		  }
		}
	if ($XV4_missing[1]==0) {
            if ($XV4[1]==3 || $XV4[1]==7 || $XV4[1]==8) {
		    push(@retvector, "V4_1_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V4_1_0_flag", "1");
		  }
		}
	if ($XV4_missing[2]==0) {
            if ($XV4[2]==3 || $XV4[2]==7 || $XV4[2]==8) {
		    push(@retvector, "V4_2_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V4_2_0_flag", "1");
		  }
		}
	if ($XV5_missing[0]==0) {
            if ($XV5[0]==3 || $XV5[0]==7 || $XV5[0]==8) {
		    push(@retvector, "V5_0_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V5_0_0_flag", "1");
		  }
		}
	if ($XV5_missing[1]==0) {
            if ($XV5[1]==3 || $XV5[1]==7 || $XV5[1]==8) {
		    push(@retvector, "V5_1_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V5_1_0_flag", "1");
		  }
		}
	if ($XV5_missing[2]==0) {
            if ($XV5[2]==3 || $XV5[2]==7 || $XV5[2]==8) {
		    push(@retvector, "V5_2_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V5_2_0_flag", "1");
		  }
		}
	if ($XV6_missing[0]==0) {
            if ($XV6[0]==3 || $XV6[0]==7 || $XV6[0]==8) {
		    push(@retvector, "V6_0_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V6_0_0_flag", "1");
		  }
		}
	if ($XV6_missing[1]==0) {
            if ($XV6[1]==3 || $XV6[1]==7 || $XV6[1]==8) {
		    push(@retvector, "V6_1_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V6_1_0_flag", "1");
		  }
		}
	if ($XV6_missing[2]==0) {
            if ($XV6[2]==3 || $XV6[2]==7 || $XV6[2]==8) {
		    push(@retvector, "V6_2_0_flag", "4");
		    $RRfla4 = 4;
		} else {
		    push(@retvector, "V6_2_0_flag", "1");
		  }
		}

	  }

#---------------------------------------------------------------------------------
	if ($RR_missing[0]==0) {
	if ($RRfla3 == 3 && $RRfla4 != 4) {
	  push(@retvector, "RR_0_0_flag", $RRfla3);
		} elsif ($RRfla4 == 4) {
	  push(@retvector, "RR_0_0_flag", $RRfla4);
		} elsif ($RRfla3 == 1 && $RRfla4 == 1) {
	    push(@retvector, "RR_0_0_flag", "1");
		}
	}
#---------------------------------------------------------------------------------
	if ($XSA_missing[0]==0) {
	if ($flag == 4) {
	  push(@retvector, "SA_0_0_flag", "4");
		} elsif ($flag == 1) {
	    push(@retvector, "SA_0_0_flag", "1");
		}
	}
#---------------------------------------------------------------------------------
#	else {
#	  print "manglende defaulthåndtering";
#	}

	my $numout= @retvector; # antall returverdier

	if ($numout == 0) {
#	  print "Alt er OK";
		 return 0;
	       }
	

	return (@retvector, $numout);

}
