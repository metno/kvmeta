#!/usr/bin/perl -w
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




#qcx            : QC1-2-101

use POSIX;
use strict;
use DBI;
use dbQC;


my $fromtime0file="fromtime_stationid_0";
open(MYFILE, $fromtime0file) or die "Can't open $fromtime0file: $!\n";
my $fromtime = <MYFILE>;
chomp($fromtime);
close(MYFILE);


my $kvpasswd=get_passwd();
my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
        die "Connect failed: $DBI::errstr";

my $sth = $dbh->prepare("UPDATE station_param \
                                  SET   fromtime = '$fromtime' \
                                  WHERE stationid=0");
                    $sth->execute;
                    $sth->finish;
                    $dbh->disconnect;
                  


