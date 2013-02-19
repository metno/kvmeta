#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: intodb_stinfosys2kvalobs.pl 27 2007-10-22 16:21:15Z paule $
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

use strict;
use DBI;
use stinfosys;
use trim;
use Date::Calc qw( check_date check_time Delta_Days Today );
use dbQC;

my $fromtime= get_fromtime();
my %hfromday=fhfromday();
my %htoday=fhtoday();

my $outfile=">station_param_QC1-1.out";
open(OUT,$outfile) or die "Can't open $outfile: $!\n";
    
# open(LOG,">RANGE_CHECK2kvalobs.log");
my $null='\N';

  my $stname=  st_name();
  my $sthost=  st_host();
  my $stport=  st_port();
  my $stuser=  st_user();
  my $stpasswd=st_passwd();

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";

my %param; 
my $sth = $dbh->prepare('select paramid, name from param');
$sth->execute;
my @row;
while (@row = $sth->fetchrow_array) {
    $param{"$row[1]"}=$row[0];
}
$sth->finish;

###########################
my $narg=@ARGV;
my %metafile;
my %param_group;

my $fromfile_param;
if ( $narg > 1 ){
   my $fromfile=$ARGV[0];
   $fromfile_param=station_param_name($ARGV[1]);
   
   if ( $narg > 2 ){  
       my $fromfile_param_group=$ARGV[2];
       open(PGROUP,$fromfile_param_group) or die "Can't open $fromfile_param_group: $!\n";
       my $splitter_param=",";
       while( defined(my $line=<PGROUP>) ){
          $line=trim($line);
          if( length($line)>0 ){
             my @sline=split /$splitter_param/,$line;
             my $paramid = trim($sline[0]);
             my $group = trim($sline[1]);
             # print "par   $group :: $paramid \n";
             $param_group{$group}{$paramid}=1;      
          }
       }
       close( PGROUP );
       #foreach my $group ( keys %param_group ){
       #    foreach my $paramid ( keys %{$param_group{$group}} ){
       #        print "param   $group :: $paramid \n";
       #    }
       #}
   }


   my $line;
   open(MYFILEP,$fromfile_param) or die "Can't open $fromfile_param: $!\n";
   
   my $splitter_param=";";
   while( defined($line=<MYFILEP>) ){
      $line=trim($line);
      if( length($line)>0 ){
         my @sline=split /$splitter_param/,$line;

         my $paramid = trim($sline[0]);
         my $level = trim($sline[1]);
         my $min    = trim($sline[2]);
         my $max    = trim($sline[3]);
         $metafile{"$paramid,$level"}=[$min,$max];       
      }
   }
   close( MYFILEP );

    my $splitter='\|';
    print "fromfile=$fromfile \n";
    open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";
    while( defined($line=<MYFILE>) ){
        $line=trim($line);
        if( $line =~ /selected/ ){ next; }
        if( $line =~ /SQL/ ){ next; }

        if( length($line) > 0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
	    #print "$sline[0] =  $len \n";
	    if( $len > 1 ){
		my $stationid = trim($sline[0]);
                my $paramid   = trim($sline[1]);
                my $level     = trim($sline[2]);
                my $MONTH     = trim($sline[3]);
		my $highest   = trim($sline[4]);
		my $high      = trim($sline[5]);
                my $low       = trim($sline[6]);
                my $lowest    = trim($sline[7]);
		my $calc_highest = trim($sline[8]);
		my $calc_high = trim($sline[9]);
		my $calc_low = trim($sline[10]);
		my $calc_lowest = trim($sline[11]);        

                print_station_param($stationid,$MONTH,$paramid,$level,
                                    $highest,$high,$low,$lowest );
                                    # $calc_highest,$calc_high,$calc_low,$calc_lowest);
	    }
        }
    }
    close( MYFILE );
}


sub print_station_param{
   my ( $stationid,$MONTH,$paramid,$level,$highest,$high,$low,$lowest ) = @_;

   my $sensor = '0';
   my $QCX = "QC1-1";
 
   my $metafile_refarr;
   if( ! defined $level || $level eq "" ){
	$level=0;
   }

   if( exists $metafile{"$paramid,$level"} ){
       # print "OK exist \n";	
   }else{
       print "ERROR: paramid=$paramid og level=$level eksisterer ikke i filen $fromfile_param :: ERROR in $stationid,$MONTH,$paramid,$level,$highest,$high,$low,$lowest\n";
   }

   my ($min,$max) = @{$metafile{"$paramid,$level"}};

   #if( defined $highest  && defined $calc_highest && $highest ne "" && $calc_highest ne "" ){ 
   #    if ( $calc_highest > $highest ){
   #	    $highest=$calc_highest;
   #    }
   #}

   #if( defined $high  && defined $calc_high && $high ne "" && $calc_high ne "" ){ 
   #    if ( $calc_high > $high ){
   #	    $high=$calc_high;
   #    }
   #}

   #if( defined $lowest  && defined $calc_lowest && $lowest ne "" && $calc_lowest ne "" ){ 
   #    if ( $calc_lowest < $lowest ){
   #	    $lowest=$calc_lowest;
   #    }
   #}

   #if( defined $low  && defined $calc_low && $low ne "" && $calc_low ne "" ){ 
   #    if ( $calc_low < $low ){
   #	    $low=$calc_low;
   #    }
   #}

   my $tt=0;
   if( defined $highest && defined $high && defined $lowest && defined $low && $highest ne "" && $high ne "" && $lowest ne "" && $low ne "" ){
      $tt=1;
   }

   #my $paramid=$param{$paraname};
   
   my $desc_metadata = "\\N";          
   my $metadata =  "max;highest;high;low;lowest;min\\n$max;$highest;$high;$low;$lowest;$min";

   my $fromday=$hfromday{$MONTH};
   my $today=$htoday{$MONTH};
   
   if( $tt ){
       my $group=$paramid;
       foreach my $lparamid ( keys %{$param_group{$group}} ){              
           print OUT "$stationid|$lparamid|$level|$sensor|$fromday|$today|$QCX-$lparamid|$metadata|$desc_metadata|$fromtime\n";
       }
   }

   return;
}

close( OUT );

