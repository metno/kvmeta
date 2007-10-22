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
#checkname       : weathersymbols
#signature       : obs;V1,V2,V3,V4,V5,V6,V7,VV,WW;;
#skript          : se nedenfor



#-#-
#################################################################################
#         6A. Hovedprinsippene for automatisk retting av feil i v�ret 
#         ved observasjonstiden (v�rsymboler og / eller koder)


########################################################################
###### Automatisk retting av feil i v�ret ved observasjonstiden########
################# (v�rsymboler og/eller koder) #########################
########################################################################
######################################################################
# Av �ystein Lie, dato 26/5-2003 Versjon 1.02 ########################
###### Lagt til 0<=$VV[0] 8/3-2004 Versjon 1.03  #####################
######################################################################
#Modifisering med subrutiner september 2006.
#Videre modifisering oktober 2006.------------------------
#Videre mod. 27/11-2006
#Diverse testing og modifisering h�sten 2006------------


# Utf�rer konsistenskontroll og returnerer kontrollflagg.
# Denne kontrollen returnerer verdien 1 ved OK kontroll og 
# verdien 3,6 eller 10 eller 13 ved feil.
#######################################################




#####################################################
sub check {
  
  #sjekk for manglende data
  if ($WW_missing[0]>0 && $V1_missing[0]>0 && $V2_missing[0]>0 && $V3_missing[0]>0){
    #aborter..
    return 0;    
  }



  
  #####Startverdi (default) for flaggene ved innkommet verdi  #######
  my $WWflag = 1;
  my $V1flag = 1;
  my $V2flag = 1;
  my $V3flag = 1;
  my $V4flag = 1;
  my $V5flag = 1;
  my $V6flag = 1;
  my $V7flag = 1;
  my $VVflag = 1;

  my $WWcorr;
  my $V1corr;
  my $V2corr;
  my $V3corr;
  my $V4corr;
  my $V5corr;
  my $V6corr;
  my $V7corr;




  ########################################################################
  #Hovedprogram#------------------------------------------------------------------------------

#---------Algoritme beskrevet under http://kvalobs. 
#---------G� til http://kvproject -> nederst i venstre meny: Link "Notater".
#---- ->Under "Spesifikasjoner fra innholdsgruppen" -> Link "Appendiks 6A til QC1-2".

# --------Her st�r spesifikasjon for: 
#         6A. Hovedprinsippene for automatisk retting av feil i v�ret 
#         ved observasjonstiden (v�rsymboler og / eller koder)
#      ------------------------------------------------------------------

# -----Spesifikasjonen er kodet nedenfor i dette program. Programmet har navnet "weathersymbols.pl". 
# -----Checkbetegnelse "QC1-2-100". 




##Kommentarer til h�yre for hver subrutine. Parentes betyr at feltet kan v�re utfylt, men det kan ogs� v�re blankt. 



#Komb 1 Torden, nedb�r (ikke-nedb�r)
  komb_1_1();  #V1=torden, V2=byger, V3=ikke-byger

  komb_1_2();  #V1=torden, V2=ikke-byger, V3=byger
  komb_1_3();  #V2 torden, V1 byge, V3 ikke-byge
  komb_1_4();  #V2 torden, V3 byge, V1 ikke-byge
  komb_1_5();  #V3 torden, V1 byge, V2 ikke-byge
  komb_1_6();  #V3 torden, V1 ikke-byge, V2 byge
  komb_1_7();  #V1 torden, V2 byger, V3 byger. 2 bygesymboler
  komb_1_8();  #V2 torden, V1 byger, V3 byger. 2 bygesymboler
  komb_1_9();  #V3 torden, V1 byger, V2 byger. 2 bygesymboler
 #komb_1_10();
  komb_1_11(); #Torden + 1 symbol: V2=ikke-byger, WW=[0-99], V3 ikke med
  komb_1_12(); #V2=Torden + 1 symbol: V1=ikke-byger, WW=[0-99], V3 ikke med


  komb_2_1();  #V1 torden, V2 nedb�r, V3 ikke-nedb�r
  komb_2_2();  #V1 torden, V2 ikke-nedb�r, V3 nedb�r
  komb_2_3();  #V2 torden, V1 nedb�r, V3 ikke-nedb�r
  komb_2_4();  #V2 torden, V1 ikke-nedb�r, V3 nedb�r
  komb_2_5();  #V3 torden, V1 nedb�r, V2 ikke-nedb�r
  komb_2_6();  #V3 torden, V1 ikke-nedb�r, V2 nedb�r


  #Komb. 3     Torden, (ikke-nedb�r), (ikke-nedb�r) 
  komb_3_1();  #V1 torden, V2 ikke-nedb�r eller manglende, V3 ikke-nedb�r eller manglende

  komb_3_2();  #V2 torden, V1 ikke-nedb�r eller manglende, V3 ikke-nedb�r eller manglende
  komb_3_3();  #V3 torden, V1 (ikke-nedb�r), V2 (ikke-nedb�r)



  #Kombinasjon 4      Nedb�r (Nedb�r) (Nedb�r)
  komb_4_1();  # 3 symboler tilstede
  komb_4_2();  # 2 symboler nedb�r tilstede+1 symbol manglende eller ikke-nedb�r
               #Og i 4_2 inng�r p� slutten: ikke-byge, byge, manglende eller ikke-byge, byge og ikke-nedb�r----- 




  komb_4_3();  # kun 1 nedb�rsymbol og 2 manglende
               #Tar ogs� deler av det som er beskrevet som Kombinasjon 5-6 i speken:  
               #1 nedb�rsymbol, ikke-nedb�r, ikke-nedb�r




  komb_5_1();  #Resten av det som er betegnet Kombinasjon 5-6 i speken: 
               # Nedb�r, ikke-nedb�r, ikke-torden og etterhvert premisser t�ke, sn�fokk osv...


  komb_7_a();  #----Ikke-nedb�r, t�ke
               ##--Vi har ett symbol (eller flere), ett symbol er premiss t�ke, de andre eventuelle 
               #symbolene er enten manglende eller ikke-torden, ikke-nedb�r, ikke-sn�fokk.
  komb_7_b();  #Ikke-nedb�r, t�ke og sn�fokk. Minst to v�rsymboler tilstede.-
  komb_7_c();  ##sn�fokk (annet) (annet)
               ##Minst ett symbol sn�fokk. De andre enten manglende eller (ikke-torden, ikke-nedb�r, ikke-t�ke)
  komb_7_d();  #Ikke torden, Ikke nedb�r, Ikke t�ke eller Ikke sn�fokk ------
               #Andre v�rsymboler-----En eller flere kommet inn eller alle manglende

  komb_7_e();  #Ingen v�rsymboler----Kan i praksis kun korrigere p� V1 og V4
  komb_7_f();  #ren luft (annet) (annet)
               ##Ikke torden, ikke-nedb�r, ikke-sn�fokk, ikke-t�ke, premiss ett symbol ren luft



  flagg_korr(); #Her korrigerer vi flagg eller setter inn manglende.
####-----------------------------------------------------------------------------------------------####




  #  END HOVEDPROGRAM ######---------------------------------------------------------------------
  ########################################################################




  #################                      #######################
  #### Vi har V1, V2, V3 for v�ret ved observasjonstiden og
  #### V4, V5 og V6 for v�ret siden forrige hovedobservasjon  ##############




  #ALLE SUBRUTINER###-----------------------------------------------------------------
  
  sub komb_1_1 {  #V1=torden, V2=byger, V3=ikke-byger

    ########################################################################
    #### Kombinasjon 1: Torden, nedb�r  #################################### 
    #### 2 symboler: Byger/ikke-byger   ######################
    #########################################################################
    #######   Tar f�rst ved tilfelle V1=torden, V2=byger, V3=ikke-byger,WW={0-98}
    
    
    if (($V1[0]==20) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {
	
=comment

#Legger inn test p� ok. 
if ($V2[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V2[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V2[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V2[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V2[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V2[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V2[0]==7) { #V2 er regnbyge--------------------------
	      if ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      } 
	      elsif ($V3[0]==1) {  #Sludd
		 $V3flag=10;
		 $V3corr=4; #Sett sluddbyge
	       }
	      elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V3flag=10;
		 $V3corr=5; #Sett sn�byger
	       }
	      elsif ($V3[0]==15) {  #Iskorn
		 $V3flag=10;
		 $V3corr=11; #Sett ishagl
	       }
	    }
	    if ($V2[0]==4) { #V2 er sluddbyge--------------------------
	      if ($V3[0]==1) { #V3 sludd-----------------------------
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      } 
	      if ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=10;
		$V3corr=7; #Sett regnbyge
	      }
	      elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V3flag=10;
		$V3corr=5; #Sett sn�byger
	      }
	      elsif ($V3[0]==15) {  #Iskorn
		$V3flag=10;
		$V3corr=11; #Sett ishagl
	      }
	    }
	    if ($V2[0]==5) {
	      if ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      }
	      elsif ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=10;
		$V3corr=7; #Sett regnbyge
	      }
	      elsif ($V3[0]==15) {  #Iskorn
		$V3flag=10;
		$V3corr=11; #Sett ishagl
	      }
	      elsif ($V3[0]==1) {  #Sludd
		$V3flag=10;
		$V3corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) { 

	  if ($V2[0]==9 || $V2[0]==10 || $V2[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V2[0]==9 || $V2[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V2[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V3[0]==15) {  #Iskorn
	      $V3flag=13; #Sletter V3---------
	      $V3_missing[0]=2; #sletter V3
	    }
	    elsif ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
	      $V3flag=10;
	      $V3corr=7; #Sett regnbyge
	    }
	    elsif ($V3[0]==1) {  #Sludd
	      $V3flag=10;
	      $V3corr=4; #Sett sluddbyge
	    }
	    elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V3flag=10;
	      $V3corr=5; #Sett sn�byger
	    }
	  } #end if ($V2[0]==9 || $V2[0]==10 || $V2[0]==11) {-----------------
	} #end if if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V1flag=3;
	  $V2flag=3;
	  $V3flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V1[0]==20) && ($V2[0]==4 || $V2[0]==5 hele regla.............

} #end komb_1_1 ---------------------------------
  



  sub komb_1_2 { 
    
    ########################################################################
    #########  Ved tilfelle V1=torden, V2=ikke-byger, V3=byger, WW={0-28, 30-90} #######################
    
     if (($V1[0]==20) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment

#Legger inn test p� ok. 
if ($V3[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V3[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V3[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V3[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V3[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V3[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut
	
	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V3[0]==7) { #V3 er regnbyge--------------------------
	      if ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      } 
	      elsif ($V2[0]==1) {  #Sludd
		 $V2flag=10;
		 $V2corr=4; #Sett sluddbyge
	       }
	      elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V2flag=10;
		 $V2corr=5; #Sett sn�byger
	       }
	      elsif ($V2[0]==15) {  #Iskorn
		 $V2flag=10;
		 $V2corr=11; #Sett ishagl
	       }
	    }
	    if ($V3[0]==4) { #V3 er sluddbyge--------------------------
	      if ($V2[0]==1) { #V2 sludd-----------------------------
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      } 
	      if ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=10;
		$V2corr=7; #Sett regnbyge
	      }
	      elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V2flag=10;
		$V2corr=5; #Sett sn�byger
	      }
	      elsif ($V2[0]==15) {  #Iskorn
		$V2flag=10;
		$V2corr=11; #Sett ishagl
	      }
	    }
	    if ($V2[0]==5) {
	      if ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      }
	      elsif ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=10;
		$V2corr=7; #Sett regnbyge
	      }
	      elsif ($V2[0]==15) {  #Iskorn
		$V2flag=10;
		$V2corr=11; #Sett ishagl
	      }
	      elsif ($V2[0]==1) {  #Sludd
		$V2flag=10;
		$V2corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) { 

	  if ($V3[0]==9 || $V3[0]==10 || $V3[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V3[0]==9 || $V3[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V3[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V2[0]==15) {  #Iskorn
	      $V2flag=13; #Sletter V2---------
	      $V2_missing[0]=2; #sletter V2
	    }
	    elsif ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
	      $V2flag=10;
	      $V2corr=7; #Sett regnbyge
	    }
	    elsif ($V2[0]==1) {  #Sludd
	      $V2flag=10;
	      $V2corr=4; #Sett sluddbyge
	    }
	    elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V2flag=10;
	      $V2corr=5; #Sett sn�byger
	    }
	  } #end if ($V3[0]==9 || $V3[0]==10 || $V3[0]==11) {-----------------
	} #end if if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V1flag=3;
	  $V3flag=3;
	  $V2flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V1[0]==20) && ($V3[0]==4 || $V3[0]==5 hele regla...........



} #end komb_1_2 ---------------------------------------




  sub komb_1_3 { #V2 torden, V1 byge, V3 ikke-byge
      
    if (($V2[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment
	
#Legger inn test p� ok. 
if ($V1[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V1[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V1[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V1[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V1[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V1[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V1[0]==7) { #V1 er regnbyge--------------------------
	      if ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      } 
	      elsif ($V3[0]==1) {  #Sludd
		 $V3flag=10;
		 $V3corr=4; #Sett sluddbyge
	       }
	      elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V3flag=10;
		 $V3corr=5; #Sett sn�byger
	       }
	      elsif ($V3[0]==15) {  #Iskorn
		 $V3flag=10;
		 $V3corr=11; #Sett ishagl
	       }
	    }
	    if ($V1[0]==4) { #V1 er sluddbyge--------------------------
	      if ($V3[0]==1) { #V3 sludd-----------------------------
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      } 
	      if ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=10;
		$V3corr=7; #Sett regnbyge
	      }
	      elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V3flag=10;
		$V3corr=5; #Sett sn�byger
	      }
	      elsif ($V3[0]==15) {  #Iskorn
		$V3flag=10;
		$V3corr=11; #Sett ishagl
	      }
	    }
	    if ($V3[0]==5) {
	      if ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V3flag=13; #Sletter V3---------
		$V3_missing[0]=2; #sletter V3
	      }
	      elsif ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
		$V3flag=10;
		$V3corr=7; #Sett regnbyge
	      }
	      elsif ($V3[0]==15) {  #Iskorn
		$V3flag=10;
		$V3corr=11; #Sett ishagl
	      }
	      elsif ($V3[0]==1) {  #Sludd
		$V3flag=10;
		$V3corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) { 

	  if ($V1[0]==9 || $V1[0]==10 || $V1[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V1[0]==9 || $V1[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V1[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V3[0]==15) {  #Iskorn
	      $V3flag=13; #Sletter V3---------
	      $V3_missing[0]=2; #sletter V3
	    }
	    elsif ($V3[0]==3 || $V3[0]==8) { #V3 regn eller yr-----------------
	      $V3flag=10;
	      $V3corr=7; #Sett regnbyge
	    }
	    elsif ($V3[0]==1) {  #Sludd
	      $V3flag=10;
	      $V3corr=4; #Sett sluddbyge
	    }
	    elsif ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V3flag=10;
	      $V3corr=5; #Sett sn�byger
	    }
	  } #end if ($V1[0]==9 || $V1[0]==10 || $V1[0]==11) {-----------------
	} #end if if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V2flag=3;
	  $V1flag=3;
	  $V3flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V2[0]==20) && ($V1[0]==4 || $V1[0]==5 hele regla.............


    } #end sub_1_3




  sub komb_1_4 { #V2 torden, V3 byge, V1 ikke-byge
     
     if (($V2[0]==20) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment
	
#Legger inn test p� ok. 
if ($V3[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V3[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V3[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V3[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V3[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V3[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V3[0]==7) { #V3 er regnbyge--------------------------
	      if ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      } 
	      elsif ($V1[0]==1) {  #Sludd
		 $V1flag=10;
		 $V1corr=4; #Sett sluddbyge
	       }
	      elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V1flag=10;
		 $V1corr=5; #Sett sn�byger
	       }
	      elsif ($V1[0]==15) {  #Iskorn
		 $V1flag=10;
		 $V1corr=11; #Sett ishagl
	       }
	    }
	    if ($V3[0]==4) { #V3 er sluddbyge--------------------------
	      if ($V1[0]==1) { #V1 sludd-----------------------------
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      } 
	      if ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=10;
		$V1corr=7; #Sett regnbyge
	      }
	      elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V1flag=10;
		$V1corr=5; #Sett sn�byger
	      }
	      elsif ($V1[0]==15) {  #Iskorn
		$V1flag=10;
		$V1corr=11; #Sett ishagl
	      }
	    }
	    if ($V1[0]==5) {
	      if ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      }
	      elsif ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=10;
		$V1corr=7; #Sett regnbyge
	      }
	      elsif ($V1[0]==15) {  #Iskorn
		$V1flag=10;
		$V1corr=11; #Sett ishagl
	      }
	      elsif ($V1[0]==1) {  #Sludd
		$V1flag=10;
		$V1corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) { 

	  if ($V3[0]==9 || $V3[0]==10 || $V3[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V3[0]==9 || $V3[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V3[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V1[0]==15) {  #Iskorn
	      $V1flag=13; #Sletter V1---------
	      $V1_missing[0]=2; #sletter V1
	    }
	    elsif ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
	      $V1flag=10;
	      $V1corr=7; #Sett regnbyge
	    }
	    elsif ($V1[0]==1) {  #Sludd
	      $V1flag=10;
	      $V1corr=4; #Sett sluddbyge
	    }
	    elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V1flag=10;
	      $V1corr=5; #Sett sn�byger
	    }
	  } #end if ($V3[0]==9 || $V3[0]==10 || $V3[0]==11) {-----------------
	} #end if if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V2flag=3;
	  $V3flag=3;
	  $V1flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V2[0]==20) && ($V3[0]==4 || $V3[0]==5 hele regla..........


    
  } #end sub komb_1_4-------------------



  sub komb_1_5 { #V3 torden, V1 byge, V2 ikke-byge
      
    if (($V3[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment
	
#Legger inn test p� ok. 
if ($V1[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V1[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V1[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V1[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V1[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V1[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut


	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V1[0]==7) { #V1 er regnbyge--------------------------
	      if ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      } 
	      elsif ($V2[0]==1) {  #Sludd
		 $V2flag=10;
		 $V2corr=4; #Sett sluddbyge
	       }
	      elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V2flag=10;
		 $V2corr=5; #Sett sn�byger
	       }
	      elsif ($V2[0]==15) {  #Iskorn
		 $V2flag=10;
		 $V2corr=11; #Sett ishagl
	       }
	    }
	    if ($V1[0]==4) { #V1 er sluddbyge--------------------------
	      if ($V2[0]==1) { #V2 sludd-----------------------------
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      } 
	      if ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=10;
		$V2corr=7; #Sett regnbyge
	      }
	      elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V2flag=10;
		$V2corr=5; #Sett sn�byger
	      }
	      elsif ($V2[0]==15) {  #Iskorn
		$V2flag=10;
		$V2corr=11; #Sett ishagl
	      }
	    }
	    if ($V2[0]==5) {
	      if ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V2flag=13; #Sletter V2---------
		$V2_missing[0]=2; #sletter V2
	      }
	      elsif ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
		$V2flag=10;
		$V2corr=7; #Sett regnbyge
	      }
	      elsif ($V2[0]==15) {  #Iskorn
		$V2flag=10;
		$V2corr=11; #Sett ishagl
	      }
	      elsif ($V2[0]==1) {  #Sludd
		$V2flag=10;
		$V2corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) { 

	  if ($V1[0]==9 || $V1[0]==10 || $V1[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V1[0]==9 || $V1[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V1[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V2[0]==15) {  #Iskorn
	      $V2flag=13; #Sletter V2---------
	      $V2_missing[0]=2; #sletter V2
	    }
	    elsif ($V2[0]==3 || $V2[0]==8) { #V2 regn eller yr-----------------
	      $V2flag=10;
	      $V2corr=7; #Sett regnbyge
	    }
	    elsif ($V2[0]==1) {  #Sludd
	      $V2flag=10;
	      $V2corr=4; #Sett sluddbyge
	    }
	    elsif ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V2flag=10;
	      $V2corr=5; #Sett sn�byger
	    }
	  } #end if ($V1[0]==9 || $V1[0]==10 || $V1[0]==11) {-----------------
	} #end if if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V3flag=3;
	  $V1flag=3;
	  $V2flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V3[0]==20) && ($V1[0]==4 || $V1[0]==5 hele regla.............



  } #end sub komb_1_5---------------------------------




  sub komb_1_6 { #V3 torden, V1 ikke-byge, V2 byge
      
    if (($V3[0]==20) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment
	
#Legger inn test p� ok. 
if ($V2[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V2[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V2[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V2[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V2[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V2[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  ### Regnbyger/sluddbyger/sn�byger   ##############################
	  if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) { #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	    if ($V2[0]==7) { #V2 er regnbyge--------------------------
	      if ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      } 
	      elsif ($V1[0]==1) {  #Sludd
		 $V1flag=10;
		 $V1corr=4; #Sett sluddbyge
	       }
	      elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		 $V1flag=10;
		 $V1corr=5; #Sett sn�byger
	       }
	      elsif ($V1[0]==15) {  #Iskorn
		 $V1flag=10;
		 $V1corr=11; #Sett ishagl
	       }
	    }
	    if ($V2[0]==4) { #V2 er sluddbyge--------------------------
	      if ($V1[0]==1) { #V1 sludd-----------------------------
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      } 
	      if ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=10;
		$V1corr=7; #Sett regnbyge
	      }
	      elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V1flag=10;
		$V1corr=5; #Sett sn�byger
	      }
	      elsif ($V1[0]==15) {  #Iskorn
		$V1flag=10;
		$V1corr=11; #Sett ishagl
	      }
	    }
	    if ($V1[0]==5) {
	      if ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
		$V1flag=13; #Sletter V1---------
		$V1_missing[0]=2; #sletter V1
	      }
	      elsif ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
		$V1flag=10;
		$V1corr=7; #Sett regnbyge
	      }
	      elsif ($V1[0]==15) {  #Iskorn
		$V1flag=10;
		$V1corr=11; #Sett ishagl
	      }
	      elsif ($V1[0]==1) {  #Sludd
		$V1flag=10;
		$V1corr=4; #Sett sluddbyge
	      }
	    }
	  } #end hvis if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) { 

	  if ($V2[0]==9 || $V2[0]==10 || $V2[0]==11) {

	    #####################   Spr�hagl/hagl    ##############################
	    if ($V2[0]==9 || $V2[0]==10) {
	      $WWflag=10;
	      $WWcorr=96;
	    }
	    
	    ##################   Ishagl  ###########################################
	    if ($V2[0]==11) {
	      $WWflag=10;
	      $WWcorr=99;
	    }
	    if ($V1[0]==15) {  #Iskorn
	      $V1flag=13; #Sletter V1---------
	      $V1_missing[0]=2; #sletter V1
	    }
	    elsif ($V1[0]==3 || $V1[0]==8) { #V1 regn eller yr-----------------
	      $V1flag=10;
	      $V1corr=7; #Sett regnbyge
	    }
	    elsif ($V1[0]==1) {  #Sludd
	      $V1flag=10;
	      $V1corr=4; #Sett sluddbyge
	    }
	    elsif ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {  #Sn�, Kornsn�, isn�ler
	      $V1flag=10;
	      $V1corr=5; #Sett sn�byger
	    }
	  } #end if ($V2[0]==9 || $V2[0]==10 || $V2[0]==11) {-----------------
	} #end if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {

	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V3flag=3;
	  $V2flag=3;
	  $V1flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V3[0]==20) && ($V2[0]==4 || $V2[0]==5 hele regla.............


  } #end sub komb_1_6------------------------------




  sub komb_1_7 { #V1 torden, V2 byger, V3 byger. 2 bygesymboler.--------------------

    if (($V1[0]==20) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment

#Legger inn OK-testing
	  if (($V2[0]==7 || $V2[0]==4 || $V2[0]==5 || $V3[0]==7 || $V3[0]==4 || $V3[0]==5) && ($WW[0]==95 || $WW[0]==97)) { return;}
if (($V2[0]==11 || $V2[0]==10 || $V2[0]==9 || $V3[0]==11 || $V3[0]==10 || $V3[0]==9) && ($WW[0]==96 || $WW[0]==99)) { return;}
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V2[0]==4 || $V2[0]==5 || $V2[0]==7) { 
	    #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	  }
	  elsif ($V3[0]==9 || $V3[0]==10 || $V2[0]==9 || $V2[0]==10) {
	    #Spr�hagl, hagl 
	    $WWflag=10;
	    $WWcorr=96;
	  }
	  elsif ($V3[0]==11 || $V2[0]==11) { #Ishagl {
	    $WWflag=10;
	    $WWcorr=99;
	  }
	}
	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V2flag=3;
	  $V3flag=3;
	  $V1flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V1[0]==20) && ($V2[0]==4 || $V2[0]==5 || $V2[0].................
  } #end sub komb_1_7----------------------------------




  sub komb_1_8 { #V2 torden, V1 byger, V3 byger. 2 bygesymboler.--------------------
    
    if (($V2[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment

#Legger inn OK-testing
   if (($V1[0]==7 || $V1[0]==4 || $V1[0]==5 || $V3[0]==7 || $V3[0]==4 || $V3[0]==5) && ($WW[0]==95 || $WW[0]==97)) { return;}
   if (($V1[0]==11 || $V1[0]==10 || $V1[0]==9 || $V3[0]==11 || $V3[0]==10 || $V3[0]==9) && ($WW[0]==96 || $WW[0]==99)) { return;}
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V1[0]==4 || $V1[0]==5 || $V1[0]==7) { 
	    #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	  }
	  elsif ($V3[0]==9 || $V3[0]==10 || $V1[0]==9 || $V1[0]==10) {
	    #Spr�hagl, hagl 
	    $WWflag=10;
	    $WWcorr=96;
	  }
	  elsif ($V3[0]==11 || $V1[0]==11) { #Ishagl {
	    $WWflag=10;
	    $WWcorr=99;
	  }
	}
	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V2flag=3;
	  $V3flag=3;
	  $V1flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V2[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0].................
  } #end sub komb_1_8----------------------------------



sub komb_1_9 { #V3 torden, V1 byger, V2 byger. 2 bygesymboler.--------------------
    
    if (($V3[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && (0<=$WW[0] && $WW[0]<=98))
      {

=comment

#Legger inn OK-testing
   if (($V1[0]==7 || $V1[0]==4 || $V1[0]==5 || $V2[0]==7 || $V2[0]==4 || $V2[0]==5) && ($WW[0]==95 || $WW[0]==97)) { return;}
   if (($V1[0]==11 || $V1[0]==10 || $V1[0]==9 || $V2[0]==11 || $V2[0]==10 || $V2[0]==9) && ($WW[0]==96 || $WW[0]==99)) { return;}
##

=cut

	###For WW=[0-28, 30-90]
	if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	  if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V1[0]==4 || $V1[0]==5 || $V1[0]==7) { 
	    #Sluddbyge, sn�byge, regnbyge
	    $WWflag=10;
	    $WWcorr=95;
	  }
	  elsif ($V2[0]==9 || $V2[0]==10 || $V1[0]==9 || $V1[0]==10) {
	    #Spr�hagl, hagl 
	    $WWflag=10;
	    $WWcorr=96;
	  }
	  elsif ($V2[0]==11 || $V1[0]==11) { #Ishagl {
	    $WWflag=10;
	    $WWcorr=99;
	  }
	}
	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V2flag=3;
	  $V3flag=3;
	  $V1flag=3;
	}
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      } #end if (($V3[0]==20) && ($V1[0]==4 || $V1[0]==5 || $V1[0].................
  } #end sub komb_1_9----------------------------------




  sub komb_1_10_evn {
      
    #M� s� teste for hvis V1=torden, og b�de V2 og V3 er ikke-byger.------------------------
    #Setter is�fall inn byger i V2 etter WW-koden.
      if (($V1[0]==20) && ($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && (0<=$WW[0] && $WW[0]<=98))
	{
	  if (80<=$WW[0] && $WW[0]<=82) {
	    $WWflag=10;
	    $WWcorr=95;
	    $V2flag=10;
	    $V2corr=7;
	  }
	  if (83<=$WW[0] && $WW[0]<=84) {
	    $WWflag=10;
	    $WWcorr=95;
	    $V2flag=10;
	    $V2corr=4;
	  }
	  if (85<=$WW[0] && $WW[0]<=86) {
	    $WWflag=10;
	    $WWcorr=95;
	    $V2flag=10;
	    $V2corr=5;
	  }
	  if (87<=$WW[0] && $WW[0]<=88) {
	    $WWflag=10;
	    $WWcorr=96;
	    $V2flag=10;
	    $V2corr=10;
	  }
	  if (89<=$WW[0] && $WW[0]<=90) {
	    $WWflag=10;
	    $WWcorr=99;
	    $V2flag=10;
	    $V2corr=11;
	  }
	} #end if begge ikke-byger

    } #end komb_1_10 ##################################





   sub komb_1_11 {
      
      ####   Torden + 1 symbol: V2=ikke-byger, WW=[0-99], V3 ikke med  ###  
      ####################
      ############## yr, regn, sludd, sn�, isn�ler  #############################
      if (($V1[0]==20) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V3_missing[0]>0) && (0<=$WW[0] && $WW[0]<=99))
	{
	  if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	    if ($V2[0]==3 || $V2[0]==8 || $V2[0]==1 || $V2[0]==2 || $V2[0]==16) {
	      $WWflag=10;
	      $WWcorr=95;
	      if ($V2[0]==3 || $V2[0]==8)   #yr, regn##
		{
		  $V2flag=10;
		  $V2corr=7;
		}
       
	      if ($V2[0]==1)  #sludd##
		{
		  $V2flag=10;
		  $V2corr=4;
		}
	      if ($V2[0]==2 || $V2[0]==16)  #sn�, isn�ler##
		{
		  $V2flag=10;
		  $V2corr=5;
		}
	    }
	    ######   kornsn�   ###########
	    if ($V2[0]==6)
	      {
		$WWflag=10;
		$WWcorr=96;
		$V2flag=10;
		$V2corr=5;
	      } 
	    ############### Iskorn  ##################################################
	    if ($V2[0]==15)
	      {
		$WWflag=10;
		$WWcorr=99;
		$V2flag=10;
		$V2corr=11;
	      } 
	  } #end if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90))	
	  
	  if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	    $WWflag=3;
	    $V1flag=3;
	    $V2flag=3;
	  }
	  if ($WW[0]==98) {
	    $WWflag=6;
	  }
	  ###################################
	  
	  if ($WW[0]==95 || $WW[0]==96 || $WW[0]==97 || $WW[0]==99) {
	    
	    if ($V2[0]==3 || $V2[0]==8)   #yr, regn##
	      {
		$V2flag=10;
		$V2corr=7;       
	      }
	    if ($V2[0]==1)  #sludd##
	      {
		$V2flag=10;
		$V2corr=4;
	      }
	    if ($V2[0]==2 || $V2[0]==16)  #sn�, isn�ler##
	      {
		$V2flag=10;
		$V2corr=5;       
	      }
	    
	    ######   kornsn�   ###########
	    if ($V2[0]==6)
	      {
		$V2flag=10;
		$V2corr=5;
	      } 
	    ############### Iskorn  ##################################################
	    if ($V2[0]==15)
	      {
		$V2flag=10;
		$V2corr=11;
	      } 
	  } #end if ($WW[0]==95 || $WW[0]==96 || $WW[0]==97 || $WW[0]==99)
	} #end if (($V1[0]==20) && ($V2[0]==1 || $V2[0]==2 ...........


    } #end sub komb_1_11................................


#------------------------------------------------------------------------#




sub komb_1_12 {
   
      ####   V2=Torden + 1 symbol: V1=ikke-byger, WW=[0-99], V3 ikke med  ###  
      ####################
      ############## yr, regn, sludd, sn�, isn�ler  #############################
      if (($V2[0]==20) && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V3_missing[0]>0) && (0<=$WW[0] && $WW[0]<=99))
	{
	  if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90)) {
	    if ($V1[0]==3 || $V1[0]==8 || $V1[0]==1 || $V1[0]==2 || $V1[0]==16) {
	      $WWflag=10;
	      $WWcorr=95;
	      if ($V1[0]==3 || $V1[0]==8)   #yr, regn##
		{
		  $V1flag=10;
		  $V1corr=7;
		}
       
	      if ($V1[0]==1)  #sludd##
		{
		  $V1flag=10;
		  $V1corr=4;
		}
	      if ($V1[0]==2 || $V1[0]==16)  #sn�, isn�ler##
		{
		  $V1flag=10;
		  $V1corr=5;
		}
	    }
	      ######   kornsn�   ###########
	    if ($V1[0]==6)
	      {
		$WWflag=10;
		$WWcorr=96;
		$V1flag=10;
		$V1corr=5;
	      } 
	    ############### Iskorn  ##################################################
	    if ($V1[0]==15)
	      {
		$WWflag=10;
		$WWcorr=99;
		$V1flag=10;
		$V1corr=11;
	      } 
	  } #end if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=90))	

	  if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	    $WWflag=3;
	    $V2flag=3;
	    $V1flag=3;
	  }
	  if ($WW[0]==98) {
	    $WWflag=6;
	  }
	  ###################################
	  
	  if ($WW[0]==95 || $WW[0]==96 || $WW[0]==97 || $WW[0]==99) {
	    
	    if ($V1[0]==3 || $V1[0]==8)   #yr, regn##
	      {
		$V1flag=10;
		$V1corr=7;       
	      }
	    if ($V1[0]==1)  #sludd##
	      {
		$V1flag=10;
		$V1corr=4;
	      }
	    if ($V1[0]==2 || $V1[0]==16)  #sn�, isn�ler##
	      {
		$V1flag=10;
		$V1corr=5;       
	      }
	    
	    ######   kornsn�   ###########
	    if ($V1[0]==6)
	      {
		$V1flag=10;
		$V1corr=5;
	      } 
	    ############### Iskorn  ##################################################
	    if ($V1[0]==15)
	      {
		$V1flag=10;
		$V1corr=11;
	      } 
	  } #end if ($WW[0]==95 || $WW[0]==96 || $WW[0]==97 || $WW[0]==99)
	} #end if (($V2[0]==20) && ($V1[0]==1 || $V1[0]==2 ...........


    } #end sub komb_1_12................................














    ######################################################################
  #################  Kombinasjon2 Torden, nedb�r, ikke-nedb�r  #########
  ###########  Regnbyger, sluddbyger, sn�byger  ###################

  ###### Tar f�rst og tester for at V1=torden, V2=nedb�r og V3=ikke-nedb�r og WW=[0-99] ####
  ########## og fjerner enkelte ikke-nedb�r-symboler i V3 #############f�r vi 
  ##### etterp� g�r videre med en masse if-tester innenfor denne elsif- 
  ### l�kken, hvor flere (to) if tester kan oppfylles #####, tar f�rst �verst side 60 og s� nederst side 59  ####################
  #########################################################################



  sub komb_2_1_gammel {
    
    #######  Kombinasjon 2 ####################################
    #############################################################
    #############################################################
    #### nederst side 59, etter OK.  V1=torden, V2 =byger, V3 med eller ikke.
    ## Hvis V2 er ikke-byger dekkes tilfellet av Komb. 1   #########    
    if ($V1[0]==20 && (1<=$V2[0] && $V2[0]<=11 || $V2[0]==15 || $V2[0]==16)) {
      if (0<=$WW[0] && $WW[0]<=28 || 30<=$WW[0] && $WW[0]<=55 || 58<=$WW[0] && $WW[0]<=65 || 68<=$WW[0] && $WW[0]<=90) {
	if ($V2[0]==7 || $V2[0]==4 || $V2[0]==5) { #Regnbyg, sluddbyg, sn�byger
	  $WWflag=10;
	  $WWcorr=95;
	}
	if ($V2[0]==9 || $V2[0]==10) { ## Spr�hagl, hagl
	  $WWflag=10;
	  $WWcorr=96;
	}
	if ($V2[0]==11) { ## ishagl
	  $WWflag=10;
	  $WWcorr=99;
	}
	if ($WW[0]==29 || (91<=$WW[0] && $WW[0]<=94)) {
	  $WWflag=3;
	  $V1flag=3;
	  $V2flag=3;
	}	    
	if ((56<=$WW[0] && $WW[0]<=57) || (66<=$WW[0] && $WW[0]<=67)) {
	  $V2flag=10;
	  $V2corr=14;
	} 
	if ($WW[0]==98) {
	  $WWflag=6;
	}
	
      }
    } #end if ($V1[0]==20 && (1<=$V2[0] && $V2[0]<=11 .........


    ######### s. 60, t�ke ####  Tester p� at V1 er torden, V2 NEDB�R, V3 IKKE-NEDB�R, WW=[0-99]
    elsif (($V1[0]==20) && (1<=$V2[0] && $V2[0]<=11 || $V2[0]==15 || $V2[0]==16) && (12<=$V3[0] && $V3[0]<=14 || 17<=$V3[0] && $V3[0]<=29) && (0<=$WW[0] && $WW[0]<=99)) {
      if ($V3[0]==29) {
	$V3flag=13;
	$V3_missing[0]=2; #sletter kornmo
      }
      if ($V3[0]==19 && $VV[0]>10000) {
	$V3flag=13;
	$V3_missing[0]=2; #sletter t�kedis
      }
      if ($V3[0]==21) {
	$V3flag=13;
	$V3_missing[0]=2; #sletter �lr�yk
      }
      if ($V3[0]==28) {
	$WWflag=3;
	$V1flag=3;
	$V2flag=3;
	$V3flag=3;
      }
      if (0<=$VV[0] && $VV[0]<1000) {
	$WWflag=3;
	$VVflag=3;
      } 
      
      if ($V3[0]==18 && $WW[0]!=28 && $VV[0]>900)
	{
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke##
	}
      if ($V3[0]==18 && $WW[0]==28)
	{
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke##
	  $V4flag=10;
	  $V4corr=18;  # Setter inn t�ke for v�ret siden forrige observasjon ###
	}
      
    } #end elsif (($V1[0]==20) && (1<=$V2[0] && $V2[0]<=11 ........
    
    
  } #end sub komb_2_1
















#####Komb. 2 Torden, nedb�r, ikke-nedb�r, alle symboler utfylt.------------------------
#--------------------------------------------------------------------------------------

sub komb_2_1 {     #Hvis V1 torden, V2 nedb�r, V3 ikke-nedb�r-------------------
  
  if (($V1[0]==20) && ((1<=$V2[0] && $V2[0]<=11) || $V2[0]==15 || $V2[0]==16) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V2[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V2[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V2[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V2[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V2[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V2[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V2[0]==9 || $V2[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V2[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    } #end ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V2[0]==3 || $V2[0]==8) {
	$V2flag=10;
	$V2corr=7; #Setter inn regnbyger--------------
      }
      if ($V2[0]==1) {
	$V2flag=10;
	$V2corr=4; #Setter sluddbyger-----------------
      }
      if ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {
	$V2flag=10;
	$V2corr=5; #Setter inn sn�byger--------------
      }
      if ($V2[0]==15) {
	$V2flag=10;
	$V2corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V3[0]==18 && $VV[0]>900) {
	$V3flag=13;
	$V3_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V3[0]==18) {
      $V3flag=13;
      $V3_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V3[0]==18) 
    
    if ($V3[0]==28) { #Sn�fokk
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
    if ($V3[0]==29) { #Kornmo
      $V3flag=13;
      $V3_missing[0]=2;  #Sletter kornmo
    }
    if ($V3[0]==19 && $VV[0]>10000) {
      $V3flag=13;
      $V3_missing[0]=2;
    }
    if ($V3[0]==21) { 
      $V3flag=13;
      $V3_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) { #M� sjekke p� om den har kommet inn
      $VVflag=3;
      $WWflag=3;
    }



  } # end if (($V1[0]==20) && (1<=$V2[0] && $V2[0]<=11 || $V2[0]==15........

} # end sub komb_2_1------------------




sub komb_2_2 {     #Hvis V1 torden, V2 ikke-nedb�r, V3 nedb�r----
#----------------------------
  if (($V1[0]==20) && ((1<=$V3[0] && $V3[0]<=11) || $V3[0]==15 || $V3[0]==16) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V3[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V3[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V3[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V3[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V3[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V3[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V3[0]==9 || $V3[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V3[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    }
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V1flag=3;
      $V3flag=3;
      $V2flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V3[0]==3 || $V3[0]==8) {
	$V3flag=10;
	$V3corr=7; #Setter inn regnbyger--------------
      }
      if ($V3[0]==1) {
	$V3flag=10;
	$V3corr=4; #Setter sluddbyger-----------------
      }
      if ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {
	$V3flag=10;
	$V3corr=5; #Setter inn sn�byger--------------
      }
      if ($V3[0]==15) {
	$V3flag=10;
	$V3corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V2[0]==18 && $VV[0]>900) {
	$V2flag=13;
	$V2_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V2[0]==18) {
      $V2flag=13;
      $V2_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V2[0]==18) 
    
    if ($V2[0]==28) { #Sn�fokk
      $WWflag=3;
      $V1flag=3;
      $V3flag=3;
      $V2flag=3;
    }
    if ($V2[0]==29) { #Kornmo
      $V2flag=13;
      $V2_missing[0]=2;  #Sletter kornmo
    }
    if ($V2[0]==19 && $VV[0]>10000) {
      $V2flag=13;
      $V2_missing[0]=2;
    }
    if ($V2[0]==21) { 
      $V2flag=13;
      $V2_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      $VVflag=3;
      $WWflag=3;
    }

  } # end if (($V1[0]==20) && (1<=$V3[0] && $V3[0]<=11 || $V3[0]==15...


} #end sub komb_2_2---------------



sub komb_2_3 { #V2 torden, V1 nedb�r, V3 ikke-nedb�r-----------
  
  if (($V2[0]==20) && ((1<=$V1[0] && $V1[0]<=11) || $V1[0]==15 || $V1[0]==16) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V1[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V1[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V1[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V1[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V1[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V1[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V1[0]==9 || $V1[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V1[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    }
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V2flag=3;
      $V1flag=3;
      $V3flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V1[0]==3 || $V1[0]==8) {
	$V1flag=10;
	$V1corr=7; #Setter inn regnbyger--------------
      }
      if ($V1[0]==1) {
	$V1flag=10;
	$V1corr=4; #Setter sluddbyger-----------------
      }
      if ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {
	$V1flag=10;
	$V1corr=5; #Setter inn sn�byger--------------
      }
      if ($V1[0]==15) {
	$V1flag=10;
	$V1corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V3[0]==18 && $VV[0]>900) {
	$V3flag=13;
	$V3_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V3[0]==18) {
      $V3flag=13;
      $V3_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V3[0]==18) 
    
    if ($V3[0]==28) { #Sn�fokk
      $WWflag=3;
      $V2flag=3;
      $V1flag=3;
      $V3flag=3;
    }
    if ($V3[0]==29) { #Kornmo
      $V3flag=13;
      $V3_missing[0]=2;  #Sletter kornmo
    }
    if ($V3[0]==19 && $VV[0]>10000) {
      $V3flag=13;
      $V3_missing[0]=2;
    }
    if ($V3[0]==21) { 
      $V3flag=13;
      $V3_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      $VVflag=3;
      $WWflag=3;
    }



  } # end if (($V2[0]==20) && (1<=$V1[0] && $V1[0]<=11 || $V1[0]==15........
 

} #end sub komb_2_3---------------




sub komb_2_4 { #V2 torden, V1 ikke-nedb�r, V3 nedb�r------------
  #----------------------------
  if (($V2[0]==20) && ((1<=$V3[0] && $V3[0]<=11) || $V3[0]==15 || $V3[0]==16) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V3[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V3[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V3[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V3[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V3[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V3[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V3[0]==4 || $V3[0]==5 || $V3[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V3[0]==9 || $V3[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V3[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    }
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V2flag=3;
      $V3flag=3;
      $V1flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V3[0]==3 || $V3[0]==8) {
	$V3flag=10;
	$V3corr=7; #Setter inn regnbyger--------------
      }
      if ($V3[0]==1) {
	$V3flag=10;
	$V3corr=4; #Setter sluddbyger-----------------
      }
      if ($V3[0]==2 || $V3[0]==6 || $V3[0]==16) {
	$V3flag=10;
	$V3corr=5; #Setter inn sn�byger--------------
      }
      if ($V3[0]==15) {
	$V3flag=10;
	$V3corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V1[0]==18 && $VV[0]>900) {
	$V1flag=13;
	$V1_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V1[0]==18) {
      $V1flag=13;
      $V1_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V1[0]==18) 
    
    if ($V1[0]==28) { #Sn�fokk
      $WWflag=3;
      $V2flag=3;
      $V3flag=3;
      $V1flag=3;
    }
    if ($V1[0]==29) { #Kornmo
      $V1flag=13;
      $V1_missing[0]=2;  #Sletter kornmo
    }
    if ($V1[0]==19 && $VV[0]>10000) {
      $V1flag=13;
      $V1_missing[0]=2;
    }
    if ($V1[0]==21) { 
      $V1flag=13;
      $V1_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      $VVflag=3;
      $WWflag=3;
    }

  } # end if (($V2[0]==20) && (1<=$V3[0] && $V3[0]<=11 || $V3[0]==15...


} #end sub komb_2_4---------------




sub komb_2_5 { #V3 torden, V1 nedb�r, V2 ikke-nedb�r------------

  if (($V3[0]==20) && ((1<=$V1[0] && $V1[0]<=11) || $V1[0]==15 || $V1[0]==16) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V1[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V1[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V1[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V1[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V1[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V1[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V1[0]==4 || $V1[0]==5 || $V1[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V1[0]==9 || $V1[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V1[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    }
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V3flag=3;
      $V1flag=3;
      $V2flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V1[0]==3 || $V1[0]==8) {
	$V1flag=10;
	$V1corr=7; #Setter inn regnbyger--------------
      }
      if ($V1[0]==1) {
	$V1flag=10;
	$V1corr=4; #Setter sluddbyger-----------------
      }
      if ($V1[0]==2 || $V1[0]==6 || $V1[0]==16) {
	$V1flag=10;
	$V1corr=5; #Setter inn sn�byger--------------
      }
      if ($V1[0]==15) {
	$V1flag=10;
	$V1corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V2[0]==18 && $VV[0]>900) {
	$V2flag=13;
	$V2_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V2[0]==18) {
      $V2flag=13;
      $V2_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V2[0]==18) 
    
    if ($V2[0]==28) { #Sn�fokk
      $WWflag=3;
      $V3flag=3;
      $V1flag=3;
      $V2flag=3;
    }
    if ($V2[0]==29) { #Kornmo
      $V2flag=13;
      $V2_missing[0]=2;  #Sletter kornmo
    }
    if ($V2[0]==19 && $VV[0]>10000) {
      $V2flag=13;
      $V2_missing[0]=2;
    }
    if ($V2[0]==21) { 
      $V2flag=13;
      $V2_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      $VVflag=3;
      $WWflag=3;
    }


  } # end if (($V3[0]==20) && (1<=$V1[0] && $V1[0]<=11 || $V1[0]==15.......


} #end sub komb_2_5-------------





sub komb_2_6 { #V3 torden, V1 ikke-nedb�r, V2 nedb�r------------

#----------------------------
  if (($V3[0]==20) && ((1<=$V2[0] && $V2[0]<=11) || $V2[0]==15 || $V2[0]==16) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=29)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Legger inn test p� ok. 
if ($V2[0]==7 && ($WW[0]==95 || $WW[0]==97)) { return;}  #regnbyger 
if ($V2[0]==4 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sluddbyger
if ($V2[0]==5 && ($WW[0]==95 || $WW[0]==97)) { return;}   #sn�byger
if ($V2[0]==10 && ($WW[0]==96 || $WW[0]==99)) { return;}  #hagl
if ($V2[0]==9 && ($WW[0]==96 || $WW[0]==99)) { return;}    #spr�hagl
if ($V2[0]==11 && ($WW[0]==96 || $WW[0]==99)) { return;}    #ishagl
##

=cut

    if ((0<=$WW[0] && $WW[0]<=28) || (30<=$WW[0] && $WW[0]<=55) || (58<=$WW[0] && $WW[0]<=65) || (68<=$WW[0] && $WW[0]<=90)) {
      if ($V2[0]==4 || $V2[0]==5 || $V2[0]==7) {
	$WWflag=10;
	$WWcorr=95;
      }
      if ($V2[0]==9 || $V2[0]==10) {
	$WWflag=10;
	$WWcorr=96;
      }
      if ($V2[0]==11) {
	$WWflag=10;
	$WWcorr=99;
      }
    }
    if ((91<=$WW[0] && $WW[0]<=94) || $WW[0]==29) {
      $WWflag=3;
      $V3flag=3;
      $V2flag=3;
      $V1flag=3;
    }
    if ($WW[0]==98) {
      $WWflag=6;
    }
    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
      if ($V2[0]==3 || $V2[0]==8) {
	$V2flag=10;
	$V2corr=7; #Setter inn regnbyger--------------
      }
      if ($V2[0]==1) {
	$V2flag=10;
	$V2corr=4; #Setter sluddbyger-----------------
      }
      if ($V2[0]==2 || $V2[0]==6 || $V2[0]==16) {
	$V2flag=10;
	$V2corr=5; #Setter inn sn�byger--------------
      }
      if ($V2[0]==15) {
	$V2flag=10;
	$V2corr=11; #Setter inn ishagl-----------------
      }
    }
    if ((0<=$WW[0] && $WW[0]<=27) || (29<=$WW[0] && $WW[0]<=99)) {
      if ($V1[0]==18 && $VV[0]>900) {
	$V1flag=13;
	$V1_missing[0]=2; #sletter t�ke
      }
    }
    if ($WW[0]==28 && $V1[0]==18) {
      $V1flag=13;
      $V1_missing[0]=2; #sletter t�ke
      #S� m� vi teste en del for � kunne legge inn i enten V4, V5, V6
      #eller V7, dvs. v�ret siden forrige hovedobservasjon
      if ($V4[0]!=18 && $V5[0]!=18 && $V6[0]!=18 && $V7[0]!=18) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      } #end if ($V4[0]!=18 && $V5[0]!=18......
    } #end if ($WW[0]==28 && $V1[0]==18) 
    
    if ($V1[0]==28) { #Sn�fokk
      $WWflag=3;
      $V3flag=3;
      $V2flag=3;
      $V1flag=3;
    }
    if ($V1[0]==29) { #Kornmo
      $V1flag=13;
      $V1_missing[0]=2;  #Sletter kornmo
    }
    if ($V1[0]==19 && $VV[0]>10000) {
      $V1flag=13;
      $V1_missing[0]=2;
    }
    if ($V1[0]==21) { 
      $V1flag=13;
      $V1_missing[0]=2;
    }
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      $VVflag=3;
      $WWflag=3;
    }

  } # end if (($V3[0]==20) && (1<=$V2[0] && $V2[0]<=11 || $V2[0]==15...



} #end sub komb_2_6-------------









##
####
#######
##########---------------##################------------#####################
############################################################################
#Komb. 3 ---Torden, (ikke-nedb�r), (ikke-nedb�r) -------------------------------------------------------------------
#------------------------------------------------------------------------------

sub komb_3_1 { # V1 torden, V2 ikke-nedb�r eller manglende, V3 ikke-nedb�r eller manglende
  
  if (($V1[0]==20) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=29) || $V2_missing[0]>0) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=29) || $V3_missing[0]>0) && (0<=$WW[0] && $WW[0]<=99)) { 

=comment

#Legger inn test p� om ok...
      if ($WW[0]==17) { return;}
###

=cut

    if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=16) || (30<=$WW[0] && $WW[0]<=35)) {
      $WWflag=10;
      $WWcorr=17;
    }
    if ($WW[0]==5) {
      $WWflag=10;
      $WWcorr=17;
      if ($V2[0] != 21 && $V3[0] != 21) {
	if ($V3_missing[0]==0) {
	  $V3flag=10;
	  $V3corr=21;
	}
	if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	  $V2flag=10;
	  $V2corr=21;
	}
      }
    }
    if ($WW[0]==10) { #T�kedis
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<=10000) {
	if ($V2[0] != 19 && $V3[0] != 19) {
	  if ($V3_missing[0]==0) {
	    $V3flag=10;
	    $V3corr=19; #Setter inn t�kedis-----------
	  }
	  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=19; #Setter inn t�kedis-----------
	  }
	}
      }
    }
    if ($WW[0]==13) { #Lyn
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 29) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter kornmo.
      }
      if ($V2[0] == 29) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter kornmo.
      }
    }
    if (20<=$WW[0] && $WW[0]<=27) {
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 14) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter isslag.
      }
      if ($V2[0] == 14) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter isslag.
      }
      my $settinn =0;
      if ($WW[0]==20) { $settinn=8; }
      if ($WW[0]==21) { $settinn=3; }
      if ($WW[0]==22) { $settinn=2; }
      if ($WW[0]==23) { $settinn=1; }
      if ($WW[0]==24) { $settinn=14; }
      if ($WW[0]==25) { $settinn=7; }
      if ($WW[0]==26) { $settinn=5; }
      if ($WW[0]==27) { $settinn=10; }

      if ($V7_missing[0]==0 && $V7[0] !=$settinn) { #V7 har kommet inn
	$V7flag=10;
	$V7corr=$settinn;
      }
      if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=$settinn) {
	$V6flag=10;
	$V6corr=$settinn;
      }
      if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=$settinn) {
	$V5flag=10;
	$V5corr=$settinn;
      }
      if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=$settinn) {
	$V4flag=10;
	$V4corr=$settinn;
      }
    } # end if (20<=$WW[0] && $WW[0]<=27).......
    if ($WW[0]==28 || (40<=$WW[0] && $WW[0]<=41)) {
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 18) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter t�ke.
      }
      if ($V2[0] == 18) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter t�ke.
      }
    }
    if ($WW[0]==29) {
      $V1flag=13;
      $V1_missing[0]=2; #Sletter torden.
    
      #Setter inn torden i en av V4/V5/V6/V7.
      if ($V4[0] !=20 && $V5[0] !=20 && $V6[0] !=20 && $V7[0] !=20) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=20;
	}
      } #end if ($V4[0]!=20 && $V5[0]!=20......
    } #end if ww=29.
    
    if (36<=$WW[0] && $WW[0]<=39) {
      $WWflag=10;
      $WWcorr=17;
      if ($V2[0] != 28 && $V3[0] != 28) {
	if ($V3_missing[0]==0) {
	  $V3flag=10;
	  $V3corr=28; #Setter inn sn�fokk-----------
	}
	if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	  $V2flag=10;
	  $V2corr=28; #Setter inn sn�fokk-----------
	}
      }
    }
    
    if (42<=$WW[0] && $WW[0]<=49) {
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<1000) {
	if ($V2[0] != 18 && $V3[0] != 18) {
	  if ($V3_missing[0]==0) {
	    $V3flag=10;
	    $V3corr=18; #Setter inn t�ke-----------
	  }
	  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=18; #Setter inn t�ke-----------
	  }
	}
      }
    }
    if (50<$WW[0] && $WW[0]<=99) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }

    #Obs her er vi ute av WW-sl�yfene, s� vi m� gj�re eksplisitt testing..eks p� ww=17.
    #Premisser: T�ke, sn�fokk, isslag kornmo osv.......
    #F�rst t�ke---------------


   if ($WW[0]!=17) { 
    if ($V2[0]==18 || $V3[0]==18) {
      if (0<=$WW[0] && $WW[0]<=41) {
	if ($VV_missing[0]==0 && $VV[0]<1000) {
	  if (0<=$WW[0] && $WW[0]<=35) {
	    $WWflag=10;
	    $WWcorr=17;
	  }
	  if (36<=$WW[0] && $WW[0]<=41) {
	    $WWflag=3;
	    $V1flag=3;
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}
	if ($VV[0]>=1000) {
	  $WWflag=10;
	  $WWcorr=17;
	  if ($V3[0] == 18) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter t�ke.
	  }
	  if ($V2[0] == 18) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter t�ke.
	  }
	}
      }
    }
    #end t�ke------------
    if ($V2[0]==28 || $V3[0]==28) {
      if ((0<=$WW[0] && $WW[0]<=35) || (40<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
      }
    }
    if ($V2[0]==14 || $V3[0]==14) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }
    if ($V2[0]==29 || $V3[0]==29) {
      if ((0<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V3[0] == 29) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter kornmo.
	}
	if ($V2[0] == 29) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter kornmo.
	}
      }
    }
    if ($V2[0]==19 || $V3[0]==19) { #T�kedis
      if ((0<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($VV[0]>10000) {
	  if ($V3[0] == 19) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter 
	  }
	  if ($V2[0] == 19) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter 
	  }
	}
      }
    }
    if ($V2[0]==21 || $V3[0]==21) { ##�lr�yk
      if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V2[0]==19 && $V3[0]==21) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter
	}
	if ($V2[0]==21 && $V3[0]==19) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter
	}
      }
    }
    if ($V2[0] != 18 && $V2[0] != 28 && $V2[0] != 14 && $V2[0] != 29 && $V2[0] != 19 && $V2[0] != 21 && $V3[0] != 18 && $V3[0] != 28 && $V3[0] != 14 && $V3[0] != 29 && $V3[0] != 19 && $V3[0] != 21) { #Annet----------------------
      if (0<=$WW[0] && $WW[0]<=49) {
	$WWflag=10;
	$WWcorr=17;
      }
    }

#Hvis V3 mangler:
    if ($V3_missing[0]>0) {
      if ($V2[0] != 18 && $V2[0] != 28 && $VV_missing[0]==0 && $VV[0]<1000) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $WWflag=3;
	  $VVflag=3;
	}
      }

=comment

      if ($V2[0] != 19 && (1000<=$VV[0] && $VV_missing[0]==0 && $VV[0]<=10000)) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $V2flag=10;
	  $V2corr=19; #Setter inn t�kedis-----------
	}
      }

=cut

    }
   } #end if ww !=17-----------
 } #end if (($V1[0]==20) && ((12<=$V2[0] && $V2[0]<=14)..........



} #end sub komb_3_1................





sub komb_3_2 { # V2 torden, V1 ikke-nedb�r eller manglende, V3 ikke-nedb�r eller manglende

 if (($V2[0]==20) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=29) || $V1_missing[0]>0) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=29) || $V3_missing[0]>0) && (0<=$WW[0] && $WW[0]<=99)) { 

=comment

#Legger inn test p� om ok...
      if ($WW[0]==17) { return;}
###

=cut

    if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=16) || (30<=$WW[0] && $WW[0]<=35)) {
      $WWflag=10;
      $WWcorr=17;
    }
    if ($WW[0]==5) {
      $WWflag=10;
      $WWcorr=17;
      if ($V1[0] != 21 && $V3[0] != 21) {
	if ($V3_missing[0]==0) {
	  $V3flag=10;
	  $V3corr=21;
	}
	if ($V1_missing[0]==0 && $V3_missing[0]>0) {
	  $V1flag=10;
	  $V1corr=21;
	}
      }
    }
    if ($WW[0]==10) { #T�kedis
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<=10000) {
	if ($V1[0] != 19 && $V3[0] != 19) {
	  if ($V3_missing[0]==0) {
	    $V3flag=10;
	    $V3corr=19; #Setter inn t�kedis-----------
	  }
	  if ($V1_missing[0]==0 && $V3_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=19; #Setter inn t�kedis-----------
	  }
	}
      }
    }
    if ($WW[0]==13) { #Lyn
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 29) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter kornmo.
      }
      if ($V1[0] == 29) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter kornmo.
      }
    }
    if (20<=$WW[0] && $WW[0]<=27) {
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 14) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter isslag.
      }
      if ($V1[0] == 14) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter isslag.
      }
      my $settinn =0;
      if ($WW[0]==20) { $settinn=8; }
      if ($WW[0]==21) { $settinn=3; }
      if ($WW[0]==22) { $settinn=2; }
      if ($WW[0]==23) { $settinn=1; }
      if ($WW[0]==24) { $settinn=14; }
      if ($WW[0]==25) { $settinn=7; }
      if ($WW[0]==26) { $settinn=5; }
      if ($WW[0]==27) { $settinn=10; }
     
      if ($V7_missing[0]==0 && $V7[0] !=$settinn) { #V7 har kommet inn
	$V7flag=10;
	$V7corr=$settinn;
      }
      if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=$settinn) {
	$V6flag=10;
	$V6corr=$settinn;
      }
      if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=$settinn) {
	$V5flag=10;
	$V5corr=$settinn;
      }
      if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=$settinn) {
	$V4flag=10;
	$V4corr=$settinn;
      }
    } # end if (20<=$WW[0] && $WW[0]<=27).......
    if ($WW[0]==28 || (40<=$WW[0] && $WW[0]<=41)) {
      $WWflag=10;
      $WWcorr=17;
      if ($V3[0] == 18) {
	$V3flag=13;
	$V3_missing[0]=2; #Sletter t�ke.
      }
      if ($V1[0] == 18) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter t�ke.
      }
    }
    if ($WW[0]==29) {
      $V2flag=13;
      $V2_missing[0]=2; #Sletter torden.
    
      #Setter inn torden i en av V4/V5/V6/V7.
      if ($V4[0]!=20 && $V5[0]!=20 && $V6[0]!=20 && $V7[0]!=20) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=20;
	}
      } #end if ($V4[0]!=20 && $V5[0]!=20......
    }
    
    if (36<=$WW[0] && $WW[0]<=39) {
      $WWflag=10;
      $WWcorr=17;
      if ($V1[0] != 28 && $V3[0] != 28) {
	if ($V3_missing[0]==0) {
	  $V3flag=10;
	  $V3corr=28; #Setter inn sn�fokk-----------
	}
	if ($V1_missing[0]==0 && $V3_missing[0]>0) {
	  $V1flag=10;
	  $V1corr=28; #Setter inn sn�fokk-----------
	}
      }
    }
    
    if (42<=$WW[0] && $WW[0]<=49) {
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<1000) {
	if ($V1[0] != 18 && $V3[0] != 18) {
	  if ($V3_missing[0]==0) {
	    $V3flag=10;
	    $V3corr=18; #Setter inn t�ke-----------
	  }
	  if ($V1_missing[0]==0 && $V3_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=18; #Setter inn t�ke-----------
	  }
	}
      }
    }
    if (50<$WW[0] && $WW[0]<=99) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
      
    }

    #Premisser: T�ke, sn�fokk, isslag kornmo osv.......
    #F�rst t�ke---------------
    if ($V1[0]==18 || $V3[0]==18) {
      if (0<=$WW[0] && $WW[0]<=41) {
	if ($VV_missing[0]==0 && $VV[0]<1000) {
	  if (0<=$WW[0] && $WW[0]<=35) {
	    $WWflag=10;
	    $WWcorr=17;
	  }
	  if (36<=$WW[0] && $WW[0]<=41) {
	    $WWflag=3;
	    $V1flag=3;
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}
	if ($VV[0]>=1000) {
	  $WWflag=10;
	  $WWcorr=17;
	  if ($V3[0] == 18) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter t�ke.
	  }
	  if ($V1[0] == 18) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter t�ke.
	  }
	}
      }
    }
    #end t�ke------------
    if ($V1[0]==28 || $V3[0]==28) {
      if ((0<=$WW[0] && $WW[0]<=35) || (40<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
      }
    }
    if ($V1[0]==14 || $V3[0]==14) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }
    if ($V1[0]==29 || $V3[0]==29) {
      if ((0<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V3[0] == 29) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter kornmo.
	}
	if ($V1[0] == 29) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter kornmo.
	}
      }
    }
    if ($V1[0]==19 || $V3[0]==19) { #T�kedis
      if ((0<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($VV[0]>10000) {
	  if ($V3[0] == 19) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter 
	  }
	  if ($V1[0] == 19) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter 
	  }
	}
      }
    }
    if ($V1[0]==21 || $V3[0]==21) { ##�lr�yk
      if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V1[0]==19 && $V3[0]==21) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter
	}
	if ($V1[0]==21 && $V3[0]==19) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter
	}
      }
    }
    if ($V1[0] != 18 && $V1[0] != 28 && $V1[0] != 14 && $V1[0] != 29 && $V1[0] != 19 && $V1[0] != 21 && $V3[0] != 18 && $V3[0] != 28 && $V3[0] != 14 && $V3[0] != 29 && $V3[0] != 19 && $V3[0] != 21) { #Annet----------------------
      if (0<=$WW[0] && $WW[0]<=49) {
	$WWflag=10;
	$WWcorr=17;
      }
    }

