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
#checkname       : precip_weather3
#signature       : obs;RR_24,V1,V2,V3,V4,V5,V6,V7;;0,-1440;;
#skript          : se nedenfor


####Appendix 3. Samsvar mellom værsymboler og nedbørmengde ##########
################################################################
################### Av Øystein Lie, 26/5-2003, versjon 1.01 ####### 
#############         Versjon 1.02  16/9-2003               #######
#############         Versjon 1.03  7/10-2003               #######
#                      
#  ---- RR_24 ----               Versjon 1.04 15/3-2004, RR_24
#  
#---------------------Versjon 1.05 12/4-05
#--------------------Splitter opp tilfelle 1.
############# Omprogrammert versjon Terje Reite og Øystein Lie 15/6-05.
#####Omprogrammert versjon Øystein Lie 23/11-2005


# Utfører konsistenskontroll og returnerer kontrollflagg.
# Denne kontrollen returnerer verdien 1 ved ok kontroll og verdien 3 ved feil.

#
# $RR_24, kontrollverdi1
# 
#
# Returverdi: 
# $flagg: Beregnet flaggverdi
# 
# Setter returverdi til 1=OK.
#####################################################################
sub check {
    
    #sjekk for manglende data
    if ($RR_24_missing[0]>0){
	#aborter
	return 0;
    }

my @retvector;

#####Startverdi (default) for flagget hvis kommet inn  #######
    my $RR_24flag = 1;

    my $N=$obs_numtimes;
    my $M;
    if( $obs_timeoffset[$N-1] == -1440 ){
      $M=$N-1;
    }else{
      $M=$N;
    }

#--------------------------------------
#-------------------------------------------------------------#

## obs;RR_24,V1,V2,V3,V4,V5,V6,V7;;0,-1440;; 
## -1440 angir alle verdier 24 timer tilbake.


    for (my $i=0; $i < $N; $i++) {    	
        #####  Initialiserer flaggverdiene til kodene V1,...,V7 (været siden 
        #####  siste hovedobservasjon) for alle innkommende av disse som gjelder
        #####  for de siste 24 timene.
        $V1flag[$i]=1;
	$V2flag[$i]=1;
	$V3flag[$i]=1;
      }

#for V4,...V7 må vi passe på at vi ikke teller med verdien stemplet -1440 minutter tilbake,
#for den gjelder for enda en dag tilbake. Men hvis siste tidsangivelse i obs_timeoffset > -1440
#er saken grei.
    for (my $i=0; $i < $M; $i++) { 
	$V4flag[$i]=1;
	$V5flag[$i]=1;
	$V6flag[$i]=1;
	$V7flag[$i]=1;
    }


####    Tilfelle 1    #######
#####################################################################
####  RR_24[0]==-1 (ingen nedbør) og V1/V2/V3/V4/V5/V6/V7 = nedbørsymbol
 

if ($RR_24[0]>-1.01 && $RR_24[0]<-0.99) 
 {
  for (my $i=0; $i < $N; $i++) {
    if ((1<=$V1[$i] && $V1[$i]<=11) || (15<=$V1[$i] && $V1[$i]<=16))
     {
       $V1flag[$i] = 3;
       $RR_24flag=3;
     }
    if ((1<=$V2[$i] && $V2[$i]<=11) || (15<=$V2[$i] && $V2[$i]<=16))
     {
       $V2flag[$i] = 3;
       $RR_24flag=3;
     }
    if ((1<=$V3[$i] && $V3[$i]<=11) || (15<=$V3[$i] && $V3[$i]<=16))
     {
       $V3flag[$i] = 3;
       $RR_24flag=3;
     }
  }# end for $N


  for (my $i=0; $i < $M; $i++) {
   if ((1<=$V4[$i] && $V4[$i]<=11) || (15<=$V4[$i] && $V4[$i]<=16))
     {
       $V4flag[$i] = 3;
       $RR_24flag=3;
     }
   if ((1<=$V5[$i] && $V5[$i]<=11) || (15<=$V5[$i] && $V5[$i]<=16))
     {
       $V5flag[$i] = 3;
       $RR_24flag=3;
     }
   if ((1<=$V6[$i] && $V6[$i]<=11) || (15<=$V6[$i] && $V6[$i]<=16))
     {
       $V6flag[$i] = 3;
       $RR_24flag=3;
     }
   if ((1<=$V7[$i] && $V7[$i]<=11) || (15<=$V7[$i] && $V7[$i]<=16))
     {
       $V7flag[$i] = 3;
       $RR_24flag=3;
     }
 }# end for (my $i=0; $i < $M; $i++)
 
} # end if($RR_24[0]>-1.01 && $RR_24[0]<-0.99) 



 ########   Tilfelle 2 og tilfelle 3 slår vi sammen.  ############
#### RR_24[0]=0.0 (nedbør, men ikke målbar) men det finnes ikke nedbørsymbol i V1/V2/V3/V4/V5/V6/V7
  if ($RR_24[0]>-0.01) {

my $telleN=0;
my $telleM=0;

for (my $i=0; $i < $N; $i++) {

  if (((12<=$V1[$i] && $V1[$i]<=14) || (17<=$V1[$i] && $V1[$i]<=29) || $V1_missing[$i]>0) && ((12<=$V2[$i] && $V2[$i]<=14) || (17<=$V2[$i] && $V2[$i]<=29) || $V2_missing[$i]>0) && ((12<=$V3[$i] && $V3[$i]<=14) || (17<=$V3[$i] && $V3[$i]<=29) || $V3_missing[$i]>0)) 
	  {
	    $telleN=$telleN+1;
	    if ($RR_24[0]<0.5) {
	      if ((12<=$V1[$i] && $V1[$i]<=14) || ($V1[$i]==17) || (12<=$V2[$i] && $V2[$i]<=14) || ($V2[$i]==17) || (12<=$V3[$i] && $V3[$i]<=14) || ($V3[$i]==17)) {
		$telleN=$telleN-1;
	      }
	    }
	  }
} # end for ...N




for (my $i=0; $i < $M; $i++) {

  if (((12<=$V4[$i] && $V4[$i]<=14) || (17<=$V4[$i] && $V4[$i]<=29) || $V4_missing[$i]>0) && ((12<=$V5[$i] && $V5[$i]<=14) || (17<=$V5[$i] && $V5[$i]<=29) || $V5_missing[$i]>0) && ((12<=$V6[$i] && $V6[$i]<=14) || (17<=$V6[$i] && $V6[$i]<=29) || $V6_missing[$i]>0) && ((12<=$V7[$i] && $V7[$i]<=14) || (17<=$V7[$i] && $V7[$i]<=29) || $V7_missing[$i]>0))
    {
      
      $telleM=$telleM+1;
      if ($RR_24[0]<0.5) {
	if ((12<=$V4[$i] && $V4[$i]<=14) || ($V4[$i]==17) || (12<=$V5[$i] && $V5[$i]<=14) || ($V5[$i]==17) || (12<=$V6[$i] && $V6[$i]<=14) || ($V6[$i]==17) || (12<=$V7[$i] && $V7[$i]<=14) || ($V7[$i]==17)) {
	  $telleM=$telleM-1;
	}
      }
    }
} # end for ...M


if ($telleN==$N && $telleM==$M)
  {
    $RR_24flag = 3;
  }

} #end if ($RR_24[0]>-0.01 ...............





########################################################################
########################################################################
#----------------------------------------------------------------#######
####      Ferdig med alle testene.
#######   Pusher kontrollflaggene på arrayen retvector ######
#---------Tester for hver parameter (RR_24,V1,....., V7) om de har 
#---------kommet inn, de skal isåfall flagges med 1 eller 3, alt ettersom
#---------testene har slått ut.


#Først RR_24 som gjelder for nå-tidspunkt. (kl. 00 eller kl. 12, dette styres av checks.active)

	if ($RR_24_missing[0]==0) {               #Hvis verdien har kommet inn
	  push(@retvector, "RR_24_0_0_flag");
	  push(@retvector, $RR_24flag);
	}




#For V1,..,V3 gjelder tellevariabelen N:

	for (my $i=0; $i < $N; $i++) {
	
	  if ($V1_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V1_$i" . "_0_flag");
	    push(@retvector, $V1flag[$i]);
	  }
	
	  if ($V2_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V2_$i" . "_0_flag");
	    push(@retvector, $V2flag[$i]);
	  }
	    
	  if ($V3_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V3_$i" . "_0_flag");
	    push(@retvector, $V3flag[$i]);
	  }
	}  # end for ...N


#For V4,..,V7 gjelder tellevariabelen M:

	for (my $i=0; $i < $M; $i++) {
 
	  if ($V4_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V4_$i" . "_0_flag");
	    push(@retvector, $V4flag[$i]);
	  }
	  if ($V5_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V5_$i" . "_0_flag");
	    push(@retvector, $V5flag[$i]);
	  }
	  if ($V6_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V6_$i" . "_0_flag");
	    push(@retvector, $V6flag[$i]);
	  }
	  if ($V7_missing[$i]==0) {                 #Hvis verdien har kommet inn
	    push(@retvector, "V7_$i" . "_0_flag");
	    push(@retvector, $V7flag[$i]);
	  }
	}  # end for ..M

   
   my $numout = @retvector;
    
   return(@retvector,$numout); 
	    
} # end sub check
