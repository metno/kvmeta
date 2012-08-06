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

open(LOG,">T_KC2kvalobs.log");
my $null='\N';

  my $stname=  st_name();
  my $sthost=  st_host();
  my $stport=  st_port();
  my $stuser=  st_user();
  my $stpasswd=st_passwd();

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Cant't connect";

my $sth=$dbh->prepare("select distinct stationid,paramid,fromtime,totime from obs_pgm where paramid in (262,211) and hour != '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'") or die "Can't prep\n";

    $sth->execute;

    my %stat_par;
    while (my @row = $sth->fetchrow()) {
        my $fromtime=$row[2];
        my $totime=$row[3];
        if( not defined $totime or $totime eq "" ) {
            $totime = $null;
        }
        my $ft=[$fromtime,$totime];
        #if( $row[0] == 32100 and $row[1] == 262 ){
            #my($fromtime2,$totime2)=@{$ft}; 
            #print "$fromtime2,$totime2 \n";
            my @ft_list;
	    if( exists $stat_par{$row[0]}{$row[1]} ){
	        @ft_list=@{ $stat_par{$row[0]}{$row[1]} };
            }else{
	      @ft_list=();
            } 
            push(@ft_list,$ft);
            $stat_par{$row[0]}{$row[1]}=\@ft_list;
        #}
    }

#my $stationid=32100;
#my $paramid=262;

#my @stat_par_list=@{ $stat_par{$stationid}{$paramid} };
#   my $len2=@stat_par_list;
#   print "len2=$len2 \n";
#
#   foreach my $ft ( @stat_par_list ){
#          print "hei 2\n";
#          my ($fromtime,$totime)=@{$ft};
#          print "$fromtime,$totime \n";
#   }
#
#exit 0;

###########################
my $narg=@ARGV;

my %ELEM_CODE_par;
   $ELEM_CODE_par{"C"}=262;
   $ELEM_CODE_par{"K"}=211;

my $fromfile;
if ( $narg>0 ){
  $fromfile=$ARGV[0];
}

my $line;
my $splitter=',';

if ( $narg>0){
    open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

    while( defined($line=<MYFILE>) ){
      $line=trim($line);
      if( $line =~ /selected/ ){ next; }
      if( $line =~ /SQL/ ){ next; }

      if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
            my $len=@sline;
	    #print "$sline[0] =  $len \n";
	    if( $len > 1 ){
		my $stationid = trim($sline[0]);
		my $ELEM_CODE = trim($sline[1]);
                my $FYEAR = trim($sline[2]);
                my $FMONTH = trim($sline[3]);
		my $TYEAR = trim($sline[4]);
		my $TMONTH = trim($sline[5]);
		my $JAN = trim($sline[6]);
 		my $FEB = trim($sline[7]);
 		my $MAR = trim($sline[8]);
 		my $APR = trim($sline[9]);
 		my $MAY = trim($sline[10]);
 		my $JUN = trim($sline[11]);
 		my $JUL = trim($sline[12]);
 		my $AUG = trim($sline[13]);
 		my $SEP = trim($sline[14]);
 		my $OCT = trim($sline[15]);
 		my $NOV = trim($sline[16]);
 		my $DEC = trim($sline[17]);
 		my $FDATO = trim($sline[18]);
 		my $TDATO = trim($sline[19]);

                print_station_metadata($stationid,$ELEM_CODE,$JAN,$FEB,$MAR,$APR,$MAY,$JUN,$JUL,$AUG,$SEP,$OCT,$NOV,$DEC,$FDATO,$TDATO);
	    }
	}
  }
}


