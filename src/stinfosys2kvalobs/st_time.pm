package st_time;
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: st_time.pm 1 2010-04-16 16:21:15Z terjeer $
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
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( is_legal_time is_greaterDate getDate getTime get_current_time );

use strict;
use Date::Calc qw( check_date check_time Delta_Days );
use trim;


sub is_legal_time{
  my $stime=shift;
  my $legal_time=1;
 
  if ( $stime =~ /\d\d\d\d-\d?\d-\d?\d \d?\d:\d?\d:\d?\d/ ){
    #print "islegal:DATETIME::$stime \n";
    my ($year,$month,$day)=getDate($stime);
    my ($hour,$min,$sec)=getTime($stime);
    if (check_date($year,$month,$day)){
      ;
    }else{
      #print "Brum i veidate\n";
      return 0;
    }

    if (check_time($hour,$min,$sec)){
	return 1;
    }else{
      #print "Brum i veitime \n";
      return 0;
    }
  }


  if ( $stime =~ /\d\d\d\d-\d?\d-\d?\d/ ){
    #print "islegal:DATE:$stime \n";
    my ($year,$month,$day)=getDate($stime);
    if (check_date($year,$month,$day)){
       return 1;
    }else{
      #print "Brum i veidate \n";
      return 0;
    }
  }
    
  return 0;

}

sub is_greaterDate{
  my $l=shift;
  my $r=shift;
  if((defined $l ) && (defined $r) ){
    if( $l eq $r ){
      return 0;
    }
    if( $l eq "\\N" ){
      return 1;
    }

    my ($lyear,$lmonth,$lday)=getDate($l);
    my ($ryear,$rmonth,$rday)=getDate($r);

    if( Delta_Days($ryear,$rmonth,$rday, $lyear,$lmonth,$lday) > 0){
      return 1;
    }

  }

  return 0;
}


sub getDate{
  my ( $isotime )=  @_;

  $isotime= trim($isotime);

  if( length($isotime)>0 ){
        my @sline=split /\s+/,$isotime;
        my $len=@sline;
        #print "len=$len \n";
        #print "sline0= $sline[0] \n";
        #print "sline1= $sline[1] \n";

        if($len >0){
          my @date=split /-/,$sline[0];
          $date[0]= trim_lzero($date[0]);
          $date[1]= trim_lzero($date[1]);
          $date[2]= trim_lzero($date[2]);
          return @date;
      }
    }
  return (0,0,0);
}


sub getTime{
  my ( $isotime )=  @_;

  $isotime= trim($isotime);

  if( length($isotime)>0 ){
        my @sline=split /\s+/,$isotime;
        my $len=@sline;
        #print "len=$len \n";
        #print "sline0= $sline[0] \n";
        #print "sline1= $sline[1] \n";

        if($len>1){
          my @clock=split /:/,$sline[1];
	  $clock[0]=trim_lzero($clock[0]);
	  $clock[1]=trim_lzero($clock[1]);
	  $clock[2]=trim_lzero($clock[2]);
          return @clock;
          }
      }
  return (0,0,0);
}


sub get_current_time{
    my @tt=    gmtime(time);
    my $curtime;

    my $year=  1900 +  $tt[5];
    my $month= $tt[4] + 1;
    my $day=   $tt[3];
    my $hour=  $tt[2];
    my $minute= $tt[1]; ##########
    if($month<10){
        $month='0' . $month;
    }

    if($day<10){
        $day='0' . $day;
    }

    if($hour<10){
        $hour='0' . $hour;
    }

     if($minute<10){         ################
        $minute='0' . $minute;
    }

    $curtime="$year-$month-$day $hour:$minute";
    #print "tidspunkt: $curtime\n";
    return $curtime;
}


1;
