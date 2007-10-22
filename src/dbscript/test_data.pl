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




#####README BEGIN####
# INPUT: This script reads one file as input.
#       The format of this file is:
#       STNR   AAR MND DAG TIM  VALUE T PARAMID
#       Empty is used as a splitter.
#       Each row has a size of 8 columns
#       A row with the size of 7 means the value is missing and the flag is set.
#       less than 7 columns means the row gets ignored.
#
#   The columns are defined as:
#       STNR means stationid( the id for the station) for the observation.
#       AAR is the year for the observation
#       MND is the month for the observation
#       DAG is the day for the observation
#       TIM is the hour for the observation
#       VALUE is the observed value
#       T is a sign that can be used to anything, it is not used, but it has to be there
#       PARAMID is the parameter that is observed, that is the parameterid in kvalobs.
#
# OUTPUT: The filename of the output file is the filename of the input 
#         file extended with .out. The format of the outputfile i is
#         the COPY format of the table test_data whith DELIMETERS |.
#          (that is the same format as that for the data table )
# SIDEEFFECT/FUNCTIONALITY: Those rows that exist in the database before 
#              with the same key as those on the outputfile are deleted in the database. 
#               The outputfile is put into the database.
#              if paramid is 55(HL), 273(VV) or 301,302,303,304(HS) then the
#              the value get converted.
# USAGE: This script has only one argument and is used like this: test_data filename
#
#
#####README BEGIN####


use POSIX;
use strict;
use decodeutility;
use DBI;
use intodb;
use dbQC;

my $typeid=0;       # INTEGER NOT NULL,
my $sensor=0;       # CHAR(1) DEFAULT '0',
my $level=0;        # INTEGER DEFAULT 0,
#my $corrected='\N'; # FLOAT NOT NULL,
my $controlinfo_std ='0000000000000000'; # CHAR(16) DEFAULT '0000000000000000',
my $controlinfo_missing ='0000003000000000';
my $useinfo =  '0000000000000000';   # CHAR(16) DEFAULT '0000000000000000',
my $cfailed='\N';                    # TEXT DEFAULT NULL


my $len= @ARGV;
if( $len<1 ){ 
    print "No argument \n";
    exit 0;
}

#my $arg       = $ARGV[0];
my $outfilename = $ARGV[0].".out";

my $kvpasswd=get_passwd();
my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";

 

my $fromfile=$ARGV[0];
open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";


my $outfile= '>'.$outfilename;
open(MYFILEOUT,$outfile) or die "Can't open  $outfile: $!\n";
print "$outfilename \n";
select(MYFILEOUT);




my $line;
my $splitter="\\s+";
while( defined($line=<MYFILE>) ){
    $line=trim($line); 
    if( length($line)>0 ){
            my @sline = split /$splitter/,$line;
            my $len = @sline;
            
		my $stationid = $sline[0];
		my $aar =  $sline[1];
		my $mnd = $sline[2];
		my $day = $sline[3];
		my $time = $sline[4];
	        my $original;
	        my $paramid;
	        my $controlinfo;

	        if( $len == 8){
		    $original = $sline[5];
		    $paramid = $sline[7];
		    $controlinfo= $controlinfo_std;

                    if( $paramid == 55 ){ #HL
			$original=HL($original);
		    }

		    if( $paramid == 273 ){#VV
		        $original=VV($original);
		    }
		
		    if( $paramid == 301 || $paramid == 302 || $paramid == 303 || $paramid == 304 ){#HS
			$original=HS($original);
		    }
	    
	        }elsif( $len == 7 ){
		    #$original = '\N';
		    $original = -32767;
		    $paramid = $sline[6];
		    # print "ERROR len=$len paramid=$paramid \n";
                    $controlinfo= $controlinfo_missing;
		}else{
		    next;
		}
            
		$day = sprintf("%02d",$day);
		$mnd = sprintf("%02d",$mnd);
		$time= sprintf("%02d",$time);

		my $obstime = "$aar-$mnd-$day $time:00:00+00";
		my $tbtime = $obstime;
            
		#if( $paramid>50 && $paramid<60){
		#	print "paramid=$paramid";
		#}

 my $corrected= $original;

	    if( isUnique( $stationid, $paramid, $obstime )){
#Insert("$stationid,'$obstime',$original,$paramid,'$tbtime',$typeid,$sensor,$level,'$corrected','$controlinfo','$useinfo','$cfailed'");
	    } else{
		Delete( $stationid, $paramid, $obstime, $original );
            } 
	    print "$stationid|$obstime|$original|$paramid|$tbtime|$typeid|$sensor|$level|$corrected|$controlinfo|$useinfo|$cfailed \n";
	}
}
 

close(MYFILEOUT);
close(MYFILE);   

$dbh->disconnect;

select(STDOUT);
    
dtodb( "test_data", $outfilename, '|' );




sub isUnique{
  my $stationid = shift;
  my $paramid   = shift;
  my $obstime   = shift; 

  
  #print "start isUnique";
  my $sth = $dbh->prepare("select * from test_data where stationid= $stationid and obstime= '$obstime' and paramid = $paramid");
  $sth->execute;
  

  my @row;
  my @data_already;
  
  while( @row = $sth->fetchrow_array ){
      push(@data_already, $row[0]);
  }

  $sth->finish;

  my $len_data = @data_already;

  
  if( $len_data == 0 ){
      #print "1:$stationid|$paramid|$obstime \n";
      return 1;
  }else{  
      #print "0:$stationid|$paramid|$obstime \n";
      return 0;
  }

}


sub Delete{
    my $stationid=shift;
    my $paramid=shift;
    my $obstime=shift;
    my $original=shift;

    #print "Update:$stationid|$paramid|$obstime \n";

    #my $sth = $dbh->prepare("UPDATE test_data \
    #                         SET   original = '$original' \
    #                         WHERE stationid=$stationid AND paramid=$paramid AND \
    #                               obstime = '$obstime'");

    my $sth = $dbh->prepare("DELETE from test_data \
                             WHERE stationid= $stationid AND paramid = $paramid AND \
                                   obstime = '$obstime'");
   
    #my $sth = $dbh->prepare("DELETE from test_data \
    #                         WHERE stationid like '$stationid'");

    $sth->execute;
    $sth->finish;

    #print "return Update\n";    

    return;
}


sub Insert{
    my $arg=shift;


    my $sth = $dbh->prepare("INSERT INTO test_data VALUES  ($arg) ");
    $sth->execute;
    $sth->finish;

    return;
}