#Hvis V3 mangler:
    if ($V3_missing[0]>0) {
      if ($V1[0] != 18 && $V1[0] != 28 && $VV_missing[0]==0 && $VV[0]<1000) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $WWflag=3;
	  $VVflag=3;
	}
      }

=comment

      if ($V1[0] != 19 && (1000<=$VV[0] && $VV_missing[0]==0 && $VV[0]<=10000)) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $V1flag=10;
	  $V1corr=19; #Setter inn t�kedis-----------
	}
      }

=cut

    }

 } #end if (($V2[0]==20) && ((12<=$V1[0] && $V1[0]<=14)..........


} #end sub komb_3_2................




sub komb_3_3 {#V3 torden, V1 (ikke-nedb�r), V2 (ikke-nedb�r)
  

 if (($V3[0]==20) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=29) || $V1_missing[0]>0) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=29) || $V2_missing[0]>0) && (0<=$WW[0] && $WW[0]<=99)) { 

=comment

#Legger inn test p� om ok...
      if ($WW[0]==17) { return;}
###

=cut

    if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=16) || (30<=$WW[0] && $WW[0]<=35)) {
      $WWflag=10;
      $WWcorr=17;
    }
    if ($WW[0]==5) {
      $WWflag=10;
      $WWcorr=17;
      if ($V1[0] != 21 && $V2[0] != 21) {
	if ($V2_missing[0]==0) {
	  $V2flag=10;
	  $V2corr=21;
	}
	if ($V1_missing[0]==0 && $V2_missing[0]>0) {
	  $V1flag=10;
	  $V1corr=21;
	}
      }
    }
    if ($WW[0]==10) { #T�kedis
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<=10000) {
	if ($V1[0] != 19 && $V2[0] != 19) {
	  if ($V2_missing[0]==0) {
	    $V2flag=10;
	    $V2corr=19; #Setter inn t�kedis-----------
	  }
	  if ($V1_missing[0]==0 && $V2_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=19; #Setter inn t�kedis-----------
	  }
	}
      }
    }
    if ($WW[0]==13) { #Lyn
      $WWflag=10;
      $WWcorr=17;
      if ($V2[0] == 29) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter kornmo.
      }
      if ($V1[0] == 29) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter kornmo.
      }
    }
    if (20<=$WW[0] && $WW[0]<=27) {
      $WWflag=10;
      $WWcorr=17;
      if ($V2[0] == 14) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter isslag.
      }
      if ($V1[0] == 14) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter isslag.
      }
      my $settinn =0;
      if ($WW[0]==20) { $settinn=8; }
      if ($WW[0]==21) { $settinn=3; }
      if ($WW[0]==22) { $settinn=2; }
      if ($WW[0]==23) { $settinn=1; }
      if ($WW[0]==24) { $settinn=14; }
      if ($WW[0]==25) { $settinn=7; }
      if ($WW[0]==26) { $settinn=5; }
      if ($WW[0]==27) { $settinn=10; }
    
      if ($V7_missing[0]==0 && $V7[0] !=$settinn) { #V7 har kommet inn
	$V7flag=10;
	$V7corr=$settinn;
      }
      if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=$settinn) {
	$V6flag=10;
	$V6corr=$settinn;
      }
      if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=$settinn) {
	$V5flag=10;
	$V5corr=$settinn;
      }
      if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=$settinn) {
	$V4flag=10;
	$V4corr=$settinn;
      }
    } # end if (20<=$WW[0] && $WW[0]<=27).......
    if ($WW[0]==28 || (40<=$WW[0] && $WW[0]<=41)) {
      $WWflag=10;
      $WWcorr=17;
      if ($V2[0] == 18) {
	$V2flag=13;
	$V2_missing[0]=2; #Sletter t�ke.
      }
      if ($V1[0] == 18) {
	$V1flag=13;
	$V1_missing[0]=2; #Sletter t�ke.
      }
    }
    if ($WW[0]==29) {
      $V3flag=13;
      $V3_missing[0]=2; #Sletter torden.
    
      #Setter inn torden i en av V4/V5/V6/V7.
      if ($V4[0]!=20 && $V5[0]!=20 && $V6[0]!=20 && $V7[0]!=20) {
	if ($V7_missing[0]==0) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=20;
	}
      } #end if ($V4[0]!=20 && $V5[0]!=20......
    }
    
    if (36<=$WW[0] && $WW[0]<=39) {
      $WWflag=10;
      $WWcorr=17;
      if ($V1[0] != 28 && $V2[0] != 28) {
	if ($V2_missing[0]==0) {
	  $V2flag=10;
	  $V2corr=28; #Setter inn sn�fokk-----------
	}
	if ($V1_missing[0]==0 && $V2_missing[0]>0) {
	  $V1flag=10;
	  $V1corr=28; #Setter inn sn�fokk-----------
	}
      }
    }
    
    if (42<=$WW[0] && $WW[0]<=49) {
      $WWflag=10;
      $WWcorr=17;
      if ($VV_missing[0]==0 && $VV[0]<1000) {
	if ($V1[0] != 18 && $V2[0] != 18) {
	  if ($V2_missing[0]==0) {
	    $V2flag=10;
	    $V2corr=18; #Setter inn t�ke-----------
	  }
	  if ($V1_missing[0]==0 && $V2_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=18; #Setter inn t�ke-----------
	  }
	}
      }
    }
    if (50<$WW[0] && $WW[0]<=99) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }

    #Premisser: T�ke, sn�fokk, isslag kornmo osv.......
    #F�rst t�ke---------------
    if ($V1[0]==18 || $V2[0]==18) {
      if (0<=$WW[0] && $WW[0]<=41) {
	if ($VV_missing[0]==0 && $VV[0]<1000) {
	  if (0<=$WW[0] && $WW[0]<=35) {
	    $WWflag=10;
	    $WWcorr=17;
	  }
	  if (36<=$WW[0] && $WW[0]<=41) {
	    $WWflag=3;
	    $V1flag=3;
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}
	if ($VV[0]>=1000) {
	  $WWflag=10;
	  $WWcorr=17;
	  if ($V2[0] == 18) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter t�ke.
	  }
	  if ($V1[0] == 18) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter t�ke.
	  }
	}
      }
    }
    #end t�ke------------
    if ($V1[0]==28 || $V2[0]==28) {
      if ((0<=$WW[0] && $WW[0]<=35) || (40<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
      }
    }
    if ($V1[0]==14 || $V2[0]==14) {
      $WWflag=3;
      $V1flag=3;
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }
    if ($V1[0]==29 || $V2[0]==29) {
      if ((0<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V2[0] == 29) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter kornmo.
	}
	if ($V1[0] == 29) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter kornmo.
	}
      }
    }
    if ($V1[0]==19 || $V2[0]==19) { #T�kedis
      if ((0<=$WW[0] && $WW[0]<=9) || (11<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($VV[0]>10000) {
	  if ($V2[0] == 19) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter 
	  }
	  if ($V1[0] == 19) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter 
	  }
	}
      }
    }
    if ($V1[0]==21 || $V2[0]==21) { ##�lr�yk
      if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=49)) { 
	$WWflag=10;
	$WWcorr=17;
	if ($V1[0]==19 && $V2[0]==21) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter
	}
	if ($V1[0]==21 && $V2[0]==19) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter
	}
      }
    }
    if ($V1[0] != 18 && $V1[0] != 28 && $V1[0] != 14 && $V1[0] != 29 && $V1[0] != 19 && $V1[0] != 21 && $V2[0] != 18 && $V2[0] != 28 && $V2[0] != 14 && $V2[0] != 29 && $V2[0] != 19 && $V2[0] != 21) { #Annet----------------------
      if (0<=$WW[0] && $WW[0]<=49) {
	$WWflag=10;
	$WWcorr=17;
      }
    }

