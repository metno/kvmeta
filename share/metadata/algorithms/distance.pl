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


#checkname       : distance
#signature       : obs;rlat,rlon;;




sub check {
    use POSIX;

    my $MAXSPEED = 50;         #meter per second
    my $EARTHRADIUS = 6370000; #meter

    my $len_lat=@rlat;
    my $len_lon=@rlon;


    my $flag=1;

    if( $len_lat !=  $len_lon || $len_lat < 2 ){
	$flag=2;
    }elsif( !defined($rlon[0]) ||  !defined($rlon[1] || !defined($rlat[0] || !defined($rlat[1] ){ 
	$flag=3;
    }elsif( abs($rlat[0]) > 90 || abs($rlon[0]) > 180 || abs($rlat[1]) > 90 || abs($rlon[1]) > 180 ) {
	$flag=4;
    }else{
        # mye fint skjer her i fremtiden
   
    }
    print "flag= $flag\n";

    my @retvector = ("rlat_0_0_flag",$flag); # kun flaggverdi ut her
    push(@retvector,"rlon_0_0_flag");
    push(@retvector,$flag);
    my $numout= @retvector;           # antall returverdier
    return (@retvector, $numout);

}




