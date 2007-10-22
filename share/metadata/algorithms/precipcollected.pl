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


# checkname : precipcollected
# signature : obs;R;;|refobs;Rstart,Robs;;
#
# Detektering av oppsamlet verdi basert på observatørens anvisning.
# Gabriel Kielland 22. desember 2004
# signaturen korrigert 27. mai 2005
# Benytter forsøksvis den rene perl-modulen Time::Local istedet for C-programmet Date::Calc 18. mai 2006
#

sub check {
use Time::Local qw(timegm);

  my $flag;
# Tolererer ikke manglende nedbørmengde  
  if ($R_missing[0]>0) {
	return;
  }

# Pakk ut klokkene
  my ($year0,$month0,$day0,$hour0) = $Rstart[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/;
  my ($year1,$month1,$day1,$hour1) = $Robs[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/;

  if ( $Rstart_missing[0] > 0 || $Robs_missing[0] > 0 ) {
    $flag = 3;
  } elsif ( not $year0 or not $year1 ) {
# Feil klokkesyntaks (ikke 10 siffre)
    $flag = 3;
  } else {

# Beregner oppsamlingsperioden i hele timer
    eval {
      my $epoch_seconds0 = timegm(0,0,$hour0,$day0,$month0-1,$year0-1900);
      my $epoch_seconds1 = timegm(0,0,$hour1,$day1,$month1-1,$year1-1900);

      my $Dh = sprintf("%.0f",($epoch_seconds1-$epoch_seconds0)/3600);

# Sett flagg
      if ( $Dh == 24 || $Dh == 23 || $Dh == 25 ) {
	$flag = 1;
      } elsif ( $Dh >= 47 && $Dh < 74 ) {
	$flag = 2;
      } else {
	$flag = 3;
      }
    }; # end eval
    $flag = 3 if $@; # eval failet, høyst trolig pga ugyldig dato
                     # (timegm vil da protestere)
  }

  my @retvector;
  push(@retvector,"R_0_0_flag");
  push(@retvector,$flag);
  my $numout  = @retvector;
  return(@retvector,$numout);
}