#Hvis V2 mangler:
    if ($V2_missing[0]>0) {
      if ($V1[0] != 18 && $V1[0] != 28 && $VV_missing[0]==0 && $VV[0]<1000) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $WWflag=3;
	  $VVflag=3;
	}
      }

=comment

      if ($V1[0] != 19 && (1000<=$VV[0] && $VV_missing[0]==0 && $VV[0]<=10000)) {
	if (0<=$WW[0] && $WW[0]<=49) {
	  $V1flag=10;
	  $V1corr=19; #Setter inn t�kedis-----------
	}
      }

=cut

    }

 } #end if (($V3[0]==20) && ((12<=$V1[0] && $V1[0]<=14)..........



} #end sub komb_3_3................




###################################################









######### 23/10 Begynner med Kombinasjon 4-----------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------#Nedb�r (Nedb�r) (Nedb�r)

sub komb_4_1 { # 3 nedb�rsymboler tilstede -----

  if (((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && (0<=$WW[0] && $WW[0]<=99)) {

=comment

#Tester f�rst p� de tilfellene som er OK:
      if (($V1[0]==3 || $V1[0]==2 || $V1[0]==1 || $V2[0]==3 || $V2[0]==2 || $V2[0]==1 || $V3[0]==3 || $V3[0]==2 || $V3[0]==1) && (68<=$WW[0] && $WW[0]<=69)) {
	  return;
      }
       if (($V1[0]==8 || $V1[0]==2 || $V1[0]==1 || $V2[0]==8 || $V2[0]==2 || $V2[0]==1 || $V3[0]==8 || $V3[0]==2 || $V3[0]==1) && (68<=$WW[0] && $WW[0]<=69)) {
	  return;
      }
       if (($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V3[0]==4 || $V3[0]==5 || $V3[0]==7) && (83<=$WW[0] && $WW[0]<=84)) {
	  return;
      }
      if (($V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;
      }
      if (($V1[0]==4 || $V2[0]==4 || $V3[0]==4) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;
      }
      if (($V1[0]==7 || $V1[0]==4 || $V1[0]==11 || $V2[0]==7 || $V2[0]==4 || $V2[0]==11 || $V3[0]==7 || $V3[0]==4 || $V3[0]==11) && (89<=$WW[0] && $WW[0]<=90)) {
	  return;
      }

=cut


    if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0]==28 || $WW[0]==29 || (30<=$WW[0] && $WW[0]<=49)) {
    
  #NB Husk ta med insetting i V4-V7 ved WW=24, 28, 29-----------------------------
    
      if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) {
	$WWflag=10;
	$WWcorr=50;
      }
      if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
        $WWflag=10;
	$WWcorr=60;
      }
      if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
        $WWflag=10;
	$WWcorr=68;
      }
      if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
        $WWflag=10;
	$WWcorr=70;
      }
      if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
        $WWflag=10;
	$WWcorr=76;
      }
      if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
        $WWflag=10;
	$WWcorr=77;
      }
      if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
        $WWflag=10;
	$WWcorr=79;
      }
      if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
        $WWflag=10;
	$WWcorr=80;
      }
      if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
        $WWflag=10;
	$WWcorr=83;
      }
      if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
        $WWflag=10;
	$WWcorr=85;
      }
      if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
        $WWflag=10;
	$WWcorr=87;
      }
      if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
        $WWflag=10;
	$WWcorr=89;
      }
      
      #Til V4-V7--------------------------------------
      if ($WW[0]==24) {
	if ($V7[0] !=14 && $V6[0] !=14 && $V5[0] !=14 && $V4[0] !=14) {
	  if ($V7_missing[0]==0) { #V7 har kommet inn
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=14;
	}
	}
      }
    
      if ($WW[0]==28) {
	if ($V7[0] !=18 && $V6[0] !=18 && $V5[0] !=18 && $V4[0] !=18) {
	if ($V7_missing[0]==0 && $V7[0] !=18) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=18;
	}
      }
      }
      
      if ($WW[0]==29) {
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0 && $V7[0] !=20) { #V7 har kommet inn
		  $V7flag=10;
		  $V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=20) {
		  $V6flag=10;
		  $V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=20) {
		  $V5flag=10;
		  $V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=20) {
		  $V4flag=10;
		  $V4corr=20;
	      }
	  }
      }
      
  

      if (42<=$WW[0] && $WW[0]<=49) {
	  my $taakeja=0;
	  if ($VV_missing[0]==0 && $VV[0]<1000) {
	      if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) { #Yr
		  $WWflag=10;
		  $WWcorr=50;$taakeja=1;
	      }
	      if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
		  $WWflag=10;
		  $WWcorr=60;$taakeja=1;
	      }
	      if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
		  $WWflag=10;
		  $WWcorr=68;$taakeja=1;
	      }
	      if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
		  $WWflag=10;
		  $WWcorr=70;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	      if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
		  $WWflag=10;
		  $WWcorr=76;$taakeja=1;
	      }
	      if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
		  $WWflag=10;
		  $WWcorr=77;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	      if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
		  $WWflag=10;
		  $WWcorr=79;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	      if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
		  $WWflag=10;
		  $WWcorr=80;$taakeja=1;
	      }
	      if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
		  $WWflag=10;
		  $WWcorr=83;$taakeja=1;
	      }
	      if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
		  $WWflag=10;
		  $WWcorr=85;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	      if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
		  $WWflag=10;
		  $WWcorr=87;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	      if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
		  $WWflag=10;
		  $WWcorr=89;
		  if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
						     }
	      }
	
=comment
    
	      #Setter inn t�ke---------------
	      if ($V3_missing[0]==0 && $V3[0] !=18 && $V2[0] !=18 && $V1[0] !=18 && $taakeja==1) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=18; #Sett t�ke
	      }
	      
=cut
	      
	  } #End if $VV_missing[0]==0 && VV<1000

=comment
	  
	  if (1000<=$VV[0] && $VV_missing[0]==0 && $VV[0]<=10000) {
	      #Setter inn t�kedis---------------
	      if ($V1[0]!=19 && $V2[0]!=19 && $V3[0]!=19) {
		  if ($V3_missing[0]==0) { #V3 har kommet inn
		      $V3flag=10;
		      $V3corr=19; #Setter inn t�kedis
		  }
	      }
	  }

=cut

      }#End if (42<=$WW[0] && $WW[0]<=49) 
      } #end if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0]==28 || $WW


#Her blir det andre flagginger----------------

	if ($WW[0]==15 || $WW[0]==16 || $WW[0]==18 || $WW[0]==19) {
	    $WWflag=3;
	    $V1flag=3;
	    $V2flag=3;
	    $V3flag=3;
	}
    
    if ($WW[0]==17) {
	if ($V3_missing[0]==0 && $V3[0] !=20) { #V7 har kommet inn
	    $V3flag=10;
	    $V3corr=20; #Sett torden
	}
	if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=20) {
	    $V2flag=10;
	    $V2corr=20;
	}
	if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $V1[0] !=20) {
	    $V1flag=10;
	    $V1corr=20;
	}
    }
    if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
        #Sletter all nedb�r---------------
	$V1flag=13;
	$V1_missing[0]=2;
	$V2flag=13;
	$V2_missing[0]=2;
	$V3flag=13;
	$V3_missing[0]=2;

	my $settinn =0;
	if ($WW[0]==20) { $settinn=8; }
	if ($WW[0]==21) { $settinn=3; }
	if ($WW[0]==22) { $settinn=2; }
	if ($WW[0]==23) { $settinn=1; }
	if ($WW[0]==25) { $settinn=7; }
	if ($WW[0]==26) { $settinn=5; }
	if ($WW[0]==27) { $settinn=10; }
	

	    if ($V7_missing[0]==0 && $V7[0] !=$settinn) { #V7 har kommet inn
		$V7flag=10;
		$V7corr=$settinn;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=$settinn) {
		$V6flag=10;
		$V6corr=$settinn;
	    }
	    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=$settinn) {
		$V5flag=10;
		$V5corr=$settinn;
	    }
	    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=$settinn) {
		$V4flag=10;
		$V4corr=$settinn;
	    }
    } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))


     
    

#Videre under 3 symboler------------------
   if (50<=$WW[0] && $WW[0]<=94) {
     #----------S� tar vi ikke-byge, ikke-byge, byge, WW=50-94 under 3 symboler.------------- 
     #V1 ikke-byge, V2 ikke-byge, V3 byge.
     if  (($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
      #V1 byge, V2 ikke-byge, V3 ikke-byge.
     if  (($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
      #V1 ikke-byge, V2 byge, V3 ikke-byge.
     if  (($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }

     #V1 ikke-byge, V2 byge, V3 byge.
     if (($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
     #V1 byge, V2 ikke-byge, V3 byge.
     if (($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
     #V1 byge, V2 byge, V3 ikke-byge.
     if (($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
      $WWflag=3;
      $V1flag=3;
      $V2flag=3;
      $V3flag=3;
    }
   } #end  if (50<=$WW[0] && $WW[0]<=94)

} #end  if (((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V2[0] &
  
} #end sub komb_4_1 ---------------------------------------




sub komb_4_2 { # 2 symboler nedb�r tilstede, 1 symbol ikke-nedb�r eller manglende ---------Enten V1 og V2, V1 og V3 eller V2 og V3.
    if ((((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ($V3_missing[0]>0 || (12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29))) || 
(((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && ($V2_missing[0]>0 || (12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29))) || 
(((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && ($V1_missing[0]>0 || (12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29))))  {
	    

#Alts� 2 nedb�rsymboler og 1 symbol manglende eller ikke-nedb�r.
#I tilfellet den siste ikke-nedb�r er dette komb. 5 (2 nedb�rsymboler).
#-------------------------------------------

# Legger inn test p� ok-tilfeller----------

=comment
 
 if (($V1[0]==8 || $V1[0]==3 || $V2[0]==8 || $V2[0]==3 || $V3[0]==8 || $V3[0]==3) && (58<=$WW[0] && $WW[0]<=59)) {
	  return;}
 if (($V1[0]==3 || $V1[0]==1 || $V2[0]==3 || $V2[0]==1 || $V3[0]==3 || $V3[0]==1) && (60<=$WW[0] && $WW[0]<=67)) {
	  return;}
if (($V1[0]==3 || $V1[0]==2 || $V2[0]==3 || $V2[0]==2 || $V3[0]==3 || $V3[0]==2) && (68<=$WW[0] && $WW[0]<=69)) {
	  return;}
if (($V1[0]==1 || $V1[0]==2 || $V2[0]==1 || $V2[0]==2 || $V3[0]==1 || $V3[0]==2) && (68<=$WW[0] && $WW[0]<=69)) {
	  return;}
if (($V1[0]==1 || $V1[0]==2 || $V2[0]==1 || $V2[0]==2 || $V3[0]==1 || $V3[0]==2) && (70<=$WW[0] && $WW[0]<=79)) {
	  return;}
if (($V1[0]==1 || $V1[0]==2 || $V2[0]==1 || $V2[0]==2 || $V3[0]==1 || $V3[0]==2) && (80<=$WW[0] && $WW[0]<=82)) {
	  return;}
if (($V1[0]==7 || $V1[0]==4 || $V2[0]==7 || $V2[0]==4 || $V3[0]==7 || $V3[0]==4) && (83<=$WW[0] && $WW[0]<=84)) {
	  return;}
if (($V1[0]==4 || $V1[0]==5 || $V2[0]==4 || $V2[0]==5 || $V3[0]==4 || $V3[0]==5) && (85<=$WW[0] && $WW[0]<=86)) {
	  return;}
if (($V1[0]==10 || $V1[0]==7 || $V2[0]==10 || $V2[0]==7 || $V3[0]==10 || $V3[0]==7) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;}
if (($V1[0]==10 || $V1[0]==7 || $V2[0]==10 || $V2[0]==7 || $V3[0]==10 || $V3[0]==7) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;}
if (($V1[0]==10 || $V1[0]==9 || $V2[0]==10 || $V2[0]==9 || $V3[0]==10 || $V3[0]==9) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;}
if (($V1[0]==4 || $V2[0]==4 || $V3[0]==4) && (87<=$WW[0] && $WW[0]<=88)) {
	  return;}
if (($V1[0]==11 || $V2[0]==11 || $V3[0]==11) && (89<=$WW[0] && $WW[0]<=90)) {
	  return;}
if (($V1[0]==7 || $V2[0]==7 || $V3[0]==7) && (89<=$WW[0] && $WW[0]<=90)) {
	  return;}
if (($V1[0]==4 || $V2[0]==4 || $V3[0]==4) && (89<=$WW[0] && $WW[0]<=90)) {
	  return;}


=cut

#####

	    
	if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0]==28 || $WW[0]==29 || (30<=$WW[0] && $WW[0]<=49)) {
	    #NB Husk ta med insetting i V4-V7 ved WW=24, 28, 29-----------------------------
	
	    if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) {
		$WWflag=10;
		$WWcorr=50;
	    }
	    if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
		$WWflag=10;
		$WWcorr=60;
	    }
	    if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
		$WWflag=10;
		$WWcorr=68;
	    }
	    if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
		$WWflag=10;
		$WWcorr=70;
	    }
	    if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
		$WWflag=10;
		$WWcorr=76;
	    }
	    if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
		$WWflag=10;
		$WWcorr=77;
	    }
	    if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
		$WWflag=10;
		$WWcorr=79;
	    }
	    if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
		$WWflag=10;
		$WWcorr=80;
	    }
	    if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
		$WWflag=10;
		$WWcorr=83;
	    }
	    if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
		$WWflag=10;
		$WWcorr=85;
	    }
	    if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
		$WWflag=10;
		$WWcorr=87;
	    }
	    if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
		$WWflag=10;
		$WWcorr=89; #Setter WW=89.
	    }
	    
	    #Til V4-V7--------------------------------------
	    if ($WW[0]==24) {
		if ($V7[0] !=14 && $V6[0] !=14 && $V5[0] !=14 && $V4[0] !=14) {
		    if ($V7_missing[0]==0) { #V7 har kommet inn
			$V7flag=10;
			$V7corr=14;
		    }
		    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
			$V6flag=10;
			$V6corr=14;
		    }
		    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
			$V5flag=10;
			$V5corr=14;
		    }
		    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
			$V4flag=10;
			$V4corr=14;
		    }
		}
	    }

	    if ($WW[0]==28) {
		if ($V7[0]!=18 && $V6[0]!=18 && $V5[0]!=18 && $V4[0]!=18) {
		    if ($V7_missing[0]==0 && $V7[0] !=18) { #V7 har kommet inn
			$V7flag=10;
			$V7corr=18;
		    }
		    if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=18) {
			$V6flag=10;
			$V6corr=18;
		    }
		    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=18) {
			$V5flag=10;
			$V5corr=18;
		    }
		    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=18) {
			$V4flag=10;
			$V4corr=18;
		    }
		}
	    }
	    
	    if ($WW[0]==29) {
		
		if ($V7[0]!=20 && $V6[0]!=20 && $V5[0]!=20 && $V4[0]!=20) {
		    if ($V7_missing[0]==0 && $V7[0] !=20) { #V7 har kommet inn
			$V7flag=10;
			$V7corr=20;
		    }
		    if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=20) {
			$V6flag=10;
			$V6corr=20;
		    }
		    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=20) {
			$V5flag=10;
			$V5corr=20;
		    }
		    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=20) {
			$V4flag=10;
			$V4corr=20;
		    }
		}
	    }

	    if (42<=$WW[0] && $WW[0]<=49) {
		my $taakeja=0;
		if ($VV_missing[0]==0 && $VV[0]<1000) {
		    if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) { #Yr
			$WWflag=10;
			$WWcorr=50;$taakeja=1;
		    }
		    if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
			$WWflag=10;
			$WWcorr=60;$taakeja=1;
		    }
		    if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
			$WWflag=10;
			$WWcorr=68;$taakeja=1;
		    }
		    if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
			$WWflag=10;
			$WWcorr=70;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }
		    if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
			$WWflag=10;
			$WWcorr=76;$taakeja=1;
		    }
		    if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
			$WWflag=10;
			$WWcorr=77;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }
		    if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
			$WWflag=10;
			$WWcorr=79;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }
		    if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
			$WWflag=10;
			$WWcorr=80;$taakeja=1;
		    }
		    if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
			$WWflag=10;
			$WWcorr=83;$taakeja=1;
		    }
		    if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
			$WWflag=10;
			$WWcorr=85;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }
		    if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
			$WWflag=10;
			$WWcorr=87;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }
		    if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
			$WWflag=10;
			$WWcorr=89;
			if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
							   }
		    }