sub print_station_metadata{
my ($stationid,$ELEM_CODE,$JAN,$FEB,$MAR,$APR,$MAY,$JUN,$JUL,$AUG,$SEP,$OCT,$NOV,$DEC,$FDATO,$TDATO)=@_;

    my ($year,$month,$day) = Today();
    if( $year lt $TDATO ){
         $TDATO=$null;
    }
    
    my $paramid=$ELEM_CODE_par{$ELEM_CODE};

    if( (! defined $JAN) or $JAN eq "" ){ $JAN=$null; }
    if( (! defined $FEB) or $FEB eq "" ){ $FEB=$null; }
    if( (! defined $MAR) or $MAR eq "" ){ $MAR=$null; }
    if( (! defined $APR) or $APR eq "" ){ $APR=$null; }
    if( (! defined $MAY) or $MAY eq "" ){ $MAY=$null; }
    if( (! defined $JUN) or $JUN eq "" ){ $JUN=$null; }
    if( (! defined $JUL) or $JUL eq "" ){ $JUL=$null; }
    if( (! defined $AUG) or $AUG eq "" ){ $AUG=$null; }
    if( (! defined $SEP) or $SEP eq "" ){ $SEP=$null; }
    if( (! defined $OCT) or $OCT eq "" ){ $OCT=$null; }
    if( (! defined $NOV) or $NOV eq "" ){ $NOV=$null; }
    if( (! defined $DEC) or $DEC eq "" ){ $DEC=$null; }

    
 my @ft_list=station_time($stationid,$paramid,$FDATO,$TDATO);
 my $len=@ft_list;

 foreach my $ft ( @ft_list ){
     my ($Ftime,$Ttime)=@{$ft};
     if( defined $Ftime ){
        if( $JAN ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_01|$JAN|$Ftime|$Ttime\n"; }
        if( $FEB ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_02|$FEB|$Ftime|$Ttime\n"; }
        if( $MAR ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_03|$MAR|$Ftime|$Ttime\n"; }
        if( $APR ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_04|$APR|$Ftime|$Ttime\n"; }
        if( $MAY ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_05|$MAY|$Ftime|$Ttime\n"; }
        if( $JUN ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_06|$JUN|$Ftime|$Ttime\n"; }
        if( $JUL ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_07|$JUL|$Ftime|$Ttime\n"; }
        if( $AUG ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_08|$AUG|$Ftime|$Ttime\n"; }
        if( $SEP ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_09|$SEP|$Ftime|$Ttime\n"; }
        if( $OCT ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_10|$OCT|$Ftime|$Ttime\n"; }
        if( $NOV ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_11|$NOV|$Ftime|$Ttime\n"; }
        if( $DEC ne $null ){ print "$stationid|$paramid|$null|$null|$null|koppen_12|$DEC|$Ftime|$Ttime\n"; }
     }
 } 
    return;
}

#my %stationid_fromtime;
#    while (my @row = $sth->fetchrow()) {
#	$st{$row[0]}{$row[1]}{$row[2]}={$row[3]};
#    }

sub station_time{
 my ($stationid,$paramid,$FDATO,$TDATO)=@_;

   my $Ftime=$FDATO . " 00:00:00";
   my $Ttime=$null;
   if( $TDATO ne $null ){
       $Ttime=$TDATO . " 00:00:00";
   }

   my @ft_list=();

 if( ! defined $stationid ){
     print LOG "stationid not defined \n";
     return ();
 }
#else{
#   print "stationid=$stationid\n";
#}

 if( exists $stat_par{$stationid}{$paramid} ){
     print LOG "HEllO :: $stationid :: $paramid \n"; 
   
     my @stat_par_list=@{$stat_par{$stationid}{$paramid}};
     my $len=@stat_par_list; print LOG "len=$len \n";
   
     foreach my $ft ( @stat_par_list ){
          my ($fromtime,$totime)=@{$ft};
          print LOG "$fromtime,$totime,$Ftime,$Ttime\n";
          my $ft_ref=time_intersection($fromtime,$totime,$Ftime,$Ttime);
          push(@ft_list,$ft_ref);
     }
     return @ft_list;
 }else{
    print LOG "NOT exists :: $stationid :: $paramid :: $FDATO :: $TDATO \n";
    return ();  
 }
}


sub time_intersection{
  my($fromtime,$totime,$Ftime,$Ttime)=@_;
     my $f=$Ftime;
     my $t=$Ttime;
    
    if( $fromtime gt $f ){
	$f=$fromtime;
    }

    if( greater_than($t, $totime) ){
	$t=$totime
    }

    if( greater_than( $f, $t ) ){
	return [];
    }
    
    return [ $f, $t ];
}


sub greater_than{
  my $l=shift;
  my $r=shift;
  if( (defined $l ) && (defined $r) ){
     if( $r ne $null ) {
        if( $l eq $null ){
           return 1;
        }
        if( $l gt  $r ){
           return 1;
        }
     }
  }
  return 0;
}

close(LOG);

