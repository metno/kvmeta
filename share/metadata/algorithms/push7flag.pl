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


# checkname : push7flag
# signature : obs;X;;
#
# Setter flaggverdien 7, forkaster originalverdien og returnerer.
# Gabriel Kielland 18. august 2004
# Sist oppdatert 13. oktober 2005: Aborterer når fmis > 0

sub check {

  my @retvector;

  if ( $X_missing[0] ) {
                # aborter..
                return 0;
        }

  push(@retvector,"X_0_0_flag");
  push(@retvector,7);

  push(@retvector,"X_0_0_missing");
  push(@retvector,2);

  my $numout  = @retvector;

  return(@retvector,$numout);
}