=comment
	  
		    #Setter inn t�ke---------------
		    if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
			if ($taakeja==1) { #V3 har kommet inn
			    $V3flag=10;
			    $V3corr=18; #Sett t�ke
			}



			if ($V2_missing[0]==0 && $V3_missing[0]>0 && $taakeja==1) {
			    $V2flag=10;
			    $V2corr=18;
			}
			if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $taakeja==1) {
			    $V1flag=10;
			    $V1corr=18;
			}



		    }

=cut

		} #End if VV<1000
	
###Alts� vi setter bare inn t�ke/t�kedis hvis alle symboler er kommet inn og er forskjellige fra t�ke/t�kedis. NEI, har ingen mulighet til � sette inn nye symboler (bare korrigere p� eksisterende), s� denne tar vi ut.

=comment
	
		if (1000<=$VV[0] && $VV[0]<=10000) {
		    #Setter inn t�kedis---------------
		    if ($V1[0]!=19 && $V2[0]!=19 && $V3[0]!=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
			if ($V3_missing[0]==0) { #V3 har kommet inn
			    $V3flag=10;
			    $V3corr=19; #Setter inn t�kedis
			}



			if ($V2_missing[0]==0 && $V3_missing[0]>0) {
			    $V2flag=10;
			    $V2corr=19; #Setter inn t�kedis
			}
			if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
			    $V1flag=10;
			    $V1corr=19; #Setter inn t�kedis
			}


		    }
		}

=cut

	    } #End if (42<=$WW[0] && $WW[0]<=49) 

	} #end if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0]==28 || $WW[0]==29 |

########
      
	if ($WW[0]==15 || $WW[0]==16 || $WW[0]==18 || $WW[0]==19) {
	    $WWflag=3;
	    if ($V1_missing[0]==0) {$V1flag=3; }
	    if ($V2_missing[0]==0) {$V2flag=3; }
	    if ($V3_missing[0]==0) {$V3flag=3; }	
        }
	
	if ($WW[0]==17) {
	    if ($V3[0]!=20 && $V2[0]!=20 && $V1[0]!=20) {
		if ($V3_missing[0]==0) { #V7 har kommet inn
		    $V3flag=10;
		    $V3corr=20; #Sett torden
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=20;
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		    $V1flag=10;
		    $V1corr=20;
		}
	    }
	}
	
	if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
	    #Sletter all nedb�r---------------
	    if ($V1_missing[0]==0) { #Hvis verdien har kommet inn
		$V1flag=13;
		$V1_missing[0]=2; }
	    if ($V2_missing[0]==0) {
		$V2flag=13;
		$V2_missing[0]=2;}
	    if ($V3_missing[0]==0) {
		$V3flag=13;
		$V3_missing[0]=2; }
	    
	    my $settinn =0;
	    if ($WW[0]==20) { $settinn=8; }
	    if ($WW[0]==21) { $settinn=3; }
	    if ($WW[0]==22) { $settinn=2; }
	    if ($WW[0]==23) { $settinn=1; }
	    if ($WW[0]==25) { $settinn=7; }
	    if ($WW[0]==26) { $settinn=5; }
	    if ($WW[0]==27) { $settinn=10; }
	    
	    if ($V7[0]!= $settinn && $V6[0]!= $settinn && $V5[0]!= $settinn && $V4[0]!= $settinn)
	    {
		if ($V7_missing[0]==0) { #V7 har kommet inn
		    $V7flag=10;
		    $V7corr=$settinn;
		}
		if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		    $V6flag=10;
		    $V6corr=$settinn;
		}
		if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
		    $V5flag=10;
		    $V5corr=$settinn;
		}
		if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
		    $V4flag=10;
		    $V4corr=$settinn;
		}
	    }
	} #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))
	

     #end if (((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V2[0] &
# Obs her ender den aller f�rste if-en!!!!!!
######################################################
#####--------###########-------------#################






#------------Fortsatt komb_4_2------------------------------
#------------S� g�r vi l�s p� Ikke-byge, byge---------------
#------------WW=50-79 osv........

#V1 ikke-byge, V2 byge, V3 manglende og de andre komb.
# byge, mangl eller ikke-nedb�r, ikke-byge
#mangl eller ikke-nedb�r, ikke-byge, byge
#ikke-byge, mangl eller ikke-nedb�r, byge
# byge, ikke-byge, mangl eller ikke-nedb�r 
#mangl eller ikke-nedb�r, byge, ikke-byge


#Komb.5-6 i speken.. g�r ogs� inn her.. Nedb�r, ikke-nedb�r, dvs. 
#Her har vi ogs� dekket ikke-byge,byge og ikke-nedb�r.


#Obs har valget om vi skal ta denne med eller ikke..........
#Den f�rste if-en (under sub 4_2) g�r n� over hele.

    if ((($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V3_missing[0]>0 || (12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29))) || 
(($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V2_missing[0]>0 || (12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29))) || 
(($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && ($V1_missing[0]>0 || (12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29))) || 
(($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]==15 || $V1[0]==16) && ($V3[0]==4 || $V3[0]==5 || $V3[0]==7 || $V3[0]==9 || $V3[0]==10 || $V3[0]==11) && ($V2_missing[0]>0 || (12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29))) || 
(($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==6 || $V2[0]==8 || $V2[0]==15 || $V2[0]==16) && ($V1[0]==4 || $V1[0]==5 || $V1[0]==7 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) && ($V3_missing[0]>0 || (12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29))) || 
(($V3[0]==1 || $V3[0]==2 || $V3[0]==3 || $V3[0]==6 || $V3[0]==8 || $V3[0]==15 || $V3[0]==16) && ($V2[0]==4 || $V2[0]==5 || $V2[0]==7 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11) && ($V1_missing[0]>0 || (12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)))) {

    ###----WW Fra 50-90----------------------------------------------------
	if (50<=$WW[0] && $WW[0]<=90) {

#50-57
	    if (50<=$WW[0] && $WW[0]<=57) {
		my $yrsettinn="true";
		#Setter inn yr---------------
		# Sjekker om det finnes fra f�r av:
		
		if ($V3_missing[0]==0 && $V3[0] ==8) {
		    $yrsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==8) {
		    $yrsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==8) {
		    $yrsettinn="false"; }
		
		if ($V3_missing[0]==0 && $yrsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=8; #Setter inn yr
		    if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==7 || $V2[0]==4 || $V2[0]==5)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==7 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $yrsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=8; #Setter inn yr
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==7 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $yrsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=8; #Setter inn yr
		}
	    } #end if (50<=$WW[0] && $WW[0]<=57)
	    
#58-59
	    if (58<=$WW[0] && $WW[0]<=59) {
		my $yrsettinn2="true";
		#Setter inn yr---------------
		# Hvis det ikke finnes fra f�r av:
		
		if ($V3_missing[0]==0 && $V3[0] ==8) {
		    $yrsettinn2="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==8) {
		    $yrsettinn2="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==8) {
		    $yrsettinn2="false"; }
		
		if ($V3_missing[0]==0 && $yrsettinn2 eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=8; #Sett inn yr
		    if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==4 || $V2[0]==5)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $yrsettinn2 eq "true") {
		    $V2flag=10;
		    $V2corr=8;
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $yrsettinn2 eq "true") {
		    $V1flag=10;
		    $V1corr=8;
		}
	    } #end if (58<=$WW[0] && $WW[0]<=59)
	    
#60-67
	    if (60<=$WW[0] && $WW[0]<=67) {
		#Setter inn regn---------------
		# Hvis det ikke finnes fra f�r av:
		my $regnsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==3) {
		    $regnsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==3) {
		    $regnsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==3) {
		    $regnsettinn="false"; }
		
		if ($V3_missing[0]==0 && $regnsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=3; #Setter inn regn
		    if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==8 || $V2[0]==4 || $V2[0]==5)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==8 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $regnsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=3; #Setter inn regn
		    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==8 || $V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $regnsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=3;
		}
	    } #end if (60<=$WW[0] && $WW[0]<=67)
	    
# 70-79
	    if (70<=$WW[0] && $WW[0]<=79){
		my $rette =0;
		if (70<=$WW[0] && $WW[0]<=75) { $rette=2; } #Setter inn sn�
		if ($WW[0]==76) { $rette=16; }              #Setter inn isn�ler
		if ($WW[0]==77 || $WW[0]==78) { $rette=6; } #Setter inn kornsn�
		if ($WW[0]==79) { $rette=15; }              #Setter inn iskorn
		
		#Setter inn diverse (etter kode)---------------
		# Hvis det ikke finnes fra f�r av:
		my $diverse="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==$rette) {
		    $diverse="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==$rette) {
		    $diverse="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==$rette) {
		    $diverse="false"; }

		if ($V3_missing[0]==0 && $diverse eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=$rette; #Setter inn etter WW-koden.... 
		    if ($V2_missing[0]==0 && ($V2[0]==8 || $V2[0]==3 || $V2[0]==7)) { #Sletter yr, regn (og regnbyge)
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==8 || $V1[0]==3 || $V1[0]==7)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}

		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $diverse eq "true") {
		    $V2flag=10;
		    $V2corr=$rette; #Setter inn 
		    if ($V1_missing[0]==0 && ($V1[0]==8 || $V1[0]==3 || $V1[0]==7)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $diverse eq "true") {
		    $V1flag=10;
		    $V1corr=$rette;
		}
	    } #end if (70<=$WW[0] && $WW[0]<=79)
	    
# 80-82
	    if (80<=$WW[0] && $WW[0]<=82) {
		#Setter inn regnbyge---------------
		# Hvis det ikke finnes fra f�r av:
		my $regnbsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==7) {
		    $regnbsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==7) {
		    $regnbsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==7) {
		    $regnbsettinn="false"; }
		

		if ($V3_missing[0]==0 && $regnbsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=7; #Setter inn regnbyge
		    if ($V2_missing[0]==0 && ($V2[0]==4 || $V2[0]==5)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $regnbsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=7; #Setter inn regnbyge
		    if ($V1_missing[0]==0 && ($V1[0]==4 || $V1[0]==5)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}

		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $regnbsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=7;
		}
	    } #end if (80<=$WW[0] && $WW[0]<=82)
	    
#83-84
	    if (83<=$WW[0] && $WW[0]<=84) {
		#Setter inn sluddbyge---------------
		# Hvis det ikke finnes fra f�r av:
		my $sluddbsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==4) {
		    $sluddbsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==4) {
		    $sluddbsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==4) {
		    $sluddbsettinn="false"; }
		
		if ($V3_missing[0]==0 && $sluddbsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=4; #Setter inn sluddbyge
		    if ($V2_missing[0]==0 && ($V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $sluddbsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=4; #Setter inn sluddbyge
		    if ($V1_missing[0]==0 && ($V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $sluddbsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=4;
		}
	    } #end if (83<=$WW[0] && $WW[0]<=84)
	    
#WW=85,86
	    if (85<=$WW[0] && $WW[0]<=86) {
		#Setter inn sn�byge---------------
		# Hvis det ikke finnes fra f�r av:
		my $snobsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==5) {
		    $snobsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==5) {
		    $snobsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==5) {
		    $snobsettinn="false"; }
		
		if ($V3_missing[0]==0 && $snobsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=5; #Setter inn sn�byge
		    if ($V2_missing[0]==0 && ($V2[0]==3 || $V2[0]==1 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==3 || $V1[0]==1 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $snobsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=5; #Setter inn sn�byge
		    if ($V1_missing[0]==0 && ($V1[0]==3 || $V1[0]==1 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $snobsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=5;
		}
	    } #end if (85<=$WW[0] && $WW[0]<=86)
	    
#WW=87,88
	    if (87<=$WW[0] && $WW[0]<=88) {
		#Setter inn hagl---------------
		# Hvis det ikke finnes fra f�r av:
		my $haglsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==10) {
		    $haglsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==10) {
		    $haglsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==10) {
		    $haglsettinn="false"; }
		
		if ($V3_missing[0]==0 && $haglsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=10; #Setter inn haglbyge
		    if ($V2_missing[0]==0 && ($V2[0]==5 || $V2[0]==11)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $haglsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=10; #Setter inn hagl
		    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==11)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $haglsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=10;
		}
	    } #end if (87<=$WW[0] && $WW[0]<=88)
	    
#WW=89,90
	    if (89<=$WW[0] && $WW[0]<=90) {
		#Setter inn ishagl---------------
		# Hvis det ikke finnes fra f�r av:
		my $ishaglsettinn="true";
		
		if ($V3_missing[0]==0 && $V3[0] ==11) {
		    $ishaglsettinn="false"; }
		if ($V2_missing[0]==0 && $V2[0] ==11) {
		    $ishaglsettinn="false"; }
		if ($V1_missing[0]==0 && $V1[0] ==11) {
		    $ishaglsettinn="false"; }
		
		if ($V3_missing[0]==0 && $ishaglsettinn eq "true") { #V3 har kommet inn
		    $V3flag=10;
		    $V3corr=11; #Setter inn ishagl
		    if ($V2_missing[0]==0 && ($V2[0]==5 || $V2[0]==10 || $V2[0]==9)) {
			$V2flag=13;
			$V2_missing[0]=2; #Sletter V2
		    }
		    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==10 || $V1[0]==9)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}
		
		if ($V2_missing[0]==0 && $V3_missing[0]>0 && $ishaglsettinn eq "true") {
		    $V2flag=10;
		    $V2corr=11; #Setter inn ishagl
		    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==10 || $V1[0]==9)) {
			$V1flag=13;
			$V1_missing[0]=2; #Sletter V1
		    }
		}

		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $ishaglsettinn eq "true") {
		    $V1flag=10;
		    $V1corr=11;
		}
	    } #end if (89<=$WW[0] && $WW[0]<=90)

=comment
	    
	    #S� tar vi hensyn til sikt:
	    if (50<=$WW[0] && $WW[0]<=79) { #Enda mer sjekking, tar hensyn til sikten ogs�....
		if ($VV_missing[0]==0 && $VV[0]<1000) {
		    if ((50<=$WW[0] && $WW[0]<=53) || (56<=$WW[0] && $WW[0]<=71) || (76<=$WW[0] && $WW[0]<=79)) {
			
			if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
			    if ($V3_missing[0]==0) {
				$V3flag=10;
				$V3corr=18; #Setter inn t�ke-----------
			    }
			    

				
         if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=18; #Setter inn t�ke-----------
         }
	 if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=18; #Setter inn t�ke-----------
	 }
			    
	

}
		    }
		    if (54<=$WW[0] && $WW[0]<=55) {
			if ($VV_missing[0]==0 && $VV[0]<=400) {
			    #Setter inn t�ke.
			    if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
				if ($V3_missing[0]==0) {
				    $V3flag=10;
				    $V3corr=18; #Setter inn t�ke-----------
				}



				if ($V2_missing[0]==0 && $V3_missing[0]>0) {
				    $V2flag=10;
				    $V2corr=18; #Setter inn t�ke-----------
				}
				if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
				    $V1flag=10;
				    $V1corr=18; #Setter inn t�ke-----------
				}



			    }
			}
		    }
		    
		    if (72<=$WW[0] && $WW[0]<=75) {
			if ($VV_missing[0]==0 && $VV[0]<=200) {
			    #Setter inn t�ke.
			    if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
				if ($V3_missing[0]==0) {
				    $V3flag=10;
				    $V3corr=18; #Setter inn t�ke-----------
				}



				if ($V2_missing[0]==0 && $V3_missing[0]>0) {
				    $V2flag=10;
				    $V2corr=18; #Setter inn t�ke-----------
				}
				if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
				    $V1flag=10;
				    $V1corr=18; #Setter inn t�ke-----------
				}
	


             		    }
			} 
		    } #end if (72<=$WW[0] && $WW[0]<=75)
		} #end if VV<1000
	    }#end if (50<=$WW[0] && $WW[0]<=79)

=cut

	    } #end if (50<=$WW[0] && $WW[0]<=90) {
   # } # end if ((($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 ||


}#end if ((($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==6 || $V1[0]==8 || $V1[0]=
}  #end if (((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((1<=$V2[0] &
} #end sub komb_4_2 -----





sub komb_4_3 {

#---------Da begynner vi p� kun 1 nedb�rsymbol og 2 ikke-nedb�r eller 2 manglende----------------
#Obs, men denne vil ogs� sl� til p� 1 nedb�rsymbol, 1 ikke-nedb�r og ett manglende! #Denne linjen lagt til etterp�.

#---------Siste p� komb. 4------------------------------
#Tar ogs� komb_5-6:  1 nedb�rsymbol, ikke-nedb�r, ikke-nedb�r


  if ((((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ($V2_missing[0]>0 || (12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)) && ($V3_missing[0]>0 || (12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29))) || 
(((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ($V1_missing[0]>0 || (12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)) && ($V3_missing[0]>0 || (12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29))) || 
(((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && ($V1_missing[0]>0 || (12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)) && ($V2_missing[0]>0 || (12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)))) 

  {

=comment
    
#Legger inn en test p� ok tilfeller, da hopper vi ut av denne subrutinen.
    if (($V1[0]==2 || $V2[0]==2 || $V3[0]==2) && ((70<=$WW[0] && $WW[0]<=75) || $WW[0] == 78)) {
	return; } #Sn�
if (($V1[0]==7 || $V2[0]==7 || $V3[0]==7) && (80<=$WW[0] && $WW[0]<=82)) {
	return; } #Regnbyge
if (($V1[0]==4 || $V2[0]==4 || $V3[0]==4) && (83<=$WW[0] && $WW[0]<=84)) {
	return; } #Sluddbyge
if (($V1[0]==5 || $V2[0]==5 || $V3[0]==5) && (85<=$WW[0] && $WW[0]<=86)) {
	return; } #Sn�byger
if (($V1[0]==10 || $V2[0]==10 || $V3[0]==10) && (87<=$WW[0] && $WW[0]<=88)) {
	return; } #Hagl
if (($V1[0]==9 || $V2[0]==9 || $V3[0]==9) && (87<=$WW[0] && $WW[0]<=88)) {
	return; } #Spr�hagl
if (($V1[0]==11 || $V2[0]==11 || $V3[0]==11) && (89<=$WW[0] && $WW[0]<=90)) {
	return; } #Ishagl
if (($V1[0]==8 || $V2[0]==8 || $V3[0]==8) && (50<=$WW[0] && $WW[0]<=57)) {
	return; } #Yr
if (($V1[0]==3 || $V2[0]==3 || $V3[0]==3) && (60<=$WW[0] && $WW[0]<=67)) {
	return; } #Regn
if (($V1[0]==1 || $V2[0]==1 || $V3[0]==1) && (68<=$WW[0] && $WW[0]<=69)) {
	return; } #Sludd
if (($V1[0]==16 || $V2[0]==16 || $V3[0]==16) && $WW[0]==76) {
	return; } #Isn�ler
if (($V1[0]==6 || $V2[0]==6 || $V3[0]==6) && $WW[0]==77) {
	return; } #Kornsn�
if (($V1[0]==15 || $V2[0]==15 || $V3[0]==15) && $WW[0]==79) {
	return; } #Iskorn

=cut


    if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0]==28 || $WW[0]==29 || (30<=$WW[0] && $WW[0]<=49)) {
      #NB Husk ta med insetting i V4-V7 ved WW=24, 28, 29-----------------------------
      
      if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) {
	$WWflag=10;
	$WWcorr=50;
      }
      if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
        $WWflag=10;
	$WWcorr=60;
      }
      if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
        $WWflag=10;
	$WWcorr=68;
      }
      if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
        $WWflag=10;
	$WWcorr=70;
      }
      if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
        $WWflag=10;
	$WWcorr=76;
      }
      if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
        $WWflag=10;
	$WWcorr=77;
      }
      if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
        $WWflag=10;
	$WWcorr=79;
      }
      if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
        $WWflag=10;
	$WWcorr=80;
      }
      if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
        $WWflag=10;
	$WWcorr=83;
      }
      if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
        $WWflag=10;
	$WWcorr=85;
      }
      if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
        $WWflag=10;
	$WWcorr=87;
      }
      if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
        $WWflag=10;
	$WWcorr=89; #Setter WW=89.
      }
	
	 #Til V4-V7--------------------------------------
      if ($WW[0]==24) {
	if ($V7[0] !=14 && $V6[0] !=14 && $V5[0] !=14 && $V4[0] !=14) {
	  if ($V7_missing[0]==0) { #V7 har kommet inn
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=14;
	}
	}
      }

	
      if ($WW[0]==28) {
	if ($V7[0]!=18 && $V6[0]!=18 && $V5[0]!=18 && $V4[0]!=18) {
	if ($V7_missing[0]==0 && $V7[0] !=18) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=18;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=18) {
	  $V6flag=10;
	  $V6corr=18;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=18) {
	  $V5flag=10;
	  $V5corr=18;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=18) {
	  $V4flag=10;
	  $V4corr=18;
	}
      }
      }
      
      if ($WW[0]==29) {
	if ($V7[0]!=20 && $V6[0]!=20 && $V5[0]!=20 && $V4[0]!=20) {
	if ($V7_missing[0]==0 && $V7[0] !=20) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=20) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=20) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=20) {
	  $V4flag=10;
	  $V4corr=20;
	}
      }
      }


      if (42<=$WW[0] && $WW[0]<=49) {
	  my $taakeja=0;
	  if ($VV_missing[0]==0 && $VV[0]<1000) {
	    if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) { #Yr
	      $WWflag=10;
	      $WWcorr=50;$taakeja=1;
	    }
	    if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
	      $WWflag=10;
	    $WWcorr=60;$taakeja=1;
	  }
	  if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
	    $WWflag=10;
	    $WWcorr=68;$taakeja=1;
	  }
	  if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
	    $WWflag=10;
	    $WWcorr=70;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
	    $WWflag=10;
	    $WWcorr=76;$taakeja=1;
	  }
	  if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
	    $WWflag=10;
	    $WWcorr=77;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
	    $WWflag=10;
	    $WWcorr=79;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
	    $WWflag=10;
	    $WWcorr=80;$taakeja=1;
	  }
	  if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
	    $WWflag=10;
	    $WWcorr=83;$taakeja=1;
	  }
	  if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
	    $WWflag=10;
	    $WWcorr=85;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
	    $WWflag=10;
	    $WWcorr=87;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
	    $WWflag=10;
	    $WWcorr=89;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }

=comment
	  
	  #Setter inn t�ke---------------
	  if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	  if ($taakeja==1) { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=18; #Sett t�ke
	  }
	 
	}

=cut

	} #End if VV<1000
	
=comment

	if (1000<=$VV[0] && $VV[0]<=10000) {
	  #Setter inn t�kedis---------------
	  if ($V1[0]!=19 && $V2[0]!=19 && $V3[0]!=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	    if ($V3_missing[0]==0) { #V3 har kommet inn
	      $V3flag=10;
	      $V3corr=19; #Setter inn t�kedis
	    }
	   
	  }
	}

=cut

	} #End if (42<=$WW[0] && $WW[0]<=49) 
 } #end if ((0<=$WW[0] && $WW[0]<=14) || $WW[0]==24 || $WW[0

############
	if ($WW[0]==15 || $WW[0]==16 || $WW[0]==18 || $WW[0]==19) {
	  $WWflag=3;
	  if ($V1_missing[0]==0) {$V1flag=3; }
	  if ($V2_missing[0]==0) {$V2flag=3; }
	  if ($V3_missing[0]==0) {$V3flag=3; }	
	}
	
	if ($WW[0]==17) {
	if ($V3[0]!=20 && $V2[0]!=20 && $V1[0]!=20) {
	  if ($V3_missing[0]==0) { #V7 har kommet inn
	    $V3flag=10;
	    $V3corr=20; #Sett torden
	  }
	  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=20;
	  }
	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=20;
	  }
	}
      }


 if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
        #Sletter all nedb�r---------------
	if ($V1_missing[0]==0) { #Hvis verdien har kommet inn
	  $V1flag=13;
	  $V1_missing[0]=2; }
	if ($V2_missing[0]==0) {
	  $V2flag=13;
	  $V2_missing[0]=2;}
	if ($V3_missing[0]==0) {
	  $V3flag=13;
	  $V3_missing[0]=2; }

	my $settinn =0;
	if ($WW[0]==20) { $settinn=8; }
	if ($WW[0]==21) { $settinn=3; }
	if ($WW[0]==22) { $settinn=2; }
	if ($WW[0]==23) { $settinn=1; }
	if ($WW[0]==25) { $settinn=7; }
	if ($WW[0]==26) { $settinn=5; }
	if ($WW[0]==27) { $settinn=10; }
	
	if ($V7[0]!= $settinn && $V6[0]!= $settinn && $V5[0]!= $settinn && $V4[0]!= $settinn)
	  {
	    if ($V7_missing[0]==0) { #V7 har kommet inn
	      $V7flag=10;
	      $V7corr=$settinn;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	  $V6corr=$settinn;
	    }
	    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=$settinn;
	    }
	    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=$settinn;
	  }
	}
    } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))



     
	###----WW Fra 50-90----------------------------------------------------
	if (50<=$WW[0] && $WW[0]<=90) {
	  
#50-57
	  if (50<=$WW[0] && $WW[0]<=57) {
	    my $yrsettinn="true";
	    #Setter inn yr---------------
	    # Hvis det ikke finnes fra f�r av:
	    
	    if ($V3_missing[0]==0 && $V3[0] ==8) {
	      $yrsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==8) {
	     $yrsettinn="false"; }
	    if ($V1_missing[0]==0 && $V1[0] ==8) {
	      $yrsettinn="false"; }
	    
	    if ($V3_missing[0]==0 && $yrsettinn eq "true") { #V3 har kommet inn
	      $V3flag=10;
	      $V3corr=8; #Setter inn yr
	      if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==3 || $V2[0]==7 || $V2[0]==4 || $V2[0]==5)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==7 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $yrsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=8; #Setter inn yr
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==3 || $V1[0]==7 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $yrsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=8; #Setter inn yr
	  }
	} #end if (50<=$WW[0] && $WW[0]<=57)

#58-59
	if (58<=$WW[0] && $WW[0]<=59) {
	  my $yrsettinn2="true";
	  #Setter inn yr---------------
	  # Hvis det ikke finnes fra f�r av:

	  if ($V3_missing[0]==0 && $V3[0] ==8) {
	  $yrsettinn2="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==8) {
	  $yrsettinn2="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==8) {
	  $yrsettinn2="false"; }
	  
	  if ($V3_missing[0]==0 && $yrsettinn2 eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=8; #Sett inn yr
	    if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==4 || $V2[0]==5)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $yrsettinn2 eq "true") {
	    $V2flag=10;
	    $V2corr=8;
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $yrsettinn2 eq "true") {
	    $V1flag=10;
	    $V1corr=8;
	  }
	} #end if (58<=$WW[0] && $WW[0]<=59)

