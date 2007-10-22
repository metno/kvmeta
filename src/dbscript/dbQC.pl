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



use POSIX;
use strict;
use intodb;
use logdbQC;
use dbQC;



#######################################################
## Read controlfile
my $fromfile=$ARGV[0];
my $crlfile= $ARGV[1];
my $control=" ";
$control = $ARGV[2];
print "fromfile="; print $fromfile; print "\n";
print "crlfile="; print $crlfile; print "\n";

open(MYFILE,$crlfile) or die "Can't open $crlfile: $!\n";

my $counter=0;
my $QCX;
my $time;
my $splitter;

my $split="=";
my $line;
# here we read in the three first lines from the file $crlfile
while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*?)\s*$/$1/;#Her utf?res en trim
      #last unless $line;

	if( length($line)>0 ){
	    my @sline=split /$split/,$line;
            my $len=@sline;
	    my $first = trim($sline[0]);
            #print "first= "; print $first; print "\n";
            if( $first eq "medium_qcx" ) { $QCX=trim($sline[1]);}
	    elsif( $first eq "time" ){ $time=trim($sline[1]);}
            elsif( $first eq "splitter" ){ $splitter=trim($sline[1]);}
	    else {print "ctrlERROR\n"};
	    $counter++;
	}
    if( $counter>2 ){last;}
}
print "time= "; print $time; print "\n";
print "QCX= "; print $QCX; print "\n";
print "splitter= ";  print $splitter; print "\n";            

my @table_format = qw( stationid paramid level sensor fromday today qcx metadata desc_metadata fromtime );
my %table_format; foreach (@table_format){$table_format{$_}=-1;}
my $len_table = @table_format;
my $column_not_code = "metadata";
my $extracode = "month";
#above is the table format presented

my @metadata_format;
my $table_prefix = "\$";     
my %index_input;
my %index_metadata;
my @list_input;
my @list_metadata;

$split="\\s+";
print "split= "; print $split; print "\n";
while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*?)\s*$/$1/;#Her utf?res en trim

	if( length($line)>0 ){
            my @sline=split /$split/,$line;
            my $len=@sline;
            #print "len="; print $len; print "\n";
	    
	    for( my $i=0; $i<$len; $i++ ){
		my $col = trim($sline[$i]);
		if(index($col,$table_prefix)==0 ){# this belongs to the columns 
		    $col=substr($col,1,100);
                    $index_input{$col}=$i;
                    push(@list_input,$col);
                }
                else{ #this belongs to the metadata
		    $index_metadata{$col}=$i;
                    push(@list_metadata,$col);
                }
	    }
            last;#we only read one blank line
         }
}
             
close(MYFILE);

print "list_input= "; foreach (@list_input){ print $_; print " "; } print"\n";
print "list_metadata= "; foreach (@list_metadata){ print $_; print " "; } print"\n";

# end of fileformat
#######
#control description of fileformat

#compare @list_metadata with the  @table_format and  $extracode
#controls that some of the words used as metadata are not used up as columnnames 
if( exists $index_metadata{$extracode}) {print"ERROR METADATA SYMBOL EQUAL extracode";}

my $b;
foreach (@table_format){
  if( exists $index_metadata{$_}){print"ERROR METADATA SYMBOL EQUAL table format";}}

# control that all those with $ sign are either $extracode or @table_format 

foreach (@list_input){
  if( !( (exists $table_format{$_}) or ($_ eq $extracode) ) ){
      print"ERROR $_ does not EXIST in table_format";
  }
}

END READ CONTROLFILE
#########################################################

my $fromtime=get_fromtime();

my $arg       = $ARGV[0];
my $outfilename= $QCX.".out";

my %m_station;
my %m_param;
my %m_obs_pgm;

my %m_levsen;
my %m_metafile;

my $hour=-1;
my $default_level = 0;
my $default_sensor = '0';


if( $arg eq "gen" || $arg eq "all" ){   
my $obj= new logdbQC;
my %m_station_param;



my %m_station;
my %m_param;

######
# start reading file

my %val;
$val{"stationid"} = 0;
$val{"level"} = 0;
$val{"sensor"} =  '0';
$val{"fromday"} = 1;
$val{"today"} = 365;
$val{"hour"} = -1;
$val{"desc_metadata"} = "\\N";

my %meta;
my $string_metadata="";
foreach ( @list_metadata ){
       $string_metadata .= $_ . ";";
} chop $string_metadata;

my %hfromday = fhfromday();
my %htoday   = fhtoday();



while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*?)\s*$/$1/;#Her utføres en trim
      #last unless $line;

        if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;

            # control stationid or paramid
            if( (exists $m_station{trim($sline[$index_input{"stationid"}])})
                and (exists $m_param{trim($sline[$index_input{"paramid"}])}) ){
              
               foreach (@list_input){
                     $val{$_} = trim($sline[$index_input{$_}]);             
               }

              
               if( $time eq "month" ){
                        $val{"fromday"} = $hfromday{$val{"month"}};
                        $val{"today"}  = $htoday{$val{"month"}};
               }
               
               
               my $meta;
               foreach ( @list_metadata ){#my $step=trim($sline[2]);    
                    $meta .= trim($sline[$index_metadata{$_}]) . ";";
               } chop $meta;          
               my $metadata = $string_metadata . "\\n" . $meta; 

               $val{"metadata"} = $metadata;

               my $toprint;
               foreach (@table_format){
                    $toprint .= $val{$_} . "|";
               }chop $toprint; $toprint .= "\n";
               print $toprint;

	   }
        }
}

}



























