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


#checkname:		windmaxmean6h
#signature:		obs;FX,FF;;|meta;FX_C;;
# Konsistenskontroll_Check
# Feilsituasjon: FF > FX
# Tidspunkter, FX : 00,06,12,18 (Hovedobser)
# Tidsperiode, FF : 6 timer bakover fra Hovedobs.
# Bjørn Harald Nordin 2006 03 31.

sub check {

my @FFflag;
my @retvector;

#tolererer ingen manglende observasjoner:
	if ($FX_missing[0] > 0) {
		# aborter..
		return 0;
	}

#tolererer minst en ikke manglende observasjon:
	my $AtLeastOne = 0; 
	foreach my $missing (@FF_missing) {
		if ($missing == 0) {
			$AtLeastOne++;
		}
	}

	if($AtLeastOne == 0) {
		# aborter..
		return 0;
	}

	my $FXflag = 1;

    my $N=$obs_numtimes;

    for (my $i=0; $i < $N; $i++) {    	
        #####  Initialiserer flaggverdiene til kodene FF(0),...,FF(N-1)  
        #####  (FF siden siste hovedobservasjon) for alle innkommende
        #####  av disse som gjelder for de siste 6 timene.
        $FFflag[$i]=1;
      }

  for (my $i=0; $i < $N; $i++) 
  {

	if ($FX[0] < $FF[$i] + $FX_C)
	{

	if ($i == 0) { $FFflag[$i] = 3; }
	if ($i == 0 && $FXflag < 4) { $FXflag=3; }
	if ($i > 0) { $FFflag[$i] = 4; }
	if ($i > 0) { $FXflag=4; }

    	}

  }# end for $N

########################################################################
#----------------------------------------------------------------#######
####      Ferdig med alle testene.
#######   Pusher kontrollflaggene på arrayen retvector ######
#---------Tester for hver parameter (FX og FF(0),.....,FF(N-1)) om de har 
#---------kommet inn, de skal isåfall flagges med 1, 3 eller 4, alt ettersom
#---------testene har slått ut.


#Først FX som gjelder for nå-tidspunkt. (kl.00,06,12,18 dette styres av checks.active)

	if ($FX_missing[0]==0) {               #Hvis verdien har kommet inn
	  push(@retvector, "FX_0_0_flag");
	  push(@retvector, $FXflag);
	}

#For FF(0),..,FF(N-1) gjelder tellevariabelen N:

	for (my $i=0; $i < $N; $i++) {
	
	  if ($FF_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "FF_$i" . "_0_flag");
	    push(@retvector, $FFflag[$i]);
	  }

	}  # end for ...N


	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