#60-67
	if (60<=$WW[0] && $WW[0]<=67) {
	  #Setter inn regn---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $regnsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==3) {
	  $regnsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==3) {
	  $regnsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==3) {
	  $regnsettinn="false"; }

	  if ($V3_missing[0]==0 && $regnsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=3; #Setter inn regn
	    if ($V2_missing[0]==0 && ($V2[0]==1 || $V2[0]==2 || $V2[0]==8 || $V2[0]==4 || $V2[0]==5)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==8 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $regnsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=3; #Setter inn regn
	    if ($V1_missing[0]==0 && ($V1[0]==1 || $V1[0]==2 || $V1[0]==8 || $V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $regnsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=3;
	  }
	} #end if (60<=$WW[0] && $WW[0]<=67)

	# 70-79
	if (70<=$WW[0] && $WW[0]<=79){
	  my $rette =0;
	  if (70<=$WW[0] && $WW[0]<=75) { $rette=2; } #Setter inn sn�
	  if ($WW[0]==76) { $rette=16; }              #Setter inn isn�ler
	  if ($WW[0]==77 || $WW[0]==78) { $rette=6; } #Setter inn kornsn�
	  if ($WW[0]==79) { $rette=15; }              #Setter inn iskorn

	   #Setter inn diverse (etter kode)---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $diverse="true";

	  if ($V3_missing[0]==0 && $V3[0] ==$rette) {
	  $diverse="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==$rette) {
	  $diverse="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==$rette) {
	  $diverse="false"; }

	    if ($V3_missing[0]==0 && $diverse eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=$rette; #Setter inn etter WW-koden.... 
	    if ($V2_missing[0]==0 && ($V2[0]==8 || $V2[0]==3 || $V2[0]==7)) { #Sletter yr, regn (og regnbyge)
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==8 || $V1[0]==3 || $V1[0]==7)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $diverse eq "true") {
	    $V2flag=10;
	    $V2corr=$rette; #Setter inn 
	    if ($V1_missing[0]==0 && ($V1[0]==8 || $V1[0]==3 || $V1[0]==7)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $diverse eq "true") {
	    $V1flag=10;
	    $V1corr=$rette;
	  }
	} #end if (70<=$WW[0] && $WW[0]<=79)

# 80-82
	if (80<=$WW[0] && $WW[0]<=82) {
	   #Setter inn regnbyge---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $regnbsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==7) {
	  $regnbsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==7) {
	  $regnbsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==7) {
	  $regnbsettinn="false"; }


	  if ($V3_missing[0]==0 && $regnbsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=7; #Setter inn regnbyge
	    if ($V2_missing[0]==0 && ($V2[0]==4 || $V2[0]==5)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $regnbsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=7; #Setter inn regnbyge
	    if ($V1_missing[0]==0 && ($V1[0]==4 || $V1[0]==5)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $regnbsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=7;
	  }
	} #end if (80<=$WW[0] && $WW[0]<=82)

#83-84
	if (83<=$WW[0] && $WW[0]<=84) {
	   #Setter inn sluddbyge---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $sluddbsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==4) {
	  $sluddbsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==4) {
	  $sluddbsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==4) {
	  $sluddbsettinn="false"; }

	  if ($V3_missing[0]==0 && $sluddbsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=4; #Setter inn sluddbyge
	    if ($V2_missing[0]==0 && ($V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $sluddbsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=4; #Setter inn sluddbyge
	    if ($V1_missing[0]==0 && ($V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $sluddbsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=4;
	  }
	} #end if (83<=$WW[0] && $WW[0]<=84)

#WW=85,86
	if (85<=$WW[0] && $WW[0]<=86) {
	   #Setter inn sn�byge---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $snobsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==5) {
	  $snobsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==5) {
	  $snobsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==5) {
	  $snobsettinn="false"; }

	  if ($V3_missing[0]==0 && $snobsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=5; #Setter inn sn�byge
	    if ($V2_missing[0]==0 && ($V2[0]==3 || $V2[0]==1 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==3 || $V1[0]==1 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $snobsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=5; #Setter inn sn�byge
	    if ($V1_missing[0]==0 && ($V1[0]==3 || $V1[0]==1 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $snobsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=5;
	  }
	} #end if (85<=$WW[0] && $WW[0]<=86)

#WW=87,88
	if (87<=$WW[0] && $WW[0]<=88) {
	  #Setter inn hagl---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $haglsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==10) {
	  $haglsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==10) {
	  $haglsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==10) {
	  $haglsettinn="false"; }

	  if ($V3_missing[0]==0 && $haglsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=10; #Setter inn haglbyge
	    if ($V2_missing[0]==0 && ($V2[0]==5 || $V2[0]==11)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $haglsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=10; #Setter inn hagl
	    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==11)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $haglsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=10;
	  }
	} #end if (87<=$WW[0] && $WW[0]<=88)

#WW=89,90
	if (89<=$WW[0] && $WW[0]<=90) {
	  #Setter inn ishagl---------------
	  # Hvis det ikke finnes fra f�r av:
	  my $ishaglsettinn="true";

	  if ($V3_missing[0]==0 && $V3[0] ==11) {
	  $ishaglsettinn="false"; }
	   if ($V2_missing[0]==0 && $V2[0] ==11) {
	  $ishaglsettinn="false"; }
	   if ($V1_missing[0]==0 && $V1[0] ==11) {
	  $ishaglsettinn="false"; }
	
	  if ($V3_missing[0]==0 && $ishaglsettinn eq "true") { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=11; #Setter inn ishagl
	    if ($V2_missing[0]==0 && ($V2[0]==5 || $V2[0]==10 || $V2[0]==9)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter V2
	    }
	    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==10 || $V1[0]==9)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V2_missing[0]==0 && $V3_missing[0]>0 && $ishaglsettinn eq "true") {
	    $V2flag=10;
	    $V2corr=11; #Setter inn ishagl
	    if ($V1_missing[0]==0 && ($V1[0]==5 || $V1[0]==10 || $V1[0]==9)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter V1
	    }
	  }

	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0 && $ishaglsettinn eq "true") {
	    $V1flag=10;
	    $V1corr=11;
	  }
	} #end if (89<=$WW[0] && $WW[0]<=90)

=comment

	  #S� tar vi hensyn til sikt:
      if (50<=$WW[0] && $WW[0]<=79) { #Enda mer sjekking, tar hensyn til sikten ogs�....
	if ($VV_missing[0]==0 && $VV[0]<1000) {
	  if ((50<=$WW[0] && $WW[0]<=53) || (56<=$WW[0] && $WW[0]<=71) || (76<=$WW[0] && $WW[0]<=79)) {
	    
	    if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=18; #Setter inn t�ke-----------
	      }



	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=18; #Setter inn t�ke-----------
	      }
	      if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		$V1flag=10;
		$V1corr=18; #Setter inn t�ke-----------
	      }


	    }
	  }
	  if (54<=$WW[0] && $WW[0]<=55) {
	    if ($VV_missing[0]==0 && $VV[0]<=400) {
	      #Setter inn t�ke.
	      if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
		if ($V3_missing[0]==0) {
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke-----------
		}



		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke-----------
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke-----------
		}



	      }
	    }
	  }
	  
	   if (72<=$WW[0] && $WW[0]<=75) {
	    if ($VV_missing[0]==0 && $VV[0]<=200) {
	      #Setter inn t�ke.
	      if ($V1[0] != 18 && $V2[0] != 18 && $V3[0] != 18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
		if ($V3_missing[0]==0) {
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke-----------
		}



		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke-----------
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke-----------
		}


	      }
	    }
	  }
	} #end if VV<1000
      } #End if if (50<=$WW[0] && $WW[0]<=79) 

=cut

      } #end if (50<=$WW[0] && $WW[0]<=90)


     if (91<=$WW[0] && $WW[0]<=94) {
       #Beholder n� WW, men setter inn torden i V4-V7.
       if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	 if ($V7_missing[0]==0) { #V7 har kommet inn
	   $V7flag=10;
	   $V7corr=20;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=20;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=20;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=20;
	 }
       }
     }
     if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
       #Setter alle flagg mistenkelige.
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
       if ($V4_missing[0]==0) {
	 $V4flag=3;
       }
     }
     if ($WW[0]==98) {
       $WWflag=6;
     }
   }



} #end sub komb_4_3 {









#N� g�r vi l�s p� kombinasjon 5-6.------------------------------------
sub komb_5_1 {

#2 og 1 nedb�rsymbol har vi tatt i komb. 4
#N� er vi over p� Nedb�r, ikke-nedb�r, ikke-torden og premiss t�ke.
#Tester p� 1 symbol nedb�r, 1 symbol ikke-nedb�r (og ikke-t�ke),  og premisser nedover, f�rste premiss t�ke.
#siste symbol manglende eller med (manglende eller av typen nedb�r eller ikke-nedb�r) denne teksten lagt til 

if ((((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)) && $V3[0]!=20) ||
(((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29)) && $V2[0]!=20) ||
(((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)) && $V3[0]!=20) ||
(((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) && ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29)) && $V1[0]!=20) ||
(((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)) && $V2[0]!=20) ||
(((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) && ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)) && $V1[0]!=20))

  {

=comment

#Test p� 2 nedb�rsymboler ok er gjort i komb. 4-2.
#M� legge inn test p� om ok.------------------------------------------------------
# Ett nedb�rsymbol
if (($V1[0] ==5 || $V2[0] ==5 || $V3[0] ==5) && (85<=$WW[0] && $WW[0]<=86)) {
    return;} #Sn�byger
if (($V1[0] ==3 || $V2[0] ==3 || $V3[0] ==3) && (60<=$WW[0] && $WW[0]<=67)) {
    return;} #Regn
if (($V1[0] ==8 || $V2[0] ==8 || $V3[0] ==8) && (50<=$WW[0] && $WW[0]<=57)) {
    return;} #Yr
if (($V1[0] ==1 || $V2[0] ==1 || $V3[0] ==1) && (68<=$WW[0] && $WW[0]<=69)) {
    return;} #Sludd
if (($V1[0]==2 || $V2[0]==2 || $V3[0]==2) && ((70<=$WW[0] && $WW[0]<=75) || $WW[0] == 78)) {
     return; } #Sn�
if (($V1[0]==16 || $V2[0]==16 || $V3[0]==16) && $WW[0]==76) {
	return; } #Isn�ler
if (($V1[0]==6 || $V2[0]==6 || $V3[0]==6) && $WW[0]==77) {
	return; } #Kornsn�
if (($V1[0]==15 || $V2[0]==15 || $V3[0]==15) && $WW[0]==79) {
	return; } #Iskorn
if (($V1[0] ==7 || $V2[0] ==7 || $V3[0] ==7) && (80<=$WW[0] && $WW[0]<=82)) {
    return;} #Regnbyger
if (($V1[0] ==4 || $V2[0] ==4 || $V3[0] ==4) && (83<=$WW[0] && $WW[0]<=84)) {
    return;} #Sluddbyger
if (($V1[0] ==10 || $V2[0] ==10 || $V3[0] ==10) && (87<=$WW[0] && $WW[0]<=88)) {
    return;} #Hagl
if (($V1[0] ==9 || $V2[0] ==9 || $V3[0] ==9) && (87<=$WW[0] && $WW[0]<=88)) {
    return;} #Spr�hagl
if (($V1[0] ==11 || $V2[0] ==11 || $V3[0] ==11) && (89<=$WW[0] && $WW[0]<=90)) {
    return;} #Ishagl

=cut

#####################################################



   #Kopierer fra tidligere, mye g�r igjen her----------------
      if (((0<=$WW[0] && $WW[0]<=14) || (28<=$WW[0] && $WW[0]<=49)) && ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28)) {
	
      #NB Husk ta med insetting i V4-V7 ved WW=24, 28, 29-----------------------------
      
      if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) {
	$WWflag=10;
	$WWcorr=50;
      }
      if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
        $WWflag=10;
	$WWcorr=60;
      }
      if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
        $WWflag=10;
	$WWcorr=68;
      }
      if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
        $WWflag=10;
	$WWcorr=70;
      }
      if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
        $WWflag=10;
	$WWcorr=76;
      }
      if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
        $WWflag=10;
	$WWcorr=77;
      }
      if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
        $WWflag=10;
	$WWcorr=79;
      }
      if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
        $WWflag=10;
	$WWcorr=80;
      }
      if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
        $WWflag=10;
	$WWcorr=83;
      }
      if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
        $WWflag=10;
	$WWcorr=85;
      }
      if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
        $WWflag=10;
	$WWcorr=87;
      }
      if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
        $WWflag=10;
	$WWcorr=89; #Setter WW=89.
      }
    } # end if (((0<=$WW[0] && $WW[0]<=14) || (28<=$WW[0] && $WW[0]<=49)) && ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28)
	
	 #Til V4-V7--------------------------------------
      if ($WW[0]==24) {
	if ($V7[0] !=14 && $V6[0] !=14 && $V5[0] !=14 && $V4[0] !=14) {
	  if ($V7_missing[0]==0) { #V7 har kommet inn
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=14;
	}
	}
      }

	
      if ($WW[0]==28 && $VV[0]>=1000) {
	if ($V1[0]==18 || $V2[0]==18 || $V3[0]==18) { 
	  if ($V3_missing[0]==0 && $V3[0]==18 && $V3flag !=10) { #Dersom ikke korrigert f�r
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter t�ke---------------
	  }
	  if ($V2_missing[0]==0 && $V2[0]==18 && $V2flag !=10) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter t�ke---------------
	  }
	  if ($V1_missing[0]==0 && $V1[0]==18 && $V1flag !=10) {
	    $V1flag=13;
	    $V1_missing[0]=2; # Sletter t�ke--------------
	  }
	}
#Setter inn t�ke for v�ret siden forrige hovedobservasjon
	if ($V7[0]!=18 && $V6[0]!=18 && $V5[0]!=18 && $V4[0]!=18) {
	  if ($V7_missing[0]==0 && $V7[0]!=18) { #V7 har kommet inn
	    $V7flag=10;
	    $V7corr=18;
	  }
	  if ($V6_missing[0]==0 && $V6[0]!=18 && $V7_missing[0]>0 ) {
	    $V6flag=10;
	    $V6corr=18;
	  }
	  if ($V5_missing[0]==0 && $V5[0]!=18 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=18;
	  }
	  if ($V4_missing[0]==0 && $V4[0]!=18 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=18;
	  }
	}
      } #end if ($WW[0]==28 && $VV[0]>=1000)
      if ($WW[0]==28 && $VV_missing[0]==0 && $VV[0]<1000) {
	if ($V1[0]==18 || $V2[0]==18 || $V3[0]==18) { 
	  $WWflag=6; #Antagelig feil WW, senere-----------
	}
      }

      if ($WW[0]==29) {
	if ($V7[0]!=20 && $V6[0]!=20 && $V5[0]!=20 && $V4[0]!=20) {
	if ($V7_missing[0]==0 && $V7[0] !=20) { #V7 har kommet inn
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0 && $V6[0] !=20) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V5[0] !=20) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0 && $V4[0] !=20) {
	  $V4flag=10;
	  $V4corr=20;
	}
      }
      }


if (42<=$WW[0] && $WW[0]<=49) {
	  my $taakeja=0;
	  if ($VV_missing[0]==0 && $VV[0]<1000) {
	    if ($V1[0]==8 || $V2[0]==8 || $V3[0]==8) { #Yr
	      $WWflag=10;
	      $WWcorr=50;$taakeja=1;
	    }
	    if ($V1[0]==3 || $V2[0]==3 || $V3[0]==3) {
	      $WWflag=10;
	    $WWcorr=60;$taakeja=1;
	  }
	  if ($V1[0]==1 || $V2[0]==1 || $V3[0]==1) {
	    $WWflag=10;
	    $WWcorr=68;$taakeja=1;
	  }
	  if ($V1[0]==2 || $V2[0]==2 || $V3[0]==2) {
	    $WWflag=10;
	    $WWcorr=70;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==16 || $V2[0]==16 || $V3[0]==16) {
	    $WWflag=10;
	    $WWcorr=76;$taakeja=1;
	  }
	  if ($V1[0]==6 || $V2[0]==6 || $V3[0]==6) {
	    $WWflag=10;
	    $WWcorr=77;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==15 || $V2[0]==15 || $V3[0]==15) {
	    $WWflag=10;
	    $WWcorr=79;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==7 || $V2[0]==7 || $V3[0]==7) {
	    $WWflag=10;
	    $WWcorr=80;$taakeja=1;
	  }
	  if ($V1[0]==4 || $V2[0]==4 || $V3[0]==4) {
	    $WWflag=10;
	    $WWcorr=83;$taakeja=1;
	  }
	  if ($V1[0]==5 || $V2[0]==5 || $V3[0]==5) {
	    $WWflag=10;
	    $WWcorr=85;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==9 || $V2[0]==9 || $V3[0]==9 || $V1[0]==10 || $V2[0]==10 || $V3[0]==10) {
	    $WWflag=10;
	    $WWcorr=87;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }
	  if ($V1[0]==11 || $V2[0]==11 || $V3[0]==11) {
	    $WWflag=10;
	    $WWcorr=89;
	    if ($VV_missing[0]==0 && $VV[0]<400) { $taakeja=1;
	    }
	  }

=comment
	  
	  #Setter inn t�ke---------------
	  if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	  if ($taakeja==1) { #V3 har kommet inn
	    $V3flag=10;
	    $V3corr=18; #Sett t�ke
	  }
         }

=cut

	} #End if $VV_missing[0]==0 && VV<1000
	
=comment

	  if (1000<=$VV[0] && $VV[0]<=10000) {
	    #Setter inn t�kedis---------------
	      if ($V1[0]!=19 && $V2[0]!=19 && $V3[0]!=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
		#V3 har kommet inn
		$V3flag=10;
		$V3corr=19; #Setter inn t�kedis
	    }
	    
	}

=cut

      } #End if (42<=$WW[0] && $WW[0]<=49) 



###########
      if ($WW[0]==15 || $WW[0]==16 || $WW[0]==18 || $WW[0]==19) {
	$WWflag=3;
	if ($V1_missing[0]==0) {$V1flag=3; }
	if ($V2_missing[0]==0) {$V2flag=3; }
	if ($V3_missing[0]==0) {$V3flag=3; }	
      }
      
      if ($WW[0]==17) {
	if ($V3[0]!=20 && $V2[0]!=20 && $V1[0]!=20) {
	  if ($V3_missing[0]==0) { #V7 har kommet inn
	    $V3flag=10;
	    $V3corr=20; #Sett torden
	  }
	  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=20;
	  }
	  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=20;
	  }
	}
      }
      

      if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
        #Sletter all nedb�r---------------
	#if ($V1_missing[0]==0) { #Hvis verdien har kommet inn
	  if ((1<=$V1[0] && $V1[0]<=11) || (15<=$V1[0] && $V1[0]<=16)) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter nedb�r, setter inn i V4-V7 
	  }
	#if ($V2_missing[0]==0) {
	  if ((1<=$V2[0] && $V2[0]<=11) || (15<=$V2[0] && $V2[0]<=16)) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter nedb�r, setter inn i V4-V7 
	  }
	#if ($V3_missing[0]==0) {
	  if ((1<=$V3[0] && $V3[0]<=11) || (15<=$V3[0] && $V3[0]<=16)) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter nedb�r, setter inn i V4-V7 
	  }

	my $settinn =0;
	if ($WW[0]==20) { $settinn=8; }
	if ($WW[0]==21) { $settinn=3; }
	if ($WW[0]==22) { $settinn=2; }
	if ($WW[0]==23) { $settinn=1; }
	if ($WW[0]==25) { $settinn=7; }
	if ($WW[0]==26) { $settinn=5; }
	if ($WW[0]==27) { $settinn=10; }
	
	if ($V7[0]!= $settinn && $V6[0]!= $settinn && $V5[0]!= $settinn && $V4[0]!= $settinn)
	  {
	    if ($V7_missing[0]==0) { #V7 har kommet inn
	      $V7flag=10;
	      $V7corr=$settinn;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=$settinn;
	    }
	    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=$settinn;
	    }
	    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=$settinn;
	    }
	  }
	  } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))




      #Kommer inn p� detaljer: Sletter �lr�yk------------------------
        if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) { 
	  if (0<=$WW[0] && $WW[0]<=49) {
	      if ($V3_missing[0]==0 && $V3[0]==21 && $V3flag !=10) { #Dersom ikke korrigert f�r
		  $V3flag=13;
		  $V3_missing[0]=2; #Sletter �lr�yk---------------
	      }
	      if ($V2_missing[0]==0 && $V2[0]==21 && $V2flag !=10) {
		  $V2flag=13;
		  $V2_missing[0]=2; #Sletter �lr�yk---------------
	      }
	      if ($V1_missing[0]==0 && $V1[0]==21 && $V1flag !=10) {
		  $V1flag=13;
		  $V1_missing[0]=2; # Sletter �lr�yk--------------
	      }
	  }
      }
      #Sletter t�kedis hvis VV>10000------------------------------
       if (($V1[0]==19 || $V2[0]==19 || $V3[0]==19) && $VV[0]>10000) {
	    if (0<=$WW[0] && $WW[0]<=49) {
		if ($V3_missing[0]==0 && $V3[0]==19 && $V3flag !=10) { # Dersom ikke korrigert f�r
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter t�kedis---------------
		}
		if ($V2_missing[0]==0 && $V2[0]==19 && $V2flag !=10) {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter t�kedis---------------
		}
		if ($V1_missing[0]==0 && $V1[0]==19 && $V1flag !=10) {
		    $V1flag=13;
		    $V1_missing[0]=2; # Sletter t�kedis--------------
		}
	    }
	    }

   


##################### -------------
    #S� tar vi fra WW=50 og oppover---------------------

#VV<1000 og premiss minst ett symbol t�ke----------
      if (($VV_missing[0]==0 && $VV[0]<1000) && ($V1[0]==18 || $V2[0]==18 || $V3[0]==18)) {
	if ($WW[0]==54 || $WW[0]==55 || $WW[0]==72 || $WW[0]==73 || $WW[0]==82 || $WW[0]==86 || $WW[0]==88 || $WW[0]==90)
	  {
	    if ($VV[0]>400) {
	      if ($V1[0]==18 && $V1flag !=10) {
		$V1flag=13;
		$V1_missing[0]=2; #Sletter t�ke-----
	      }
	      if ($V2[0]==18 && $V2flag !=10) {
		$V2flag=13;
		$V2_missing[0]=2; #Sletter t�ke-----
	      }
	      if ($V3[0]==18 && $V3flag !=10) {
		$V3flag=13;
		$V3_missing[0]=2; #Sletter t�ke-----
	      }
	    }
	  }
	if ($WW[0]==74 || $WW[0]==75) {
	  if ($VV[0]>100) {
	    if ($V1[0]==18 && $V1flag !=10) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter t�ke-----
	    }
	    if ($V2[0]==18 && $V2flag !=10) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter t�ke-----
	    }
	    if ($V3[0]==18 && $V3flag !=10) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter t�ke-----
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=94) {
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20; #Setter inn torden
	    } 
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20; #Setter inn torden
	    }
	    if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20; #Setter inn torden
	    }
	    if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20; #Setter inn torden
	    }
	  }
	}

	if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
	  $WWflag=3;
	  if ($V1_missing[0]==0) {
	    $V1flag=3;
	  }
	  if ($V2_missing[0]==0) {
	    $V2flag=3;
	  }
	  if ($V3_missing[0]==0) {
	    $V3flag=3;
	  }
	}
	if ($WW[0]==98) {
	  $WWflag=6; #Antagelig feil WW.
	}

      } #end if ($VV[0]<1000 && ($V1[0]==18 || $V2[0]==18 || $V3[0]==18))

      if ($VV[0]>=1000 && ($V1[0]==18 || $V2[0]==18 || $V3[0]==18)) {
	if (50<=$WW[0] && $WW[0]<=94) {
	  if ($V1[0]==18 && $V1flag !=10) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter t�ke-----
	  }
	  if ($V2[0]==18 && $V2flag !=10) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter t�ke-----
	  }
	  if ($V3[0]==18 && $V3flag !=10) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter t�ke-----
	  }
	}
	if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
	  $WWflag=3;
	  if ($V1_missing[0]==0) {
	    $V1flag=3;
	  }
	  if ($V2_missing[0]==0) {
	    $V2flag=3;
	  }
	  if ($V3_missing[0]==0) {
	    $V3flag=3;
	  }
	}
	if ($WW[0]==98) {
	  $WWflag=6; #Antagelig feil WW.
	}
      } #end if ($VV[0]>=1000 && ($V1[0]==18 || $V2[0]==18 || $V3[0]==18))




### Vi g�r over p� premiss sn�fokk-------------------
#Premiss minst ett symbol sn�fokk:-------------
      if ($V1[0]==28 || $V2[0]==28 || $V3[0]==28) {
	if (0<=$WW[0] && $WW[0]<=69) {
	  #Feil i v�rsymbol eller WW. Senere------------
	  $WWflag=3;
	  if ($V1_missing[0]==0) {
	    $V1flag=3;
	  }
	  if ($V2_missing[0]==0) {
	    $V2flag=3;
	  }
	  if ($V3_missing[0]==0) {
	    $V3flag=3;
	  }
	}
	if ((70<=$WW[0] && $WW[0]<=79) || (83<=$WW[0] && $WW[0]<=86)) {
	  if ($V1[0]==28 && $V1flag !=10) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter sn�fokk-----
	  }
	  if ($V2[0]==28 && $V2flag !=10) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter sn�fokk-----
	  }
	  if ($V3[0]==28 && $V3flag !=10) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter sn�fokk-----
	  }
	}
	if ((80<=$WW[0] && $WW[0]<=82) || (87<=$WW[0] && $WW[0]<=99)) {
	   #Feil i v�rsymbol eller WW. Senere------------
	  $WWflag=3;
	  if ($V1_missing[0]==0) {
	    $V1flag=3;
	  }
	  if ($V2_missing[0]==0) {
	    $V2flag=3;
	  }
	  if ($V3_missing[0]==0) {
	    $V3flag=3;
	  }
	}
      } #end ($V1[0]==28 || $V2[0]==28 || $V3[0]==28)

      #Premiss minst ett symbol t�kedis:-------------
      if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) {
	if (50<=$WW[0] && $WW[0]<=99) {
	  if ($VV[0]>10000) {
	    if ($V1[0]==19 && $V1flag !=10) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter t�kedis-----
	    }
	    if ($V2[0]==19 && $V2flag !=10) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter t�kedis-----
	    }
	    if ($V3[0]==19 && $V3flag !=10) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter t�kedis-----
	    }
	  }
	}
      } #end ($V1[0]==19 || $V2[0]==19 || $V3[0]==19)

      if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) {
        if (50<=$WW[0] && $WW[0]<=99) {
	    if ($V1[0]==21 && $V1flag !=10) {
		$V1flag=13;
		$V1_missing[0]=2; #Sletter �lr�yk-----
	    }
	    if ($V2[0]==21 && $V2flag !=10) {
		$V2flag=13;
		$V2_missing[0]=2; #Sletter �lr�yk-----
	    }
	    if ($V3[0]==21 && $V3flag !=10) {
		$V3flag=13;
		$V3_missing[0]=2; #Sletter �lr�yk-----
	    }
	}
      } #end ($V1[0]==21 || $V2[0]==21 || $V3[0]==21)


#################Hvis V3 mangler----------
#Setter kun inn t�ke/t�kedis i V3 (og dersom alle symboler har kommet inn og de er forskjellige fra t�ke/t�kedis.
#Kommenterer vekk her, fordi ikke mulighet til � legge inn nye symboler, som opprinnelig er meningen i speken.
################


=comment

      if ($V3_missing[0]>0) { #Hvis V3 mangler:
	if ($VV[0]<1000 && $VV_missing[0]==0) {
	  if (($V1[0]==8 || $V1[0]==3 || $V1[0]==1 || $V1[0]==16 || $V1[0]==7 || $V1[0]==4) || ($V2[0]==8 || $V2[0]==3 || $V2[0]==1 || $V2[0]==16 || $V2[0]==7 || $V2[0]==4)) {
	    if (42<=$WW[0] && $WW[0]<=49) {
	      #Setter ev. inn t�ke.
	       #---------------
	      if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18) {
		if ($V3_missing[0]==0) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke
		}
	      }
	    }
	  }

	  if (($V1[0]==2 || $V1[0]==6 || $V1[0]==15 || $V1[0]==5 || $V1[0]==9 || $V1[0]==10 || $V1[0]==11) || ($V2[0]==2 || $V2[0]==6 || $V2[0]==15 || $V2[0]==5 || $V2[0]==9 || $V2[0]==10 || $V2[0]==11)) {
	      if (42<=$WW[0] && $WW[0]<=49) {
		  if ($VV_missing[0]==0 && $VV[0]<=400) {
		      #Setter ev. inn t�ke.
		      #---------------
		      if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18) {
			  if ($V3_missing[0]==0) { #V3 har kommet inn
			      $V3flag=10;
			      $V3corr=18; #Setter inn t�ke
			  }
			  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
			      $V2flag=10;
			      $V2corr=18; #Setter inn t�ke
			  }
			  if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
			      $V1flag=10;
			      $V1corr=18; #Setter inn t�ke
			  }
		      }
		  }
	      }
	  }



     #Siste p� komb_5-6 i spesifikasjonen-------------------------------
	  if ((50<=$WW[0] && $WW[0]<=53) || (56<=$WW[0] && $WW[0]<=71) || (76<=$WW[0] && $WW[0]<=79)) {
	     #Setter ev. inn t�ke.
	       #---------------
	      if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18) {
		if ($V3_missing[0]==0) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke
		}
	      }
	    }
	  if (54<=$WW[0] && $WW[0]<=55) {
	    if ($VV_missing[0]==0 && $VV[0]<=400) {
	      #Setter ev. inn t�ke.
	       #---------------
	      if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18) {
		if ($V3_missing[0]==0) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke
		}
	      }
	    }
	  }
	  if (72<=$WW[0] && $WW[0]<=75) {
	    if ($VV_missing[0]==0 && $VV[0]<=100) {
	      #Setter ev. inn t�ke.
	       #---------------
	      if ($V1[0]!=18 && $V2[0]!=18 && $V3[0]!=18) {
		if ($V3_missing[0]==0) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=18; #Setter inn t�ke
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=18; #Setter inn t�ke
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=18; #Setter inn t�ke
		}
	      }
	    }
	  }
	} #end if VV<1000 && $VV_missing[0]==0
     
	if (1000<=$VV[0] && $VV[0]<=10000) {
	  if (42<=$WW[0] && $WW[0]<=67) {
	    #Setter ev. inn t�kedis.
	       #---------------
	      if ($V1[0]!=19 && $V2[0]!=19 && $V3[0]!=19) {
		if ($V3_missing[0]==0) { #V3 har kommet inn
		  $V3flag=10;
		  $V3corr=19; #Setter inn t�kedis
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		  $V2flag=10;
		  $V2corr=19; #Setter inn t�kedis
		}
		if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
		  $V1flag=10;
		  $V1corr=19; #Setter inn t�kedis
		}
	      }
	    }
	}
      } #end if ($V3_missing[0]>0)

