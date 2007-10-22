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


# checkname : precipcollected_flag
# signature : obs;RR;;|refobs;Rstart,Robs;;
#
# Detektering av oppsamlet verdi basert på observatørens anvisning.
# Gabriel Kielland 22. desember 2004
# signaturen korrigert 27. mai 2005
# Siste endring av Bjørn Nordin 2007 06 21.
# Benytter forsøksvis den rene perl-modulen Time::Local istedet for C-programmet Date::Calc 18. mai 2006
#
# Environmentid kan kanskje brukes til å skille ut ikke-daglige stasjoner.
# Bør kunne brukes i checks-filer eller station_param-filer?

sub check {
use Time::Local qw(timegm);

  my $flag=0;
  my $Dh;
  my $Dm2;
  my $Dh2;
  my $IN;
  my $IN2;
  my @retvector;
# Hopper ut ved manglende nedbørmengde.
  if ($RR_missing[0]>0) {
	return;
  }

# Hopper ut ved vanlig nedbørregistrering.
  if ($Rstart_missing[0] > 0 && $Robs_missing[0] > 0) {
    $flag = 1;
  push(@retvector,"RR_0_0_flag");
  push(@retvector,$flag);
  my $numout  = @retvector;
  return(@retvector,$numout);

  }

# Pakker ut klokkene.
  my ($year0,$month0,$day0,$hour0) = $Rstart[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/;
  my ($year1,$month1,$day1,$hour1) = $Robs[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/;

  if ( $Rstart_missing[0] > 0 || $Robs_missing[0] > 0 ) {
    $flag = 3;
	push(@retvector,"RR_0_0_flag");
	push(@retvector,$flag);
	my $numout  = @retvector;
	return(@retvector,$numout);
  } elsif ( not $year0 or not $year1 ) {
# Feil klokkesyntaks (ikke 10 sifre).
    $flag = 3;
	push(@retvector,"RR_0_0_flag");
	push(@retvector,$flag);
	my $numout  = @retvector;
	return(@retvector,$numout);
  } else {

# Beregner oppsamlingsperioden i hele timer.
    eval {
      my $epoch_seconds0 = timegm(0,0,$hour0,$day0,$month0-1,$year0-1900);
      my $epoch_seconds1 = timegm(0,0,$hour1,$day1,$month1-1,$year1-1900);

      $Dh = sprintf("%.0f",($epoch_seconds1-$epoch_seconds0)/3600);

# Setter flagg.
      if ( $Dh <= 19 ) {
	# Mindre enn 1 Døgn med Feil angitt Fra - Til Tidspunkt.
	$flag = 3;
      } elsif ( $Dh >= 20 && $Dh <= 35 ) {
      # 1 Døgn med Ukurant Obstid, Ukurant Sending, Korreksjon.
	$flag = 1;
      } elsif ( $Dh >= 36 && $Dh < 768 ) {
	$flag = 2; # 2-32 døgn med Oppsamling.
      }
    }; # end eval
    $flag = 3 if $@; # eval failet, høyst trolig pga ugyldig dato
                     # (timegm vil da protestere)

# Ved flagverdi = 1 eller 3 :  Pusher retvector og returnerer.
      if ( $flag == 1 || $flag == 3 ) {
	push(@retvector,"RR_0_0_flag");
	push(@retvector,$flag);
	my $numout  = @retvector;
	return(@retvector,$numout);
      }

# Tildeler $NT antall RR-verdier som er funnet.
  my $NT = @RR;

# Starter med den første forrige ($i=1).
	for (my $i=1; $i < $NT; $i++) {
	
	if ($RR_missing[$i]>0) {
# $IN er antall tilfeller med mangel-verdier/-flagg for RR.
		$IN = $i;
	}
	last  if ($RR_missing[$i] == 0);
  }

# $Dh  = Antall timer med oppsamling i følge Observatør.
# $IN2 = Antall dager med oppsamling i følge Observatør.
# $Dh2 = Antall timer med oppsamling i følge Databasen.
   $IN2 = int($Dh/24);
   $Dm2 = abs $obs_timeoffset[$IN+1];
   $Dh2 = $Dm2/60;
# $ARMDobs  = Oppsamlingsperiodens Slutt i følge Observatør.
# $Xobstime = Oppsamlingsperiodens Slutt i følge Databasen.
   my $ARMDobs = int($Robs[0]/100);
   my $Xobstime = ($obstime[0]*10000)+($obstime[1]*100)+($obstime[2]);

# Sjekker antall timer og obstidspunkter.

   if($Dh >= ($Dh2-4) && $Dh <= ($Dh2+4) && $ARMDobs == $Xobstime) {

	for (my $i=0; $i <= $IN; $i++) {
	
# Setter flagg for hele oppsamlingsperioden.

	my $RR_tidIndex = "RR_$i" . "_0_flag";
	$flag = 2; # 2-32 døgn med Oppsamling.
	push(@retvector, $RR_tidIndex);
	push(@retvector,$flag);

	}
		
   } else {

#-----------------------------------------------------------------------
# Inkonsistens: Oppsamlingsperiode Observatør vs. DB.
# Setter 3-flagg for hele mulige Oppsamlingsperiode.
# Begrenset av sammenhengende periode med mangler bakover.

	for (my $i=0; $i <= $IN; $i++) {
	
	my $RR_tidIndex = "RR_$i" . "_0_flag";
	$flag = 3; # 2-32 døgn med unormal observasjon.
	push(@retvector, $RR_tidIndex);
	push(@retvector,$flag);

	}

   }

  my $numout  = @retvector;
  return(@retvector,$numout);

}

}
