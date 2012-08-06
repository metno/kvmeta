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


# QC1-3 er testen dette gjelder for
# formatet på filen QC1-3 er følgende:
# paramid MAX eller paramid NO

# brukes på følgende måte :
# dbQC1-3 $arg $fromfile name_column1 name_column2 ...  name_columnN
# første kolonnen i inputfilen er paramid; de andre er navnene på kolonnene 
# filen gjelder for alle stasjoner og tider
# legg merke til at QCX tas fra kommandolinjen

use POSIX;
use strict;
use DBI;
use intodb;
use dbQC;

my $QCX = $ARGV[1];
my $fromtime= get_fromtime();
my %m_param;

my $arg       = $ARGV[0];
my $outfilename= $QCX.".out";

my $narg = @ARGV;
my @name_list = @ARGV;
my $t = shift( @name_list );
$t = shift( @name_list );
my $len_name_list = @name_list;
print "len_name_list = $len_name_list \n";



if( $arg eq "gen" || $arg eq "all" ){
 
my $splitter="\\s+";
my $fromfile=station_param_name($ARGV[1]);

open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

my $outfile= '>'.$outfilename;
open(MYFILEOUT,$outfile) or die "Can't open  $outfile: $!\n";
#print "$outfilename \n";
select(MYFILEOUT);


%m_param = fill_param();

my %stored_param;
my $line;

while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*)\s*$/$1/;#Her utf?res en trim
      #last unless $line;

	if( length($line)>0 ){
	    my @sline=split /$splitter/,$line;
            my $len=@sline;
	    
	    my $stationid = 0;
            my $paramid = trim($sline[0]);
            my $level = 0;
	    my $sensor =  '0';
	    my $fromday = 0;
	    my $today = 365;
            my $hour=-1;

	    if( exists $m_param{"$paramid"}  && !exists $stored_param{"$paramid"} ) {
               $stored_param{"$paramid"}=1;
               my $nrList;
	       if( $len_name_list >= $len -1 ){
		   $nrList= $len -1;
	       }else{
		   $nrList= $len_name_list;
	       }

	       if( $nrList != 0 ){
                   my $namestr="";
                   my $valuestr="";
		   for( my $k=0; $k<$nrList-1; $k++ ){
		        $namestr .= $name_list[$k].";";
			#print "k=$k -- $name_list[$k] \n";
			$valuestr .= trim($sline[$k+1]).";";
		    } 
		        $namestr .= $name_list[$nrList-1];
		        $valuestr .= trim($sline[$nrList]);
		       
		       #my $max=trim($sline[1]);
		       #my $no=trim($sline[2]);
		       #my $metadata = "max;no\\n$max;$no";

		       my $metadata = "$namestr\\n$valuestr";

		       my $desc_metadata = "\\N";
		       print "$stationid|$paramid|$level|$sensor|$fromday|$today|$hour|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";
	      }else{
		   print "ERROR";
	       }
	   }
	}
}

}

if( $arg eq "ins" || $arg eq "all" ){
    select(STDOUT);
    fintodb( ".", "station_param", $outfilename, $QCX, '|' );
}

