=cut

    } #end hele store if-en p� sub komb. 5-1

} #end komb_5_1















  
  sub komb_5_1_gammel {

    
    #############################################################
    #################   Komb. 5 (noe i komb 4, dvs. 1 symbol)   ##############
    #########################################################
    ### V1=nedb�r, V2= ikke-nedb�r ##########################
    
    if ((1<=$V1[0] && $V1[0]<=11 || 15<=$V1[0] && $V1[0]<=16) && (12<=$V2[0] && $V2[0]<=14 || 17<=$V2[0] && $V2[0]<=29))
      {
	if (0<=$WW[0] && $WW[0]<=49) 
	  {
	    
	    ########## Langh remse her, som f�r, for hvert tilfelle	
	    if ($V1[0]==8)
	      {
		$WWflag=10;
		$WWcorr=50;
	      }  
	    if ($V1[0]==3)
	      {
		$WWflag=10;
		$WWcorr=60;
	      }
	    if ($V1[0]==1)
	      {
		$WWflag=10;
		$WWcorr=68;
	      }
	    if ($V1[0]==2)
	      {
		$WWflag=10;
		$WWcorr=70;
	      }
	    if ($V1[0]==16)
	      {
		$WWflag=10;
		$WWcorr=76;
	      }
	    if ($V1[0]==6)
	      {
		$WWflag=10;
		$WWcorr=77;
	      }
	    if ($V1[0]==15)
	      {
		$WWflag=10;
		$WWcorr=79;
	      }
	    if ($V1[0]==7)
	      {
		$WWflag=10;
		$WWcorr=80;
	      }
	    if ($V1[0]==4)
	      {
		$WWflag=10;
		$WWcorr=83;
	      }
	    if ($V1[0]==5)
	      {
		$WWflag=10;
		$WWcorr=85; 
	      }
	    if ($V1[0]==9 || $V1[0]==10)
	      {
		$WWflag=10;
		$WWcorr=87;
	      }
	    if ($V1[0]==11)
	      {
		$WWflag=10;
		$WWcorr=89;
	      }
	    
	    ########### Spesialtilfeller for WW=15,16, 18 og 19 ####################
	    if ($WW[0]==15 || $WW[0]==16 || $WW[0]==18 || $WW[0]==19)
	      {
		$WWflag=3;
		$V1flag=3;
		if ($V2_missing[0]==0)
		  {
		    $V2flag=3;
		  }
		if ($V3_missing[0]==0)
		  {
		    $V3flag=3;
		  }
	      }
	    
	    #############Korrigerer i tillegg p� V4 ######################
	    if ($WW[0]==24 && $V4[0] != 14) {
	      $V4flag=10;
	      $V4corr=14;
	    }
	    if ($WW[0]==28 && $V4[0] != 18) {
	      $V4flag=10;
	      $V4corr=18;
	    }
	    if ($WW[0]==29 && $V4[0] != 20) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	    

##################################
	    if ($WW[0]==17)
	      {
		$V1flag=10;
		$V1corr=20;  
	      }
	    ##################################### 
	    if (20<=$WW[0] && $WW[0]<=23 || 25<=$WW[0] && $WW[0]<=27)
	      {
		if ($V4[0] != $V1[0]) {
		  $V4flag=10;
		  $V4corr=$V1[0];
		}
		$V1flag=13;
		$V1_missing[0]=2; #Sletter nedb�r  
	      }
	    if ($VV[0]>=1000 && ($V2[0]==18 || $V2[0]==21))
	      {
		$V2flag=13;
		$V2_missing[0]=2;  #Sletter t�ke eller �lr�yk###
	      }
	    if ($VV[0]>10000 && ($V2[0]==19))  
	      {      
		$V2flag=13;
		$V2_missing[0]=2;
	      }
	    
	  }  #end if (0<=$WW[0] && $WW[0]<=49)
	
	if (0<=$VV[0] && $VV[0]<1000 && $V2[0]==18)
	  {
	    if ($WW[0]==28)  
	      {
		$WWflag=6;
	      }
	    if (($WW[0]==54 || $WW[0]==55 || $WW[0]==72 || $WW[0]==73 || $WW[0]==82 || $WW[0]==86 || $WW[0]==88 || $WW[0]==90) && $VV[0]>400)
	      {
		$V2flag=13;
		$V2_missing[0]=2;
	      }
	    if (($WW[0]==74 || $WW[0]==75) && $VV[0]>100)
	      {
		$V2flag=13;
		$V2_missing[0]=2;
	      }
	    if ((91<=$WW[0] && $WW[0]<=94) && $V4[0]!=20)
	      {
		$V4flag=10;
		$V4corr=20; #Setter inn torden
	      }
	    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99)
	      {
		$WWflag=3;
		$V2flag=3;
	      }
	    if ($WW[0]==98)
	      {
		$WWflag=6;
	      }
	  } # end if (0<=$VV[0] && $VV[0]<1000 && $V2[0]==18)
	
	if ($VV[0]>=1000 && $V2[0]==18) ####################################
	  {
	    if ($WW[0]==28)
	      {
		$V2flag=13;
		$V2_missing[0]=2;
		if ($V4[0] != 18) {
		  $V4flag=10;
		  $V4corr=18;
		}
	      }
	    if (50<=$WW[0] && $WW[0]<=94)  {
	      $V2flag=13;
	      $V2_missing[0]=2;
	    }
	    if ((95<=$WW[0] && $WW[0]<=97) || $WW[0]==99) {
	      $WWflag=3;
	      $V2flag=3;
	    }
	    if ($WW[0]==98)
	      {
		$WWflag=6;
	      }
	  } ## end ($VV[0]>=1000 && $V2==18)
	
	if ($VV[0]>=1000 && $V2[0]==28)  {
	  if ((0<=$WW[0] && $WW[0]<=49) || (50<=$WW[0] && $WW[0]<=69) || (80<=$WW[0] && $WW[0]<=82) || (87<=$WW[0] && $WW[0]<=99)) {
	    $WWflag=3;
	    $V2flag=3;
	  }
	  if ((70<=$WW[0] && $WW[0]<=79) || (83<=$WW[0] && $WW[0]<=86)) {
	    $V2flag=13;
	    $V2_missing[0]=2;
	  }
	}  #end if ($VV[0]>=1000 && $V2==28)
	
	if ($V2[0]==19 && (50<=$WW[0] && $WW[0]<=99) && $VV[0]>10000) {
	  $V2flag=13;
	  $V2_missing[0]=2; ##Sletter t�kedis, �verst side69
	}
	if ($V2[0]==21 && (50<=$WW[0] && $WW[0]<=99)) {
	  $V2flag=13;
	  $V2_missing[0]=2; ##Sletter �lr�yk, �verst side69
	}
	
      } ##end if (1<=$V1[0] && $V1[0]<=11 || 15<=$V1[0] && $V1[0]<=16)
    ###################################################################
    
    
  } #end sub komb_5_1








##########################################################

#Begynner n� p� komb. 7a.
#---------------------------Ikke-nedb�r, t�ke.
#--Vi har ett symbol (eller flere), ett symbol er premiss t�ke, de andre eventuelle symbolene er enten manglende eller ikke-torden, ikke-nedb�r, ikke-sn�fokk--------------

#######################################
sub komb_7_a {
#(V1 t�ke), (V2 manglende eller ikke-nedb�r, ikke-t�ke, ikke-sn�fokk), (V3 manglende eller ikke-nedb�r, ikke-t�ke, ikke-sn�fokk)----------
#og de to andre komb. med V2 t�ke og V3 t�ke.

  if (($V1[0]==18 && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29)) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29))) ||
 ($V2[0]==18 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29)) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29))) ||
($V3[0]==18 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29)) && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29)))) 

 {

=comment

#Legger inn test p� om ok.
    if (($VV_missing[0]==0 && $VV[0]<1000) && (42<=$WW[0] && $WW[0]<=49)) {
	return;}
####

=cut

   if ($VV_missing[0]==0 && $VV[0]<1000) {
     if ((0<=$WW[0] && $WW[0]<=9) || (13<=$WW[0] && $WW[0]<=16)) {
       $WWflag=10;
       $WWcorr=45;
     }
     if ($WW[0]==10) {
       $WWflag=3;
       $VVflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if ((11<=$WW[0] && $WW[0]<=12) || (17<=$WW[0] && $WW[0]<=19)) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
       $WWflag=10;
       $WWcorr=45;
       if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	 if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=8;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=8;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=8;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=8;
	   }
	 }
       }
       if ($WW[0]==21) { 
	 if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=3;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=3;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=3;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=3;
	   }
	 }
       }
       if ($WW[0]==22) { 
	 if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=2;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=2;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=2;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=2;
	   }
	 }
       }
       if ($WW[0]==23) { 
	 if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=1;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=1;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=1;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=1;
	   }
	 }
       }
       if ($WW[0]==25) { 
	 if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=7;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=7;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=7;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=7;
	   }
	 }
       }
       if ($WW[0]==26) { 
	 if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=5;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=5;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=5;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=5;
	   }
	 }
       }
       if ($WW[0]==27) { 
	 if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=10;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=10;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=10;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=10;
	   }
	 }
       }
     } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))

     if ($WW[0]==24) { 
       $WWflag=10;
       $WWcorr=45;
       if ($V7[0] != 14 && $V6[0] != 14 && $V5[0] != 14 && $V4[0] != 14) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=14;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=14;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=14;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=14;
	 }
       }
     }
     if ($WW[0]==28) { 
       $WWflag=10;
       $WWcorr=45;
       if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=18;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=18;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=18;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=18;
	   }
	 }
     }
     if ($WW[0]==29) {        #-----------Torden
       $WWflag=10;
       $WWcorr=45;
       if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=20;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=20;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=20;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=20;
	 }
       }
     }
     if (30<=$WW[0] && $WW[0]<=35) {
       $WWflag=10;
       $WWcorr=45;
     }

     if (36<=$WW[0] && $WW[0]<=39) {
       if ($V1[0]==18) {
	 $V1flag=3;
       }
       if ($V2[0]==18) {
	 $V2flag=3;
       }
       if ($V3[0]==18) {
	 $V3flag=3;
       }
     }
     if (40<=$WW[0] && $WW[0]<=41) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if (50<=$WW[0] && $WW[0]<=99) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }

   } #end if VV<1000-----------

################------------------------------------------------------------
#Mellombra sikt---------
   if (1000<=$VV[0] && $VV[0]<10000) {
     if ((0<=$WW[0] && $WW[0]<=3) || (4<=$WW[0] && $WW[0]<=16) || (20<=$WW[0] && $WW[0]<=27)) {
       if (0<=$WW[0] && $WW[0]<=3) { 
	 $WWflag=10;
	 $WWcorr=10;
       }

       
=comment

##################################################
#Ev. Sett inn t�kedis-------------
       if ($V1[0] != 19 && $V2[0] != 19 && $V3[0] != 19) {
	 if ($V3_missing[0]==0) {
	   $V3flag=10;
	   $V3corr=19;
	 }
	 if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	   $V2flag=10;
	   $V2corr=19;
	 }
	 if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
	   $V1flag=10;
	   $V1corr=19;
	 }
       }

#Slett t�ke-------------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
       }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
##################################################

=cut


#Vi gj�r det p� denne m�ten:
#Sett inn t�kedis---------------------
       if ($V1[0]==18) {
	   $V1flag=10;
	   $V1corr=19;
       }
       if ($V2[0]==18) {
	   $V2flag=10;
	   $V2corr=19;
       }
       if ($V3[0]==18) {
	   $V3flag=10;
	   $V3corr=19;
       }
       

   } #end if (0<=$WW[0] && $WW[0]<=3)................

     if (17<=$WW[0] && $WW[0]<=19) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }

     #S� begynner vi med innsetting i V4, V5 osv. v�ret siden forrige hovedobs.
     if ((28<=$WW[0] && $WW[0]<=29) || (36<=$WW[0] && $WW[0]<=37)) {
  


     #Sett inn t�kedis-------------------
       if ($V1[0]==18) {
	 $V1flag=10;
	 $V1corr=19;
       }
       if ($V2[0]==18) {
	 $V2flag=10;
	 $V2corr=19;
       }
       if ($V3[0]==18) {
	 $V3flag=10;
	 $V3corr=19;
       }


       if ($WW[0]==28) { #Setter inn t�ke i V7 osv....
	 if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=18;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=18;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=18;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=18;
	   }
	 }
       }
       if ($WW[0]==29) { #Setter inn torden.
	 if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=20;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=20;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=20;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=20;
	   }
	 }
       }
       
       if (36<=$WW[0] && $WW[0]<=37) { #Setter inn sn�fokk
	 if ($V7[0] != 28 && $V6[0] != 28 && $V5[0] != 28 && $V4[0] != 28) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=28;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=28;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=28;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=28;
	   }
	 }
       }
     } #end if ((28<=$WW[0] && $WW[0]<=29) || (36<=$WW[0] && $WW[0]<=37)

     if (30<=$WW[0] && $WW[0]<=35) {
       $WWflag=6;
     }

     if ($WW[0]==38) {

       #Setter inn sn�fokk--------------
       if ($V1[0]==18) {
	 $V1flag=10;
	 $V1corr=28;
       }
       if ($V2[0]==18) {
	 $V2flag=10;
	 $V2corr=28;
	   }
       if ($V3[0]==18) {
	 $V3flag=10;
	 $V3corr=28;
       }
       
      
       
       #Setter inn sn�fokk--------------
       if ($V7[0] != 28 && $V6[0] != 28 && $V5[0] != 28 && $V4[0] != 28) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=28;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=28;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=28;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=28;
	 }
       }
     } #end if WW=38

     if ($WW[0]==39) {
       $WWflag=10;
       $WWcorr=38;


       #Setter inn sn�fokk--------------
       if ($V1[0]==18) {
	 $V1flag=10;
	 $V1corr=28;
       }
       if ($V2[0]==18) {
	 $V2flag=10;
	 $V2corr=28;
	   }
       if ($V3[0]==18) {
	 $V3flag=10;
	 $V3corr=28;
       }
      
       
       #Setter inn sn�fokk--------------
       if ($V7[0] != 28 && $V6[0] != 28 && $V5[0] != 28 && $V4[0] != 28) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=28;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=28;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=28;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=28;
	 }
       }
     } #end if WW=39

     if (40<=$WW[0] && $WW[0]<=41) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
     }
     if (42<=$WW[0] && $WW[0]<=49) {
       $WWflag=3;
       $VVflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if (50<=$WW[0] && $WW[0]<=99) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }

   } #end if (1000<=$VV[0] && $VV[0]<10000) {


###############################
##Meget bra sikt-------------------------------------------
   if ($VV[0]>=10000) {
     if (0<=$WW[0] && $WW[0]<=16) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
     }
     if (17<=$WW[0] && $WW[0]<=19) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if (20<=$WW[0] && $WW[0]<=27) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
     }
     if ($WW[0]==28) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
       #Setter inn t�ke i V4-V5 osv....
       if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=18;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=18;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=18;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=18;
	 }
       }
     }

     if ($WW[0]==29) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
       #Setter inn torden i V4-V5 osv....
       if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=20;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=20;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=20;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=20;
	 }
       }
     }
     if (30<=$WW[0] && $WW[0]<=35) {
       $WWflag=6;
     }

     if (36<=$WW[0] && $WW[0]<=38) {

	  #Setter inn sn�fokk--------------
       if ($V1[0]==18) {
	 $V1flag=10;
	 $V1corr=28;
       }
       if ($V2[0]==18) {
	 $V2flag=10;
	 $V2corr=28;
	   }
       if ($V3[0]==18) {
	 $V3flag=10;
	 $V3corr=28;
       }
      
       #Setter inn sn�fokk--------------
       if ($V7[0] != 28 && $V6[0] != 28 && $V5[0] != 28 && $V4[0] != 28) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=28;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=28;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=28;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=28;
	 }
       }
     } 
     if ($WW[0]==39) {
       $WWflag=10;
       $WWcorr=38;



 #Setter inn sn�fokk--------------
       if ($V1[0]==18) {
	 $V1flag=10;
	 $V1corr=28;
       }
       if ($V2[0]==18) {
	 $V2flag=10;
	 $V2corr=28;
	   }
       if ($V3[0]==18) {
	 $V3flag=10;
	 $V3corr=28;
       }

      
       #Setter inn sn�fokk--------------
       if ($V7[0] != 28 && $V6[0] != 28 && $V5[0] != 28 && $V4[0] != 28) {
	 if ($V7_missing[0]==0) {
	   $V7flag=10;
	   $V7corr=28;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=28;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=28;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=28;
	 }
       }
     } #end if WW=39

     if (40<=$WW[0] && $WW[0]<=41) {
       #Sletter t�ke--------------
       if ($V1[0]==18) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==18) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==18) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
     }
     if (42<=$WW[0] && $WW[0]<=49) {
       $WWflag=3;
       $VVflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }
     if (50<=$WW[0] && $WW[0]<=99) {
       $WWflag=3;
       if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
       if ($V2_missing[0]==0) {
	 $V2flag=3;
       }
       if ($V3_missing[0]==0) {
	 $V3flag=3;
       }
     }

   } #end if VV>=10000-----------------

#T�kedis, slett t�kedis hvis t�ke fortsatt er med.
   if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) {
     if ($V1[0]==18 || $V2[0]==18 || $V3[0]==18) {
       if ($V1[0]==19 && $V1flag !=10) {
	 $V1flag=13;
	 $V1_missing[0]=2;
       }
       if ($V2[0]==19 && $V2flag !=10) {
	 $V2flag=13;
	 $V2_missing[0]=2;
	   }
       if ($V3[0]==19 && $V3flag !=10) {
	 $V3flag=13;
	 $V3_missing[0]=2;
       }
     }
   }
   if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14 || $V1[0]==29 || $V2[0]==29 || $V3[0]==29) {
     if ($WW_missing[0]==0) {
       $WWflag=3;
     }
     if ($V1_missing[0]==0) {
	 $V1flag=3;
       }
     if ($V2_missing[0]==0) {
       $V2flag=3;
     }
     if ($V3_missing[0]==0) {
       $V3flag=3;
     }
   }
   if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) { #Sletter �lr�yk---------------
     if ($V1[0]==21) {
       $V1flag=13;
       $V1_missing[0]=2;
     }
     if ($V2[0]==21) {
       $V2flag=13;
       $V2_missing[0]=2;
     }
     if ($V3[0]==21) {
       $V3flag=13;
       $V3_missing[0]=2;
     }
   }

 } # end ($V3[0]==18 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) |


} #end sub komb. 7_a-----------






#----------------------------------------------------------------------------------------------#
#S� begynner vi med komb. 7b Ikke-nedb�r, t�ke og sn�fokk. Minst to v�rsymboler tilstede.------------ 
sub komb_7_b  {
#Begynner med V1=t�ke, V2=sn�fokk, V3 er (ikke-nedb�r, ikke-torden eller manglende),
#og varierer denne kombinasjonen slik at vi f�r 6 muligheter----------------------

if (($V1[0]==18 && $V2[0]==28 && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29)))) ||
($V1[0]==18 && $V3[0]==28 && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)))) ||
($V2[0]==18 && $V1[0]==28 && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || (17<=$V3[0] && $V3[0]<=19) || (21<=$V3[0] && $V3[0]<=29)))) ||
($V2[0]==18 && $V3[0]==28 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)))) ||
($V3[0]==18 && $V1[0]==28 && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || (17<=$V2[0] && $V2[0]<=19) || (21<=$V2[0] && $V2[0]<=29)))) ||
($V3[0]==18 && $V2[0]==28 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || (17<=$V1[0] && $V1[0]<=19) || (21<=$V1[0] && $V1[0]<=29)))))

  {

=comment

#Legger inn ok-testing--------
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V1[0]==18 && $V2[0]==28)) {
	return;}
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V2[0]==18 && $V3[0]==28)) {
	return;}
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V3[0]==18 && $V1[0]==28)) {
	return;}
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V1[0]==18 && $V3[0]==28)) {
	return;}
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V1[0]==28 && $V2[0]==18)) {
	return;}
    if (($VV_missing[0]==0 && $VV[0]<1000) && ($V2[0]==28 && $V3[0]==18)) {
	return;}

=cut

    if ($VV_missing[0]==0 && $VV[0]<1000) {
      if (0<=$WW[0] && $WW[0]<=19) { #Feil i v�rsymbol eller WW
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
      if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}

	#Til V4, V5, .......
	if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	 if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=8;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=8;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=8;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=8;
	   }
	 }
       }
       if ($WW[0]==21) { 
	 if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=3;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=3;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=3;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=3;
	   }
	 }
       }
       if ($WW[0]==22) { 
	 if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=2;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=2;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=2;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=2;
	   }
	 }
       }
       if ($WW[0]==23) { 
	 if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=1;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=1;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=1;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=1;
	   }
	 }
       }
       if ($WW[0]==25) { 
	 if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=7;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=7;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=7;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=7;
	   }
	 }
       }
       if ($WW[0]==26) { 
	 if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=5;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=5;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=5;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=5;
	   }
	 }
       }
       if ($WW[0]==27) { 
	 if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=10;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=10;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=10;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=10;
	   }
	 }
       }
     } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))

      if ($WW[0]==24) { 
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}

	if ($V7[0] != 14 && $V6[0] != 14 && $V5[0] != 14 && $V4[0] != 14) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=14;
	  }
	}
      }

      if ($WW[0]==28) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=18;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=18;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=18;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=18;
	  }
	}
      }
      if ($WW[0]==29) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=20;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=20;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=20;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=20;
	  }
	}
      }
      if ((30<=$WW[0] && $WW[0]<=35) && (40<=$WW[0] && $WW[0]<=99)) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
      
      if (36<=$WW[0] && $WW[0]<=39) {
	if ($V1[0]==18) {
	  $V1flag=6; 
	}
	if ($V2[0]==18) {
	  $V2flag=6; 
	}
	if ($V3[0]==18) {
	  $V3flag=6; 
	}
      }

    } #end if VV<1000

#Mellomlang sikt
    if (1000<=$VV[0] && $VV[0]<=10000) {
      if (0<=$WW[0] && $WW[0]<=16) {
	$WWflag=10;
	$WWcorr=38;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
      }	

   
      if ($WW[0]==17) {

	if ($V1[0]==18) {
	    $V1flag=10;
	    $V1corr=20; #Setter inn torden-------
	}
	if ($V2[0]==18) {
	    $V2flag=10;
	    $V2corr=20; #Setter inn torden-------
	}
	if ($V3[0]==18) {
	    $V3flag=10;
	    $V3corr=20; #Setter inn torden-------
	}

      } #end if WW=17
      
      if (18<=$WW[0] && $WW[0]<=19) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
	
      if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	
	#Til V4, V5, .......
	if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	 if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=8;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=8;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=8;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=8;
	   }
	 }
       }
       if ($WW[0]==21) { 
	 if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=3;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=3;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=3;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=3;
	   }
	 }
       }
       if ($WW[0]==22) { 
	 if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=2;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=2;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=2;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=2;
	   }
	 }
       }
       if ($WW[0]==23) { 
	 if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=1;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=1;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=1;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=1;
	   }
	 }
       }
       if ($WW[0]==25) { 
	 if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=7;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=7;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=7;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=7;
	   }
	 }
       }
       if ($WW[0]==26) { 
	 if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=5;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=5;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=5;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=5;
	   }
	 }
       }
       if ($WW[0]==27) { 
	 if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=10;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=10;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=10;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=10;
	   }
	 }
       }
      } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))

      if ($WW[0]==24) { 
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}

	if ($V7[0] != 14 && $V6[0] != 14 && $V5[0] != 14 && $V4[0] != 14) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=14;
	  }
	}
      }

      if ($WW[0]==28) {
	$WWflag=10;
	$WWcorr=38;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
	if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=18;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=18;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=18;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=18;
	  }
	}
      }

      if ($WW[0]==29) {
	$WWflag=10;
	$WWcorr=38;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
	if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=20;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=20;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=20;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=20;
	  }
	}
      }

      if (30<=$WW[0] && $WW[0]<=35) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }

      if (36<=$WW[0] && $WW[0]<=41) {
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
      }

      if (42<=$WW[0] && $WW[0]<=49) {
	$WWflag=3;
	$VVflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
      if (50<=$WW[0] && $WW[0]<=99) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }

    } #end (1000<=VV && VV<=10000)


#God sikt-------------
    if ($VV[0]>10000) {
      if (0<=$WW[0] && $WW[0]<=16) {
	$WWflag=10;
	$WWcorr=36;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
      }	
      
      if ($WW[0]==17) {

	if ($V1[0]==18) {
	  $V1flag=10;
	  $V1corr=20; #Setter inn torden-------
	  }
	if ($V2[0]==18) {
	  $V2flag=10;
	  $V2corr=20; #Setter inn torden-------
	  }
	if ($V3[0]==18) {
	  $V3flag=10;
	  $V3corr=20; #Setter inn torden-------
	}

      } #end if WW=17

      if (18<=$WW[0] && $WW[0]<=19) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }

       if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	
	#Til V4, V5, .......
	if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	 if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=8;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=8;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=8;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=8;
	   }
	 }
       }
       if ($WW[0]==21) { 
	 if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=3;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=3;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=3;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=3;
	   }
	 }
       }
       if ($WW[0]==22) { 
	 if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=2;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=2;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=2;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=2;
	   }
	 }
       }
       if ($WW[0]==23) { 
	 if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=1;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=1;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=1;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=1;
	   }
	 }
       }
       if ($WW[0]==25) { 
	 if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=7;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=7;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=7;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=7;
	   }
	 }
       }
       if ($WW[0]==26) { 
	 if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=5;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=5;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=5;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=5;
	   }
	 }
       }
       if ($WW[0]==27) { 
	 if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=10;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=10;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=10;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=10;
	   }
	 }
       }
      } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))

      if ($WW[0]==24) { 
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}

	if ($V7[0] != 14 && $V6[0] != 14 && $V5[0] != 14 && $V4[0] != 14) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=14;
	  }
	}
      }

      if ($WW[0]==28) {
	$WWflag=10;
	$WWcorr=36;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
	if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=18;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=18;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=18;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=18;
	  }
	}
      }

       if ($WW[0]==29) {
	$WWflag=10;
	$WWcorr=36;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
	if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=20;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=20;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=20;
	  }
	  if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=20;
	  }
	}
      }

      if (30<=$WW[0] && $WW[0]<=35) {
	$WWflag=6;
      }
      if ((36<=$WW[0] && $WW[0]<=37) || (40<=$WW[0] && $WW[0]<=41)) {
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
      }
      if ($WW[0]==39) {
	$WWflag=10;
	$WWcorr=38;
	if ($V1[0]==18) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter t�ke-------
	}
	if ($V2[0]==18) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter t�ke-------
	}
	if ($V3[0]==18) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter t�ke-------
	}
      }
      
      if (42<=$WW[0] && $WW[0]<=49) {
	$WWflag=3;
	$VVflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
      if (50<=$WW[0] && $WW[0]<=99) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }

    } #end if VV>=10000-----------------

#T�kedis, slett t�kedis hvis t�ke fortsatt er med.
    if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) {
      if ($V1[0]==18 || $V2[0]==18 || $V3[0]==18) {
	if ($V1[0]==19 && $V1flag !=10) {
	  $V1flag=13;
	  $V1_missing[0]=2;
	}
	if ($V2[0]==19 && $V2flag !=10) {
	  $V2flag=13;
	  $V2_missing[0]=2;
	}
	if ($V3[0]==19 && $V3flag !=10) {
	  $V3flag=13;
	  $V3_missing[0]=2;
	}
      }
    }
    if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14 || $V1[0]==29 || $V2[0]==29 || $V3[0]==29) {
      if ($WW_missing[0]==0) {
	$WWflag=3;
      }
      if ($V1_missing[0]==0) {
	$V1flag=3;
      }
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }
    if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) { #Sletter �lr�yk---------------
      if ($V1[0]==21) {
	$V1flag=13;
	$V1_missing[0]=2;
      }
      if ($V2[0]==21) {
	$V2flag=13;
	$V2_missing[0]=2;
      }
      if ($V3[0]==21) {
	$V3flag=13;
	$V3_missing[0]=2;
      }
    }


  }# end hele regla ($V3[0]==18 && $V2[0]==28 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V

} #end sub komb_7_b--------




sub komb_7_c { #sn�fokk (annet) (annet)
   #Minst ett symbol sn�fokk. De andre enten manglende eller (ikke-torden, ikke-nedb�r, ikke-t�ke)-----------
   #Det blir tre kombinasjoner----------------------

  if (($V1[0]==28 && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=29))) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=29)))) ||
($V2[0]==28 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=29))) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=29)))) ||
($V3[0]==28 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=29))) && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=29)))))
  
  {

=comment

#Legger inn ok-testing-----
    if (36<=$WW[0] && $WW[0]<=39) { return;}
###

=cut

    if (0<=$WW[0] && $WW[0]<=16) {
      $WWflag=10;
      $WWcorr=36;
    }
    if ($WW[0]==17) {
      if ($V1[0] !=20 && $V2[0] !=20 && $V3[0] !=20) {
	if ($V3_missing[0]==0) {
	  $V3flag=10;
	  $V3corr=20;
	}
	if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	  $V2flag=10;
	  $V2corr=20;
	}
	if ($V1_missing[0]==0 && $V2_missing[0]>0 && $V3_missing[0]>0) {
	  $V1flag=10;
	  $V1corr=20;
	}
      }
    }

    if ($WW[0]==18 || $WW[0]==19 || $WW[0]==24) {
      $WWflag=3;
      if ($V1_missing[0]==0) {
	$V1flag=3;
      }
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }

    if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27)) {
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	
	#Til V4, V5, .......
	if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	 if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=8;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=8;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=8;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=8;
	   }
	 }
       }
       if ($WW[0]==21) { 
	 if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=3;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=3;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=3;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=3;
	   }
	 }
       }
       if ($WW[0]==22) { 
	 if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=2;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=2;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=2;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=2;
	   }
	 }
       }
       if ($WW[0]==23) { 
	 if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=1;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=1;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=1;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=1;
	   }
	 }
       }
       if ($WW[0]==25) { 
	 if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=7;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=7;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=7;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=7;
	   }
	 }
       }
       if ($WW[0]==26) { 
	 if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=5;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=5;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=5;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=5;
	   }
	 }
       }
       if ($WW[0]==27) { 
	 if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	   if ($V7_missing[0]==0) {
	     $V7flag=10;
	     $V7corr=10;
	   }
	   if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	     $V6flag=10;
	     $V6corr=10;
	   }
	   if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V5flag=10;
	     $V5corr=10;
	   }
	   if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	     $V4flag=10;
	     $V4corr=10;
	   }
	 }
       }
      } #end if ((20<=$WW[0] && $WW[0]<=23) || (25<=$WW[0] && $WW[0]<=27))
    
    if ($WW[0]==28) {
      $WWflag=10;
      $WWcorr=36;
      
      if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	if ($V7_missing[0]==0) {
	  $V7flag=10;
	   $V7corr=18;
	 }
	 if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	   $V6flag=10;
	   $V6corr=18;
	 }
	 if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V5flag=10;
	   $V5corr=18;
	 }
	 if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	   $V4flag=10;
	   $V4corr=18;
	 }
       }
    }
    
    if ($WW[0]==29) {
      $WWflag=10;
      $WWcorr=36;
      
      if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	if ($V7_missing[0]==0) {
	  $V7flag=10;
	  $V7corr=20;
	}
	if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	  $V6flag=10;
	  $V6corr=20;
	}
	if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V5flag=10;
	  $V5corr=20;
	}
	if ($V4_missing[0]==0 && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	  $V4flag=10;
	  $V4corr=20;
	}
      }
    }
    
    if ((30<= $WW[0] && $WW[0]<=35) && (40<= $WW[0] && $WW[0]<=49) && (50<= $WW[0] && $WW[0]<=99)){
    #Feil i v�rsymbol eller WW. Senere.. Flagger mistenkelig her.
      $WWflag=3;
      if ($V1_missing[0]==0) {
	$V1flag=3;
      }
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }

    if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) {
      if ($VV[0]>10000) {
	if ($V1[0]==19) {
	  $V1flag=13;
	  $V1_missing[0]=2;
	}
	if ($V2[0]==19) {
	  $V2flag=13;
	  $V2_missing[0]=2;
	}
	if ($V3[0]==19) {
	  $V3flag=13;
	  $V3_missing[0]=2;
	}
      }
    }

    if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14) { #Isslag: Feil i v�rsymbol eller WW. Senere.
      if ($WW_missing[0]==0) {
	$WWflag=3;
      }
      if ($V1_missing[0]==0) {
	$V1flag=3;
      }
      if ($V2_missing[0]==0) {
	$V2flag=3;
      }
      if ($V3_missing[0]==0) {
	$V3flag=3;
      }
    }

    if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) { #Sletter �lr�yk---------------
      if ($V1[0]==21) {
	$V1flag=13;
	$V1_missing[0]=2;
      }
      if ($V2[0]==21) {
	$V2flag=13;
	$V2_missing[0]=2;
      }
      if ($V3[0]==21) {
	$V3flag=13;
	$V3_missing[0]=2;
      }
    }

  } #end hele regla--------------

} #end sub komb_7_c





