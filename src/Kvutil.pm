package Kvutil;
# Kvutil - Utilities for Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: Kvutil.pm 1 2010-11-15 16:38:15Z terjeer $
#
# Copyright (C) 2010 met.no
#
# Contact information:
# Norwegian Meteorological Institute
# Box 43 Blindern
# 0313 OSLO
# NORWAY
# email: kvalobs-dev@met.no
#
# This file contains utilities for algorithms in kvalobs written in perl 
# 
# Kvutil.pm is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation; either version 2 
# of the License, or (at your option) any later version.
#
# Kvutil.pm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along 
# with Kvutil.pm; if not, write to the Free Software Foundation Inc., 
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(fresult );

use strict;

sub fresult{
    my $numout = @_;
    return (@_, $numout);
}

1;