# Komb. 7d --------------------------------------
#-------------Ikke torden, Ikke nedb�r, Ikke t�ke eller Ikke sn�fokk ------
#-------------Andre v�rsymboler-----Ett v�rsymbol er kommet inn, de andre enten kommet inn eller manglende-----

sub komb_7_d {

  if ((((12<= $V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29) && ((12<= $V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29 || $V2_missing[0]>0) && ((12<= $V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29 || $V3_missing[0]>0)) ||
      (((12<= $V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29 || $V1_missing[0]>0) && ((12<= $V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29) && ((12<= $V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29 || $V3_missing[0]>0)) ||
      (((12<= $V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29 || $V1_missing[0]>0) && ((12<= $V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29 || $V2_missing[0]>0) && ((12<= $V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29)))

{

=comment

#Legger inn ok-testing------
	if (($VV[0]>10000) && ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=16) || (18<=$WW[0] && $WW[0]<=35))) { return;}
##

=cut


      if ($VV[0]>10000) {
	if ($WW[0]==5) {
	  #Ev. sett inn �lr�yk-----
	  if ($V1[0] !=21 && $V2[0] !=21 && $V3[0] !=21) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=21;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=21;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=21;
	    }
	  }
	}

	if ($WW[0]==13) {
	  #Ev. sett inn kornmo-----
	  if ($V1[0] !=29 && $V2[0] !=29 && $V3[0] !=29) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=29;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=29;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=29;
	    }
	  }
	}

	if ($WW[0]==17) {
	  #Ev. sett inn torden-----
	  if ($V1[0] !=20 && $V2[0] !=20 && $V3[0] !=20) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=20;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=20;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=20;
	    }
	  }
	}
	
	if (36<=$WW[0] && $WW[0]<=39) {
	  #Ev. sett inn sn�fokk-----
	  if ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=28;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=28;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=28;
	    }
	  }
	}
	
	if (40<=$WW[0] && $WW[0]<=49) {
	  $WWflag=10;
	  $WWcorr=0;
	}

	if (50<=$WW[0] && $WW[0]<=55) {
	  #Ev. sett inn yr-----
	  if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=8;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=8;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=8;
	    }
	  }
	}

	if (56<=$WW[0] && $WW[0]<=57) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}
      } #end if VV>10000-------

      if ($VV_missing[0]==0 && $VV[0]<1000) {
	if (0<=$WW[0] && $WW[0]<=39) {
	  $WWflag=3;
	  $VVflag=3;
	}
	if ((40<=$WW[0] && $WW[0]<=41) || $WW_missing[0]>0){
	  $WWflag=10;
	  $WWcorr=45;
	  #Ev. sett inn t�ke-----
	  if ($V1[0] !=18 && $V2[0] !=18 && $V3[0] !=18) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=18;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=18;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=18;
	    }
	  }
	}

	if (42<=$WW[0] && $WW[0]<=49) {
	  #Ev. sett inn t�ke-----
	  if ($V1[0] !=18 && $V2[0] !=18 && $V3[0] !=18) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=18;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=18;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=18;
	    }
	  }
	}

	if (50<=$WW[0] && $WW[0]<=99) {
	  $WWflag=3;
	  $VVflag=3;
	}

      } #end if VV<1000



      if (1000<=$VV[0] && $VV[0]<=10000) {
	if ((0<=$WW[0] && $WW[0]<4) || (6<=$WW[0] && $WW[0]<12) || (14<=$WW[0] && $WW[0]<16) || (40<=$WW[0] && $WW[0]<49) || (50<=$WW[0] && $WW[0]<=99)) {
	   #Ev. sett inn t�kedis-----



#Krever at alle symboler har kommet inn for denne: #Sett inn t�kedis.
	  if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19  && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=19;
	    }
    
	  }


#Krever 2 symboler videre nedover..  
	if ($WW[0]==5) {
	    #Ev. sett inn �lr�yk-----
	    if ($V1[0] !=21 && $V2[0] !=21 && $V3[0] !=21 && $V1_missing[0]==0 && $V2_missing[0]==0){
		if ($V3_missing[0]==0){
		    $V3flag=10;
		    $V3corr=21;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=21;
		}
	
	    }
	}

	if ($WW[0]==13) {
	  #Ev. sett inn kornmo-----
	    if ($V1[0] !=29 && $V2[0] !=29 && $V3[0] !=29 && $V1_missing[0]==0 && $V2_missing[0]==0) {
		if ($V3_missing[0]==0){
		    $V3flag=10;
		    $V3corr=29;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=29;
		}
		
	    }
	}

	if ($WW[0]==17) {
	  #Ev. sett inn torden-----
	    if ($V1[0] !=20 && $V2[0] !=20 && $V3[0] !=20 && $V1_missing[0]==0 && $V2_missing[0]==0) {
		if ($V3_missing[0]==0) {
		    $V3flag=10;
		    $V3corr=20;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=20;
		}
	      
	    }
	}

	if (18<=$WW[0] && $WW[0]<=35) {
	    #Ev. sett inn t�kedis-----
	    if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0) {
		if ($V3_missing[0]==0) {
		    $V3flag=10;
		    $V3corr=19;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=19;
		}
		
	    }
	}

	if (36<=$WW[0] && $WW[0]<=39) {
	    #Ev. sett inn sn�fokk-----
	    if ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28 && $V1_missing[0]==0 && $V2_missing[0]==0) {
		if ($V3_missing[0]==0) {
		    $V3flag=10;
		    $V3corr=28;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=28;
		}
		
	    }
	}
	
	if (40<=$WW[0] && $WW[0]<=41) {
	  #Ev. sett inn t�kedis-----
	    if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0) {
		if ($V3_missing[0]==0) {
		    $V3flag=10;
		    $V3corr=19;
		}
		if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		    $V2flag=10;
		    $V2corr=19;
		}
	    
	    }
	}

	if (42<=$WW[0] && $WW[0]<=49) {
	    $WWflag=3;
	    $VVflag=3;
	}



	if (50<=$WW[0] && $WW[0]<=99) {

	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=8;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=8;
	    }
	  }
	}

	if (56<=$WW[0] && $WW[0]<=57) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}

	#Setter n� inn t�kedis hvis det ikke er fra f�r og det er ledig plass, krever at alle symboler har kommet inn----------
	  if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	    #my $innsatt=0;
	    if ($V3flag !=10) { #Alts� hvis ikke korrigert.
	      $V3flag=10;
	      $V3corr=19;
	     # $innsatt=1;
	    }
	    #if ($V1_missing[0]==0 && $V2flag !=10 && $innsatt==0) { #Alts� hvis ikke korrigert.
	     # $V1flag=10;
	      #$V1corr=19;
	    #}
	  }
	
	} #end if 50<=WW<=99
	
      } #end 1000<VV og VV<=10000

      if ($VV[0]>=1000) {
	if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14) {     #isslag
	  if (0<=$WW[0] && $WW[0]<=49) {
	    $WWflag=6;
	  }
	  if (68<=$WW[0] && $WW[0]<=99) {
	    $WWflag=3;
	    if ($V1_missing[0]==0){
	      $V1flag=3;
	    }
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}

	if ($V1[0]==29 || $V2[0]==29 || $V3[0]==29) {     #kornmo
	  if (0<=$WW[0] && $WW[0]<=16) {
	    $WWflag=10;
	    $WWcorr=13;
	  }
	  if ($WW[0]==17 || (95<=$WW[0] && $WW[0]<=99)) {
	    if ($V1[0]==29) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V2[0]==29) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V3[0]==29) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter kornmo-------
	    }
	  }
	}

	if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) {     #t�kedis

	  if ($WW[0]==5) { #Setter evn inn �lr�yk--

=comment

	    if ($V1[0] !=21 && $V2[0] !=21 && $V3[0] !=21 && $V1_missing[0]==0 && $V2_missing[0]==0) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=21;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=21;
	      }
	    }
	   
=cut

            if ($V1[0]==19) {
		if ($V2[0] !=21 && $V3[0] !=21) {
		    $V1flag=10;
		    $V1corr=21; #Setter inn �lr�yk
		}
		else {
		    $V1flag=13;
		    $V1_missing[0]=2; #Sletter t�kedis-------
		}
	    }

	    if ($V2[0]==19) {
		if ($V1[0] !=21 && $V3[0] !=21) {
		    $V2flag=10;
		    $V2corr=21; #Setter inn �lr�yk
		}
		else {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter t�kedis-------
	        }
	    }

	    if ($V3[0]==19) {
		if ($V1[0] !=21 && $V2[0] !=21) {
		    $V3flag=10;
		    $V3corr=21; #Setter inn �lr�yk
		}
		else {
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter t�kedis-------
		}
	    }
	  } #end if WW=5------------
	
	  if (36<=$WW[0] && $WW[0]<=39) {
	    if ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28 && $V1_missing[0]==0 && $V2_missing[0]==0) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=28;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=28;
	      }
	    }
	  }

	  if (42<=$WW[0] && $WW[0]<=49) {
	    $WWflag=3;
	    $VVflag=3;
	  }


	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }

	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}
	} #end if V1, V2 eller V3 er t�kedis----------

#Hvis ett eller flere tegn er �lr�yk------
	if ($V1[0]==21 || $V2[0]==21 || $V3[0]==21) {     #�lr�yk
	  if ((10<=$WW[0] && $WW[0]<=29) || (40<=$WW[0] && $WW[0]<=41)) {

=comment

	    #Setter evn inn t�kedis-------
	    if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=19;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=19;
	      }
	    }

=cut

           if ($V1[0]==21) {
	    if ($V2[0] !=19 && $V3[0] !=19) {
	      $V1flag=10;
	      $V1corr=19; #Setter inn t�kedis-----------
	    } 
	    else {
	        $V1flag=13;
	        $V1_missing[0]=2; #Sletter �lr�yk-------
	    }
           }  
           if ($V2[0]==21) {
	       if ($V1[0] !=19 && $V3[0] !=19) {
		   $V2flag=10;
		   $V2corr=19; #Setter inn t�kedis-----------
	       } 
	       else {
		   $V2flag=13;
		   $V2_missing[0]=2; #Sletter �lr�yk-------
	       }
	   }
	    if ($V3[0]==21) {
		if ($V2[0] !=19 && $V1[0] !=19) {
		   $V3flag=10;
		   $V3corr=19; #Setter inn t�kedis-----------
	       } 
	       else {
		   $V3flag=13;
		   $V3_missing[0]=2; #Sletter �lr�yk-------
	       }
	    } 
}
	  if (36<=$WW[0] && $WW[0]<=39) {

=comment

	    #Setter evn inn sn�fokk-------
	    if ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28 && $V1_missing[0]==0 && $V2_missing[0]==0) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=28;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=28;
	      }
	    }
	
=cut

            if ($V1[0]==21) {
		if ($V2[0] !=28 && $V3[0] !=28) {
		    $V1flag=10;
		    $V1corr=28; #Setter inn sn�fokk-----------
		}  
		else {
		    $V1flag=13;
		    $V1_missing[0]=2; #Sletter �lr�yk-------
		}
	    }
	    if ($V2[0]==21) {
		if ($V1[0] !=28 && $V3[0] !=28) {
		    $V2flag=10;
		    $V2corr=28; #Setter inn sn�fokk-----------
		}  
		else {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter �lr�yk-------
		}
	    }
	    if ($V3[0]==21) {
		if ($V2[0] !=28 && $V1[0] !=28) {
		    $V3flag=10;
		    $V3corr=28; #Setter inn sn�fokk-----------
		}  
		else {
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter �lr�yk-------
		}
	    }
          }
	  if (42<=$WW[0] && $WW[0]<=49) {
	    $WWflag=3;
	    $VVflag=3;
	  }


	  if (50<=$WW[0] && $WW[0]<=99) {
	   if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }
	  
	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
	      $V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }

	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	   }
	  }
	   #Sletter n� �lr�yk hvis det skulle v�re igjen-----
	   if ($V3[0]==21 && $V3flag !=10) {
	     $V3flag=13;
	     $V3_missing[0]=2; #Sletter �lr�yk
	   }

	   if ($V2[0]==21 && $V2flag !=10) {
	     $V2flag=13;
	     $V2_missing[0]=2; #Sletter �lr�yk
	   }

	   if ($V1[0]==21 && $V1flag !=10) {
	     $V1flag=13;
	     $V1_missing[0]=2; #Sletter �lr�yk
	   }


	   
       




	 } #end if ww=(50-99)--------



	} #end if �lr�yk----------
	
      } #end if VV>=1000

    } #end hele regla----------

} #end sub komb. 7 d---------





sub komb_7_e { #Ingen v�rsymboler----Kan i praksis kun korrigere p� V1 og V4 
  if ($V3_missing[0]>0 && $V2_missing[0]>0 && $V1_missing[0]>0) { 
    if ($VV[0]>=1000) {


=comment

      if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=12) || (14<=$WW[0] && $WW[0]<=16) || (18<=$WW[0] && $WW[0]<=35)) {
	$V1flag=10;
	$V1corr=19;
      }
      if ($WW[0]==5) {
	$V1flag=10;
	$V1corr=21;
      }
      if ($WW[0]==13) {
	$V1flag=10;
	$V1corr=29;
      }
      if ($WW[0]==17) {
	$V1flag=10;
	$V1corr=20;
      }

=cut

      if (18<=$WW[0] && $WW[0]<=19) {
	$WWflag=3;
      }
    
      
      #Til V4, V5, .......
      if ($WW[0]==20) { #Setter inn i V7, evn V6, evn V5, evn V4 etter kode, f�rst WW=20 som tilsvarer yr (kornsn�)
	if ($V7[0] != 8 && $V6[0] != 8 && $V5[0] != 8 && $V4[0] != 8) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=8;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=8;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=8;
	   }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=8;
	  }
	}
      }
      if ($WW[0]==21) { 
	if ($V7[0] != 3 && $V6[0] != 3 && $V5[0] != 3 && $V4[0] != 3) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=3;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=3;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=3;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=3;
	  }
	}
      }

      if ($WW[0]==22) { 
	if ($V7[0] != 2 && $V6[0] != 2 && $V5[0] != 2 && $V4[0] != 2) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=2;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=2;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=2;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=2;
	  }
	}
      }
      if ($WW[0]==23) { 
	if ($V7[0] != 1 && $V6[0] != 1 && $V5[0] != 1 && $V4[0] != 1) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=1;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=1;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=1;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=1;
	  }
	}
      }
      if ($WW[0]==24) {  
	if ($V7[0] != 14 && $V6[0] != 14 && $V5[0] != 14 && $V4[0] != 14) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=14;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=14;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=14;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=14;
	  }
	}
      }

      if ($WW[0]==25) { 
	if ($V7[0] != 7 && $V6[0] != 7 && $V5[0] != 7 && $V4[0] != 7) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=7;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=7;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=7;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=7;
	  }
	}
      }
      if ($WW[0]==26) { 
	if ($V7[0] != 5 && $V6[0] != 5 && $V5[0] != 5 && $V4[0] != 5) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=5;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=5;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=5;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=5;
	  }
	}
      }
      if ($WW[0]==27) { 
	if ($V7[0] != 10 && $V6[0] != 10 && $V5[0] != 10 && $V4[0] != 10) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=10;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=10;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=10;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=10;
	  }
	}
      }
      
      if ($WW[0]==28) {
	if ($V7[0] != 18 && $V6[0] != 18 && $V5[0] != 18 && $V4[0] != 18) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=18;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=18;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=18;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=18;
	  }
	}
      }
      
      if ($WW[0]==29) {
	if ($V7[0] != 20 && $V6[0] != 20 && $V5[0] != 20 && $V4[0] != 20) {
	  if ($V7_missing[0]==0) {
	    $V7flag=10;
	    $V7corr=20;
	  }
	  if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	    $V6flag=10;
	    $V6corr=20;
	  }
	  if ($V5_missing[0]==0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V5flag=10;
	    $V5corr=20;
	  }
	  if (($V4_missing[0]==0 || $V4_missing[0]>0) && $V5_missing[0]>0 && $V6_missing[0]>0 && $V7_missing[0]>0) {
	    $V4flag=10;
	    $V4corr=20;
	  }
	}
      }


      if (30<=$WW[0] && $WW[0]<=35) { 
	$WWflag=3;
      }

=comment
      
      if (36<=$WW[0] && $WW[0]<=39) {
	#Setter inn sn�fokk-------
	$V1flag=10;
	$V1corr=28;
      }
      
      if (40<=$WW[0] && $WW[0]<=41) {
	if ($VV_missing[0]==0 && $VV[0]<=10000) { 
	  #Setter inn t�kedis-------
	  $V1flag=10;
	  $V1corr=19;
	}
      }
      
=cut

      if (42<=$WW[0] && $WW[0]<=49) {
	$WWflag=3;
	$VVflag=3;
      }


=comment
      
      #Setter inn full pakke for WW=(50-99)-------------
      if (50<=$WW[0] && $WW[0]<=55) {
	#sett inn yr-----
	$V1flag=10;
	$V1corr=8;
      }
      
      if (56<=$WW[0] && $WW[0]<=57) {
	# sett inn isslag-----
	$V1flag=10;
	$V1corr=14;
      }
      
      if (58<=$WW[0] && $WW[0]<=59) {
	# sett inn regn-----
	
	$V1flag=10;
	$V1corr=3;
      }
      
      if (60<=$WW[0] && $WW[0]<=65) {
	# sett inn regn-----
	
	$V1flag=10;
	$V1corr=3;
      }
      

      if (66<=$WW[0] && $WW[0]<=67) {
	# sett inn isslag-----
	$V1flag=10;
	$V1corr=14;
      }
      
      if (68<=$WW[0] && $WW[0]<=69) {
	# sett inn sludd-----
	$V1flag=10;
	$V1corr=1;
      }
      
      if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	# sett inn sn�-----
	$V1flag=10;
	$V1corr=2;
      }
      
      if ($WW[0]==76) {
	# sett inn isn�ler-----
	
	$V1flag=10;
	$V1corr=16;
      }
      
      if ($WW[0]==77) {
	# sett inn kornsn�-----
	
	$V1flag=10;
	$V1corr=6;
      }
	
      if ($WW[0]==79) {
	# sett inn iskorn-----
	
	$V1flag=10;
	$V1corr=15;
      }
      
      if (80<=$WW[0] && $WW[0]<=82) {
	# sett inn regnbyger-----
	
	$V1flag=10;
	$V1corr=7;
      }
      
      
      if (83<=$WW[0] && $WW[0]<=84) {
	# sett inn sluddbyger-----
	
	$V1flag=10;
	$V1corr=4;
      }
      
      if (85<=$WW[0] && $WW[0]<=86) {
	# sett inn sn�byger-----
	
	$V1flag=10;
	$V1corr=5;
      }
      
      if ($WW[0]==87) {
	# sett inn spr�hagl-----
	
	$V1flag=10;
	$V1corr=9;
      }
      
      if ($WW[0]==88) {
	# sett inn hagl-----
	
	$V1flag=10;
	$V1corr=10;
      }
      
      if (89<=$WW[0] && $WW[0]<=90) {
	# sett inn ishagl-----
	
	$V1flag=10;
	$V1corr=11;
      }

=cut
      
      if (91<=$WW[0] && $WW[0]<=92) {
	  # sett inn regn-----
	  
	  #$V1flag=10;
	  #$V1corr=3;
	  
	  #Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0) {
		  $V7flag=10;
		  $V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		  $V6flag=10;
		  $V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
		  $V5flag=10;
		  $V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
		  $V4flag=10;
		  $V4corr=20;
	      }
	  }
      }
    } #end if VV>=1000


    if ($VV_missing[0]==0 && $VV[0]<1000) {
      if (0<=$WW[0] && $WW[0]<=41) {
	$WWflag=3;
	$VVflag=3;
      }

=comment

      if (42<=$WW[0] && $WW[0]<=49) {
	$V1flag=10;
	$V1corr=18;
      }

=cut

      if (50<=$WW[0] && $WW[0]<=99) {
	$WWflag=3;
	$VVflag=3;
      }
    }


  } #end if alle missing
} #end sub 7e.-----------------------------------





sub komb_7_f {
  #ren luft (annet) (annet)
#Ikke torden, ikke-nedb�r, ikke-sn�fokk, ikke-t�ke, premiss ett symbol ren luft (22)
 if (($V1[0]==22 && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29)) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29))) ||
($V2[0]==22 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29)) && ($V3_missing[0]>0 || ((12<=$V3[0] && $V3[0]<=14) || $V3[0]==17 || $V3[0]==19 || (21<=$V3[0] && $V3[0]<=27) || $V3[0]==29))) ||
($V3[0]==22 && ($V1_missing[0]>0 || ((12<=$V1[0] && $V1[0]<=14) || $V1[0]==17 || $V1[0]==19 || (21<=$V1[0] && $V1[0]<=27) || $V1[0]==29)) && ($V2_missing[0]>0 || ((12<=$V2[0] && $V2[0]<=14) || $V2[0]==17 || $V2[0]==19 || (21<=$V2[0] && $V2[0]<=27) || $V2[0]==29)))) 

  {

=comment

#Legger inn ok-testing-------
if (($VV[0]>=75000) && ((0<=$WW[0] && $WW[0]<=3) || (11<=$WW[0] && $WW[0]<=41))) { 
return;} 
########

=cut


    if ($VV[0]>=75000) {
      if (4<=$WW[0] && $WW[0]<=10) {
	$VVflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
      if (42<=$WW[0] && $WW[0]<=99) {
	$VVflag=3;
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
      }
    } #end VV>=75000

    if (10000<$VV[0] && $VV[0]<75000) {
      if (0<=$WW[0] && $WW[0]<=41) {
	if ($V1[0]==22) { #Sletter ren luft
	  $V1flag=13;
	  $V1_missing[0]=2;
	}
	if ($V2[0]==22) { #Sletter ren luft
	  $V2flag=13;
	  $V2_missing[0]=2;
	}
	if ($V3[0]==22) { #Sletter ren luft
	  $V3flag=13;
	  $V3_missing[0]=2;
	}
      }
      if (42<=$WW[0] && $WW[0]<=49) {
	$WWflag=10;
	$WWcorr=0;
	if ($V1[0]==22) { #Sletter ren luft
	  $V1flag=13;
	  $V1_missing[0]=2;
	}
	if ($V2[0]==22) { #Sletter ren luft
	  $V2flag=13;
	  $V2_missing[0]=2;
	}
	if ($V3[0]==22) { #Sletter ren luft
	  $V3flag=13;
	  $V3_missing[0]=2;
	}
      }

      if (50<=$WW[0] && $WW[0]<=99) {
	#G�r her innp� kombinasjon 7 d, VV>=1000-------------

	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=8;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=8;
	    }
	  }
	}

	if (56<=$WW[0] && $WW[0]<=57) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
      }

	#Setter n� inn t�kedis hvis det ikke er fra f�r og det er ledig plass, krever at alle symboler har kommet inn----------
	  #if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	    #my $innsatt=0;
	   # if ($V3flag !=10) { #Alts� hvis ikke korrigert.
	    #  $V3flag=10;
	     # $V3corr=19;
	     # $innsatt=1;
	    #}
	    #if ($V1_missing[0]==0 && $V2flag !=10 && $innsatt==0) { #Alts� hvis ikke korrigert.
	     # $V1flag=10;
	      #$V1corr=19;
	    #}
	  #}
	




	if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14) {     #isslag
	  if (68<=$WW[0] && $WW[0]<=99) {
	    $WWflag=3;
	    if ($V1_missing[0]==0){
	      $V1flag=3;
	    }
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}
      
	if ($V1[0]==29 || $V2[0]==29 || $V3[0]==29) {     #kornmo
	  
	  if (95<=$WW[0] && $WW[0]<=99) {
	    if ($V1[0]==29) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V2[0]==29) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V3[0]==29) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter kornmo-------
	    }
	  }
	}


	  if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) { #T�kedis
	    if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }

	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0 && $V3[0] !=19) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	  #Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}
	  } #end if V1, V2 eller V3 er t�kedis----------

	  if ($V1[0]==21 || $V1[0]==21 || $V1[0]==21) { #�lr�yk
	     if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }
	  
	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
	      $V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }

	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	   }
	  }
	   #Sletter n� �lr�yk hvis det skulle v�re igjen-----
	     if ($V3[0]==21 && $V3flag !=10) {
	       $V3flag=13;
	       $V3_missing[0]=2; #Sletter �lr�yk
	     }
	     
	     if ($V2[0]==21 && $V2flag !=10) {
	       $V2flag=13;
	       $V2_missing[0]=2; #Sletter �lr�yk
	     }
	     
	     if ($V1[0]==21 && $V1flag !=10) {
	       $V1flag=13;
	       $V1_missing[0]=2; #Sletter �lr�yk
	     }
	   } #end if �lr�yk----------

	  #Sjekker om det er noen "Ren luft"-symboler igjen, sletter de is�fall.
	if ($V3[0]==22 && $V3flag !=10) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	  
	if ($V2[0]==22 && $V2flag !=10) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22 && $V1flag !=10) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}
	
      } #end 50<=ww<=99-----

    } #end if (10000<$VV[0] && $VV[0]<75000) Mellomlang sikt.

    if (1000<=$VV[0] && $VV[0]<=10000) {
      if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=41)) {



=comment

	if ($WW[0]==10) { #Setter evn. inn t�kedis-------
	  if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=19;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=19;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=19;
	    }
	  }
	}

=cut

####Kornmo--------------------------------------------------------
	if ($WW[0]==13) { #Setter evn. inn kornmo-------
	    if ($V3[0]==22) {
		if ($V1[0] !=29 && $V2[0] !=29) {
		    $V3flag=10;
		    $V3corr=29; #Setter inn kornmo
		}
		else {
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V2[0]==22) {
		if ($V1[0] !=29 && $V3[0] !=29) {
		    $V2flag=10;
		    $V2corr=29; #Setter inn kornmo
		}
		else {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V1[0]==22) {
		if ($V2[0] !=29 && $V3[0] !=29) {
		    $V1flag=10;
		    $V1corr=29; #Setter inn kornmo
		}
		else {
		    $V1flag=13;
		    $V1_missing[0]=2; #Sletter ren luft
		}
	    }
	}


############################

=comment

##Gammel m�te

	  if ($V1[0] !=29 && $V2[0] !=29 && $V3[0] !=29) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=29;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=29;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=29;
	    }
	  }
	}

=cut

###############

##Torden
    	if ($WW[0]==17) { #Setter evn. inn torden-------
	    if ($V3[0]==22) {
		if ($V1[0] !=20 && $V2[0] !=20) {
		    $V3flag=10;
		    $V3corr=20; #Setter inn torden
		}
		else {
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V2[0]==22) {
		if ($V1[0] !=20 && $V3[0] !=20) {
		    $V2flag=10;
		    $V2corr=20; #Setter inn torden
		}
		else {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V1[0]==22) {
		if ($V2[0] !=20 && $V3[0] !=20) {
		    $V1flag=10;
		    $V1corr=20; #Setter inn torden
		}
		else {
		    $V1flag=13;
		    $V1_missing[0]=2; #Sletter ren luft
		}
	    }
	}

###Sn�fokk
      	if (36<=$WW[0] && $WW[0]<=39) { #Setter evn. inn sn�fokk-------
	    if ($V3[0]==22) {
		if ($V1[0] !=28 && $V2[0] !=28) {
		    $V3flag=10;
		    $V3corr=28; #Setter inn sn�fokk
		}
		else {
		    $V3flag=13;
		    $V3_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V2[0]==22) {
		if ($V1[0] !=28 && $V3[0] !=28) {
		    $V2flag=10;
		    $V2corr=28; #Setter inn sn�fokk
		}
		else {
		    $V2flag=13;
		    $V2_missing[0]=2; #Sletter ren luft
		}
	    }
	    
	    if ($V1[0]==22) {
		if ($V2[0] !=28 && $V3[0] !=28) {
		    $V1flag=10;
		    $V1corr=28; #Setter inn sn�fokk
		}
		else {
		    $V1flag=13;
		    $V1_missing[0]=2; #Sletter ren luft
		}
	    }
	}
###############




################Gammel m�te � gj�re det p�.

=comment


	if ($WW[0]==17) { #Setter evn. inn torden-------
	  if ($V1[0] !=20 && $V2[0] !=20 && $V3[0] !=20) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=20;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=20;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=20;
	    }
	  }
	}
	if (36<=$WW[0] && $WW[0]<=39) { #Setter evn. inn sn�fokk-------
	  if ($V1[0] !=28 && $V2[0] !=28 && $V3[0] !=28) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=28;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=28;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=28;
	    }
	  }
	}


	#Sletter ren luft hvis noen symboler er det:
	if ($V3[0]==22) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	  
	if ($V2[0]==22) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}

=cut

##################################


      } #end if ((0<=$WW[0] && $WW[0]<=4) || (6<=$WW[0] && $WW[0]<=41))

      if ($WW[0]==5) { #Setter evn. inn �lr�yk
	
	#Sletter ren luft hvis noen symboler er det:
	if ($V3[0]==22) {
	    if ($V1[0] !=21 && $V2[0] !=21) {
		$V3flag=10;
		$V3corr=21; #Setter inn �lr�yk
	    }
	    else {
		$V3flag=13;
		$V3_missing[0]=2; #Sletter ren luft
	    }
	}
	  
	if ($V2[0]==22) {
	    if ($V1[0] !=21 && $V3[0] !=21) {
		$V2flag=10;
		$V2corr=21; #Setter inn �lr�yk
	    }
	    else {
		$V2flag=13;
		$V2_missing[0]=2; #Sletter ren luft
	    }
	}
	
	if ($V1[0]==22) {
	    if ($V2[0] !=21 && $V3[0] !=21) {
		$V1flag=10;
		$V1corr=21; #Setter inn �lr�yk
	    }
	    else {
		$V1flag=13;
		$V1_missing[0]=2; #Sletter ren luft
	    }
	}
    } #end if WW=5------


      if (42<=$WW[0] && $WW[0]<=49) {
	$VVflag=3;
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=3;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=3;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=3;
	}
	#Sletter ren luft hvis noen symboler er det:
	if ($V3[0]==22) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	
	if ($V2[0]==22) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}
      }
    

      if (50<=$WW[0] && $WW[0]<=99) {
	#G�r her innp� kombinasjon 7 d, VV>=1000-------------

	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=8;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=8;
	    }
	  }
	}

	if (56<=$WW[0] && $WW[0]<=57) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}

	#Setter n� inn t�kedis hvis det ikke er fra f�r og det er ledig plass, krever at alle symboler har kommet inn----------
	 # if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	    #my $innsatt=0;
	  #  if ($V3flag !=10) { #Alts� hvis ikke korrigert.
	   #   $V3flag=10;
	    #  $V3corr=19;
	     # $innsatt=1;
	    #}
	    #if ($V1_missing[0]==0 && $V2flag !=10 && $innsatt==0) { #Alts� hvis ikke korrigert.
	     # $V1flag=10;
	      #$V1corr=19;
	    #}
	  #}
	
      


	
	if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14) {     #isslag
	  if (68<=$WW[0] && $WW[0]<=99) {
	    $WWflag=3;
	    if ($V1_missing[0]==0){
	      $V1flag=3;
	    }
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}

	if ($V1[0]==29 || $V2[0]==29 || $V3[0]==29) {     #kornmo
	  
	  if (95<=$WW[0] && $WW[0]<=99) {
	    if ($V1[0]==29) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V2[0]==29) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V3[0]==29) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter kornmo-------
	    }
	  }
	}


	if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) { #T�kedis
	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }

	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }

	  if (60<=$WW[0] && $WW[0]<=65) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }
	  
	  if (66<=$WW[0] && $WW[0]<=67) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (68<=$WW[0] && $WW[0]<=69) {
	    #Ev. sett inn sludd-----
	    if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=1;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=1;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=1;
	      }
	    }
	  }

	  if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	    #Ev. sett inn sn�-----
	    if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=2;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
		$V2flag=10;
		$V2corr=2;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=2;
	      }
	    }
	  }
	  
	  if ($WW[0]==76) {
	    #Ev. sett inn isn�ler-----
	    if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=16;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=16;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=16;
	      }
	    }
	  }
	
	  if ($WW[0]==77) {
	    #Ev. sett inn kornsn�-----
	    if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=6;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=6;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=6;
	      }
	    }
	  }

	  if ($WW[0]==79) {
	    #Ev. sett inn iskorn-----
	    if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=15;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=15;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=15;
	      }
	    }
	  }

	  if (80<=$WW[0] && $WW[0]<=82) {
	    #Ev. sett inn regnbyger-----
	    if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=7;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=7;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=7;
	      }
	    }
	  }

	  if (83<=$WW[0] && $WW[0]<=84) {
	    #Ev. sett inn sluddbyger-----
	    if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=4;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=4;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=4;
	      }
	    }
	  }

	  if (85<=$WW[0] && $WW[0]<=86) {
	    #Ev. sett inn sn�byger-----
	    if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=5;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=5;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=5;
	      }
	    }
	  }
	  
	  if ($WW[0]==87) {
	    #Ev. sett inn spr�hagl-----
	    if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=9;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=9;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=9;
	      }
	    }
	  }

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }
	  
	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=11;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
		$V2flag=10;
		$V2corr=11;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=11;
	      }
	    }
	  }

	  if (91<=$WW[0] && $WW[0]<=92) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	    #Setter evn inn torden i v�ret siden forrige hovedobs.
	    if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0) {
		$V7flag=10;
		$V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		$V6flag=10;
		$V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
		$V5flag=10;
		$V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
		$V4flag=10;
		$V4corr=20;
	      }
	    }
	  }
	} #end if V1, V2 eller V3 er t�kedis----------
	
	if ($V1[0]==21 || $V1[0]==21 || $V1[0]==21) { #�lr�yk
	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }
	  
	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }

	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }
	  
	  if (60<=$WW[0] && $WW[0]<=65) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }

	  if (66<=$WW[0] && $WW[0]<=67) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (68<=$WW[0] && $WW[0]<=69) {
	    #Ev. sett inn sludd-----
	    if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=1;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=1;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=1;
	      }
	    }
	  }
	  
	  if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	    #Ev. sett inn sn�-----
	    if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=2;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=2;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=2;
	      }
	    }
	  }
	
	  if ($WW[0]==76) {
	    #Ev. sett inn isn�ler-----
	    if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=16;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=16;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=16;
	      }
	    }
	  }
	
	  if ($WW[0]==77) {
	    #Ev. sett inn kornsn�-----
	    if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=6;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=6;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=6;
	      }
	    }
	  }

	  if ($WW[0]==79) {
	    #Ev. sett inn iskorn-----
	    if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=15;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=15;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=15;
	      }
	    }
	  }

	  if (80<=$WW[0] && $WW[0]<=82) {
	    #Ev. sett inn regnbyger-----
	    if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=7;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=7;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=7;
	      }
	    }
	  }

	  if (83<=$WW[0] && $WW[0]<=84) {
	    #Ev. sett inn sluddbyger-----
	    if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=4;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=4;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=4;
	      }
	    }
	  }

	  if (85<=$WW[0] && $WW[0]<=86) {
	    #Ev. sett inn sn�byger-----
	    if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=5;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=5;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=5;
	      }
	    }
	  }

	  if ($WW[0]==87) {
	    #Ev. sett inn spr�hagl-----
	    if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=9;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=9;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=9;
	      }
	    }
	  }

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }

	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=11;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=11;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=11;
	      }
	    }
	  }

	  if (91<=$WW[0] && $WW[0]<=92) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	    #Setter evn inn torden i v�ret siden forrige hovedobs.
	    if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0) {
		$V7flag=10;
		$V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		$V6flag=10;
		$V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
		$V5flag=10;
		$V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
		$V4flag=10;
		$V4corr=20;
	      }
	    }
	  }



	  #Sletter n� �lr�yk hvis det skulle v�re igjen-----
	  if ($V3[0]==21 && $V3flag !=10) { #Verdien er ikke allerede korrigert
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter �lr�yk
	  }
	  
	  if ($V2[0]==21 && $V2flag !=10) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter �lr�yk
	  }
	  
	  if ($V1[0]==21 && $V1flag !=10) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter �lr�yk
	  }



	} #end if �lr�yk----------



	#Sjekker om det er noen "Ren luft"-symboler igjen, sletter de is�fall.
	if ($V3[0]==22 && $V3flag !=10) { #Verdien er ikke allerede korrigert
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	
	if ($V2[0]==22 && $V2flag !=10) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22 && $V1flag !=10) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}
	


      } #end 50<=ww<=99-----
    } #end 1000<=VV<=10000
  
    if ($VV_missing[0]==0 && $VV[0]<1000) {
      if (0<=$WW[0] && $WW[0]<=41) {
	$VVflag=3;
	$WWflag=3;
	if ($V1_missing[0]==0) {
	  $V1flag=13;
	  $V1_missing[0]=2;
	}
	if ($V2_missing[0]==0) {
	  $V2flag=13;
	  $V2_missing[0]=2;
	}
	if ($V3_missing[0]==0) {
	  $V3flag=13;
	  $V3_missing[0]=2;
	}
	#Sjekker om det er noen "Ren luft"-symboler igjen, sletter de is�fall.
	if ($V3[0]==22) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	
	if ($V2[0]==22) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}
      } #end 0<=ww<=41---

      if (42<=$WW[0] && $WW[0]<=49) {

=comment

	if ($V1[0] !=18 && $V2[0] !=18 && $V3[0] !=18) { #Setter evn inn t�ke------
	  if ($V3_missing[0]==0) {
	    $V3flag=10;
	    $V3corr=18;
	  }
	  if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	    $V2flag=10;
	    $V2corr=18;
	  }
	  if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	    $V1flag=10;
	    $V1corr=18;
	  }
	}

=cut

	#Sjekker om det er noen "Ren luft"-symboler igjen, sletter de is�fall.
        #Og erstatter de med t�ke
	if ($V3[0]==22) {
	    if ($V1[0] !=18 && $V2[0] !=18) {
		$V3flag=10;
		$V3corr=18; #setter inn t�ke
	    }
	    else {
		$V3flag=13;
		$V3_missing[0]=2; #Sletter ren luft
	    }
	}
	    
	if ($V2[0]==22) {
	    if ($V1[0] !=18 && $V3[0] !=18) {
		$V2flag=10;
		$V2corr=18; #setter inn t�ke
	    }
	    else {
		$V2flag=13;
		$V2_missing[0]=2; #Sletter ren luft
	    }
	}
	if ($V1[0]==22) {
	    if ($V2[0] !=18 && $V3[0] !=18) {
		$V1flag=10;
		$V1corr=18; #setter inn t�ke
	    }
	    else {
		$V1flag=13;
		$V1_missing[0]=2; #Sletter ren luft
	    }
	}
      }     


      if (50<=$WW[0] && $WW[0]<=99) {
	#G�r her innp� kombinasjon 7 d, VV>=1000-------------

   

	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=8;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=8;
	    }
	  }
	}

	if (56<=$WW[0] && $WW[0]<=57) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (58<=$WW[0] && $WW[0]<=59) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (60<=$WW[0] && $WW[0]<=65) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
	}

	if (66<=$WW[0] && $WW[0]<=67) {
	  #Ev. sett inn isslag-----
	  if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=14;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=14;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=14;
	    }
	  }
	}

	if (68<=$WW[0] && $WW[0]<=69) {
	  #Ev. sett inn sludd-----
	  if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=1;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=1;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=1;
	    }
	  }
	}

	if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	  #Ev. sett inn sn�-----
	  if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=2;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=2;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=2;
	    }
	  }
	}
	
	if ($WW[0]==76) {
	  #Ev. sett inn isn�ler-----
	  if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=16;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=16;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=16;
	    }
	  }
	}
	
	if ($WW[0]==77) {
	  #Ev. sett inn kornsn�-----
	  if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=6;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=6;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=6;
	    }
	  }
	}

	if ($WW[0]==79) {
	  #Ev. sett inn iskorn-----
	  if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=15;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=15;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=15;
	    }
	  }
	}

	if (80<=$WW[0] && $WW[0]<=82) {
	  #Ev. sett inn regnbyger-----
	  if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=7;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=7;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=7;
	    }
	  }
	}

	if (83<=$WW[0] && $WW[0]<=84) {
	  #Ev. sett inn sluddbyger-----
	  if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=4;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=4;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=4;
	    }
	  }
	}

	if (85<=$WW[0] && $WW[0]<=86) {
	  #Ev. sett inn sn�byger-----
	  if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=5;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=5;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=5;
	    }
	  }
	}

	if ($WW[0]==87) {
	  #Ev. sett inn spr�hagl-----
	  if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=9;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=9;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=9;
	    }
	  }
	}

	if ($WW[0]==88) {
	  #Ev. sett inn hagl-----
	  if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=10;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=10;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=10;
	    }
	  }
	}

	if (89<=$WW[0] && $WW[0]<=90) {
	  #Ev. sett inn ishagl-----
	  if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=11;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=11;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=11;
	    }
	  }
	}

	if (91<=$WW[0] && $WW[0]<=92) {
	  #Ev. sett inn regn-----
	  if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	    if ($V3_missing[0]==0) {
	      $V3flag=10;
	      $V3corr=3;
	    }
	    if ($V2_missing[0]==0 && $V3_missing[0]>0) {
	      $V2flag=10;
	      $V2corr=3;
	    }
	    if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
	      $V1flag=10;
	      $V1corr=3;
	    }
	  }
#Setter evn inn torden i v�ret siden forrige hovedobs.
	  if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	    if ($V7_missing[0]==0) {
	      $V7flag=10;
	      $V7corr=20;
	    }
	    if ($V6_missing[0]==0 && $V7_missing[0]>0) {
	      $V6flag=10;
	      $V6corr=20;
	    }
	    if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
	      $V5flag=10;
	      $V5corr=20;
	    }
	    if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
	      $V4flag=10;
	      $V4corr=20;
	    }
	  }
	}

	#Setter n� inn t�kedis hvis det ikke er fra f�r og det er ledig plass, krever at alle symboler har kommet inn----------
	  #if ($V1[0] !=19 && $V2[0] !=19 && $V3[0] !=19 && $V1_missing[0]==0 && $V2_missing[0]==0 && $V3_missing[0]==0) {
	    #my $innsatt=0;
	   # if ($V3flag !=10) { #Alts� hvis ikke korrigert.
	    #  $V3flag=10;
	     # $V3corr=19;
	     # $innsatt=1;
	    #}
	    #if ($V1_missing[0]==0 && $V2flag !=10 && $innsatt==0) { #Alts� hvis ikke korrigert.
	     # $V1flag=10;
	      #$V1corr=19;
	    #}
	  #}
	
   


	if ($V1[0]==14 || $V2[0]==14 || $V3[0]==14) {     #isslag
	  if (68<=$WW[0] && $WW[0]<=99) {
	    $WWflag=3;
	    if ($V1_missing[0]==0){
	      $V1flag=3;
	    }
	    if ($V2_missing[0]==0) {
	      $V2flag=3;
	    }
	    if ($V3_missing[0]==0) {
	      $V3flag=3;
	    }
	  }
	}

	if ($V1[0]==29 || $V2[0]==29 || $V3[0]==29) {     #kornmo
	  
	  if (95<=$WW[0] && $WW[0]<=99) {
	    if ($V1[0]==29) {
	      $V1flag=13;
	      $V1_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V2[0]==29) {
	      $V2flag=13;
	      $V2_missing[0]=2; #Sletter kornmo-------
	    }
	    if ($V3[0]==29) {
	      $V3flag=13;
	      $V3_missing[0]=2; #Sletter kornmo-------
	    }
	  }
	}


	if ($V1[0]==19 || $V2[0]==19 || $V3[0]==19) { #T�kedis
	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }

	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }

	  if (60<=$WW[0] && $WW[0]<=65) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }
	  
	  if (66<=$WW[0] && $WW[0]<=67) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (68<=$WW[0] && $WW[0]<=69) {
	    #Ev. sett inn sludd-----
	    if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=1;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=1;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=1;
	      }
	    }
	  }

	  if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	    #Ev. sett inn sn�-----
	    if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=2;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
		$V2flag=10;
		$V2corr=2;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=2;
	      }
	    }
	  }
	  
	  if ($WW[0]==76) {
	    #Ev. sett inn isn�ler-----
	    if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=16;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=16;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=16;
	      }
	    }
	  }
	
	  if ($WW[0]==77) {
	    #Ev. sett inn kornsn�-----
	    if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=6;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=6;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=6;
	      }
	    }
	  }

	  if ($WW[0]==79) {
	    #Ev. sett inn iskorn-----
	    if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=15;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=15;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=15;
	      }
	    }
	  }

	  if (80<=$WW[0] && $WW[0]<=82) {
	    #Ev. sett inn regnbyger-----
	    if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=7;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=7;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=7;
	      }
	    }
	  }

	  if (83<=$WW[0] && $WW[0]<=84) {
	    #Ev. sett inn sluddbyger-----
	    if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=4;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=4;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=4;
	      }
	    }
	  }

	  if (85<=$WW[0] && $WW[0]<=86) {
	    #Ev. sett inn sn�byger-----
	    if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=5;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=5;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=5;
	      }
	    }
	  }
	  
	  if ($WW[0]==87) {
	    #Ev. sett inn spr�hagl-----
	    if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=9;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=9;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=9;
	      }
	    }
	  }

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }
	  
	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=11;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19 ) {
		$V2flag=10;
		$V2corr=11;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=11;
	      }
	    }
	  }

	  if (91<=$WW[0] && $WW[0]<=92) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0 && $V3[0] !=19) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0 && $V2[0] !=19) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0 && $V1[0] !=19) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	    #Setter evn inn torden i v�ret siden forrige hovedobs.
	    if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0) {
		$V7flag=10;
		$V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		$V6flag=10;
		$V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
		$V5flag=10;
		$V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
		$V4flag=10;
		$V4corr=20;
	      }
	    }
	  }
	} #end if V1, V2 eller V3 er t�kedis----------
	
	if ($V1[0]==21 || $V1[0]==21 || $V1[0]==21) { #�lr�yk
	  if (50<=$WW[0] && $WW[0]<=55) {
	    #Ev. sett inn yr-----
	    if ($V1[0] !=8 && $V2[0] !=8 && $V3[0] !=8) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=8;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=8;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=8;
	      }
	    }
	  }
	  
	  if (56<=$WW[0] && $WW[0]<=57) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }

	  if (58<=$WW[0] && $WW[0]<=59) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }
	  
	  if (60<=$WW[0] && $WW[0]<=65) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	  }

	  if (66<=$WW[0] && $WW[0]<=67) {
	    #Ev. sett inn isslag-----
	    if ($V1[0] !=14 && $V2[0] !=14 && $V3[0] !=14) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=14;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=14;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=14;
	      }
	    }
	  }
	  
	  if (68<=$WW[0] && $WW[0]<=69) {
	    #Ev. sett inn sludd-----
	    if ($V1[0] !=1 && $V2[0] !=1 && $V3[0] !=1) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=1;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=1;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=1;
	      }
	    }
	  }
	  
	  if ((70<=$WW[0] && $WW[0]<=75) || $WW[0]==78) {
	    #Ev. sett inn sn�-----
	    if ($V1[0] !=2 && $V2[0] !=2 && $V3[0] !=2) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=2;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=2;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=2;
	      }
	    }
	  }
	
	  if ($WW[0]==76) {
	    #Ev. sett inn isn�ler-----
	    if ($V1[0] !=16 && $V2[0] !=16 && $V3[0] !=16) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=16;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=16;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=16;
	      }
	    }
	  }
	
	  if ($WW[0]==77) {
	    #Ev. sett inn kornsn�-----
	    if ($V1[0] !=6 && $V2[0] !=6 && $V3[0] !=6) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=6;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=6;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=6;
	      }
	    }
	  }

	  if ($WW[0]==79) {
	    #Ev. sett inn iskorn-----
	    if ($V1[0] !=15 && $V2[0] !=15 && $V3[0] !=15) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=15;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=15;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=15;
	      }
	    }
	  }

	  if (80<=$WW[0] && $WW[0]<=82) {
	    #Ev. sett inn regnbyger-----
	    if ($V1[0] !=7 && $V2[0] !=7 && $V3[0] !=7) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=7;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=7;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=7;
	      }
	    }
	  }

	  if (83<=$WW[0] && $WW[0]<=84) {
	    #Ev. sett inn sluddbyger-----
	    if ($V1[0] !=4 && $V2[0] !=4 && $V3[0] !=4) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=4;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=4;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=4;
	      }
	    }
	  }

	  if (85<=$WW[0] && $WW[0]<=86) {
	    #Ev. sett inn sn�byger-----
	    if ($V1[0] !=5 && $V2[0] !=5 && $V3[0] !=5) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=5;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=5;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=5;
	      }
	    }
	  }

	  if ($WW[0]==87) {
	    #Ev. sett inn spr�hagl-----
	    if ($V1[0] !=9 && $V2[0] !=9 && $V3[0] !=9) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=9;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=9;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=9;
	      }
	    }
	  }

	  if ($WW[0]==88) {
	    #Ev. sett inn hagl-----
	    if ($V1[0] !=10 && $V2[0] !=10 && $V3[0] !=10) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=10;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=10;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=10;
	      }
	    }
	  }

	  if (89<=$WW[0] && $WW[0]<=90) {
	    #Ev. sett inn ishagl-----
	    if ($V1[0] !=11 && $V2[0] !=11 && $V3[0] !=11) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=11;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=11;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=11;
	      }
	    }
	  }

	  if (91<=$WW[0] && $WW[0]<=92) {
	    #Ev. sett inn regn-----
	    if ($V1[0] !=3 && $V2[0] !=3 && $V3[0] !=3) {
	      if ($V3_missing[0]==0) {
		$V3flag=10;
		$V3corr=3;
	      }
	      if ($V2_missing[0]==0 && $V3_missing[0]>0) {
		$V2flag=10;
		$V2corr=3;
	      }
	      if ($V1_missing[0]==0 && $V3_missing[0]>0 && $V2_missing[0]>0) {
		$V1flag=10;
		$V1corr=3;
	      }
	    }
	    #Setter evn inn torden i v�ret siden forrige hovedobs.
	    if ($V7[0] !=20 && $V6[0] !=20 && $V5[0] !=20 && $V4[0] !=20) {
	      if ($V7_missing[0]==0) {
		$V7flag=10;
		$V7corr=20;
	      }
	      if ($V6_missing[0]==0 && $V7_missing[0]>0) {
		$V6flag=10;
		$V6corr=20;
	      }
	      if ($V5_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0) {
		$V5flag=10;
		$V5corr=20;
	      }
	      if ($V4_missing[0]==0 && $V7_missing[0]>0 && $V6_missing[0]>0 && $V5_missing[0]>0) {
		$V4flag=10;
		$V4corr=20;
	      }
	    }
	  }
	  #Sletter n� �lr�yk hvis det skulle v�re igjen-----
	  if ($V3[0]==21 && $V3flag !=10) {
	    $V3flag=13;
	    $V3_missing[0]=2; #Sletter �lr�yk
	  }
	  
	  if ($V2[0]==21 && $V2flag !=10) {
	    $V2flag=13;
	    $V2_missing[0]=2; #Sletter �lr�yk
	  }
	  
	  if ($V1[0]==21 && $V1flag !=10) {
	    $V1flag=13;
	    $V1_missing[0]=2; #Sletter �lr�yk
	  }
	} #end if �lr�yk----------

	#Sjekker om det er noen "Ren luft"-symboler igjen, sletter de is�fall.
	if ($V3[0]==22 && $V3flag !=10) {
	  $V3flag=13;
	  $V3_missing[0]=2; #Sletter ren luft
	}
	
	if ($V2[0]==22 && $V2flag !=10) {
	  $V2flag=13;
	  $V2_missing[0]=2; #Sletter ren luft
	}
	
	if ($V1[0]==22 && $V1flag !=10) {
	  $V1flag=13;
	  $V1_missing[0]=2; #Sletter ren luft
	}


	
      } #end 50<=ww<=99-----
    } #end VV<1000


    

  } #end hele regla-------------
} #end sub komb 7 f----------



  sub flagg_korr {
    
    #########################################################
    #######################################################
    ###############  Her har vi den samlede korrigering av flagg og verdi(er),
    #####  pusher disse p� stacken. Aktuelle korrigeringer er for WW, V1, V2, V3 og##  V4
    
    my @retvector;
    if ($WW_missing[0]==0) {              #Verdien har kommet inn
	push(@retvector, "WW_0_0_flag");
	push(@retvector, $WWflag);
	if ($WWflag==10) {                #Korrigert verdi, ikke slettet
	    push(@retvector, "WW_0_0_corrected");
	    push(@retvector, $WWcorr);
	} 
    }
    if ($WW_missing[0]>0 && $WWflag==13) {   #Slettet verdi                    
	push(@retvector, "WW_0_0_missing");
	push(@retvector, $WW_missing[0]);
	push(@retvector, "WW_0_0_flag");
	push(@retvector, $WWflag);
    }
    
    ###
    if ($V1_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V1_0_0_flag");
	push(@retvector, $V1flag);
	if ($V1flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V1_0_0_corrected");
	    push(@retvector, $V1corr);
	} 
    }
    if ($V1_missing[0]>0 && $V1flag==13)  {     #Slettet verdi                   
	push(@retvector, "V1_0_0_missing");
	push(@retvector, $V1_missing[0]);
	push(@retvector, "V1_0_0_flag");
	push(@retvector, $V1flag);
    }
    
    ###
    if ($V2_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V2_0_0_flag");
	push(@retvector, $V2flag);
	if ($V2flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V2_0_0_corrected");
	    push(@retvector, $V2corr);
	} 
    }
    if ($V2_missing[0]>0 && $V2flag==13)  {     #Slettet verdi                   
	push(@retvector, "V2_0_0_missing");
	push(@retvector, $V2_missing[0]);
	push(@retvector, "V2_0_0_flag");
	push(@retvector, $V2flag);
    }
    
    ###
    if ($V3_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V3_0_0_flag");
	push(@retvector, $V3flag);
	if ($V3flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V3_0_0_corrected");
	    push(@retvector, $V3corr);
	} 
    }
    if ($V3_missing[0]>0 && $V3flag==13)  {     #Slettet verdi                   
	push(@retvector, "V3_0_0_missing");
	push(@retvector, $V3_missing[0]);
	push(@retvector, "V3_0_0_flag");
	push(@retvector, $V3flag);
    }
    
    ###
    if ($V4_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V4_0_0_flag");
	push(@retvector, $V4flag);
	if ($V4flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V4_0_0_corrected");
	    push(@retvector, $V4corr);
	} 
    }
    if ($V4_missing[0]>0 && $V4flag==13)  {     #Slettet verdi                   
	push(@retvector, "V4_0_0_missing");
	push(@retvector, $V4_missing[0]);
	push(@retvector, "V4_0_0_flag");
	push(@retvector, $V4flag);
    }

    ###
    if ($V5_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V5_0_0_flag");
	push(@retvector, $V5flag);
	if ($V5flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V5_0_0_corrected");
	    push(@retvector, $V5corr);
	} 
    }
    if ($V5_missing[0]>0 && $V5flag==13)  {     #Slettet verdi                   
	push(@retvector, "V5_0_0_missing");
	push(@retvector, $V5_missing[0]);
	push(@retvector, "V5_0_0_flag");
	push(@retvector, $V5flag);
    }
    
    ###
    if ($V6_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V6_0_0_flag");
	push(@retvector, $V6flag);
	if ($V6flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V6_0_0_corrected");
	    push(@retvector, $V6corr);
	} 
    }
    if ($V6_missing[0]>0 && $V6flag==13)  {     #Slettet verdi                   
	push(@retvector, "V6_0_0_missing");
	push(@retvector, $V6_missing[0]);
	push(@retvector, "V6_0_0_flag");
	push(@retvector, $V6flag);
    }
    
    ###
    if ($V7_missing[0]==0) {                 #Verdien har kommet inn
	push(@retvector, "V7_0_0_flag");
	push(@retvector, $V7flag);
	if ($V7flag==10) {                   #Korrigert verdi, ikke slettet
	    push(@retvector, "V7_0_0_corrected");
	    push(@retvector, $V7corr);
	} 
    }
    if ($V7_missing[0]>0 && $V7flag==13)  {     #Slettet verdi                   
	push(@retvector, "V7_0_0_missing");
	push(@retvector, $V7_missing[0]);
	push(@retvector, "V7_0_0_flag");
	push(@retvector, $V7flag);
    }


    if ($VV_missing[0]==0) {
	push(@retvector, "VV_0_0_flag");
	push(@retvector, $VVflag);
    }
    
    my $numout = @retvector;
    
    return(@retvector,$numout); 
    
    ###################################################
    

  } #end sub flagg_korr ---------------




#Versjon 12/12-2006 med komm

#Versjon 14/3-2007, �ystein Lie, Dataseksjonen, OBS-div, met.no---------------------
#-#
#Versjon 23/8-2007 
#Versjon 14/9-2007----------------------------------------
#Versjon 17/9-2007 -----------------

} #END sub check ######



