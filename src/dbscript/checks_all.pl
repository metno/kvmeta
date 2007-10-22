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



use strict;

use POSIX;
use File::Copy;
use DBI;
use Cwd qw(cwd);

use dbQC;


my $control = "";

my $argn = @ARGV;

if( $argn> 0 ){
    $control = $ARGV[0];
    if( $control eq "-" ){
	#print "control == \"\" \n";
	$control = "";
    }
}

if( $argn> 1 ){
    my $filedir= $ARGV[1]; #"QC1-2_checks";
    chdir($filedir);
}

print "START \n";

my $kvpasswd=get_passwd();
our $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
    die "Connect failed: $DBI::errstr";

foreach my $file (<*checks*>){
    print $file; print "\n";
    eval { checks($file, $control) };
    if ( $@ ) {                    # EVAL_ERROR
	print "\nERROR!!\nERROR:checks $file har feilet\n\nERROR!!\n" ;
	warn "\nERROR!!\nERROR:checks $file har feilet\n\nERROR!!\n" ;
    } else {
	print "checks $file er OK\n\n";
    }
    print "*********************************";print "\n";
}

$dbh->disconnect;

print "END \n";



# Example of some rows in table checks:
# qcx            : QC1-2-101
# language       : 1
# checkname      : mediumsight_drizzlesnowthunder
# checksignature : obs;VV,WW;;|meta;VV_R1,WW_R2,WW_R3;;|

sub checks {
    my ($fromfile, $control) = @_;

    my $splitter= ":";

    my $remove_from_fromname=4;

    my $tofile = $fromfile;
    for( my $i = $remove_from_fromname; $i>0; $i-- ){
	chop($tofile);
    }
#$tofile=$tofile."_";

    open(MYFILE,$fromfile) or die "Can't open $fromfile: $!\n";

    my $line;
    my $counter=0;

    my $stationid = 0;
    my $qcx;
    my $medium_qcx;
    my $language = 1;
    my $checkname;
    my $checksignature;
    my $active= "* * * * *";
    my $fromtime= get_fromtime();


    while( defined($line=<MYFILE>) ){
	$line = trim($line);
	#last unless $line;

	if( $counter >= 15)
	{ last;}
	
	if( (length($line) > 0) && ($counter<15) ){
	    #my $x = substr($line,0,1);
	    #if($x eq "#"){
	    #	my $t= substr( $line, 1, length($line) );
            #    $t=trim($t);
	    my $t=trim($line);
	    my @words = split /$splitter/,$t;
	    my $len = @words;
            #print "len= $len \n";
	    if(($len>1) && (length(trim($words[1]))>0) ){
		my $r=trim($words[0]);
		#print $r; print "\n";
		#my $ll=trim($words[1]);
		#my $tt=length($ll);
		#print "tt=$tt\n";
		#if(length(trim($words[1]))>0){
		
		if( ($r eq "Stationid") || ($r eq "stationid") ){
		    # print "HEI!!";
		    $stationid = trim($words[1]);
		    $counter++;
		    print "stationid=$stationid  counter= $counter";  print "\n";
		}
		if( $r eq "language" ){
		    $language=trim($words[1]);
		    $counter++;
		    print "language=$language  counter= $counter";  print "\n";
		}elsif( $r eq "checkname"){
		    $checkname=trim($words[1]);
		    $counter++;
		    print "checkname=$checkname  counter= $counter";  print "\n";
		}elsif( $r eq "checksignature"){
		    $checksignature = trim($words[1]);
		    my $checksignature_ = $checksignature;
		    my $x=chop($checksignature_);
		    if( $x eq '|' ){ $checksignature=$checksignature_;}
		    $counter++;
		    print "checksignature=$checksignature  counter= $counter";  print "\n";
		}elsif( $r eq "active"){
		    $active = trim($words[1]);
		    $counter++;
		    print "active=$active  counter= $counter";  print "\n";
		}elsif( $r eq "qcx"){
		    $qcx=trim($words[1]);
		    $counter++;
		    print "qcx=$qcx  counter= $counter";  print "\n";
		}
		
	    }  
	}
    }

    close(MYFILE);



    my @med = split /-/,$qcx;
    $medium_qcx= $med[0] . "-" . $med[1];
    print "med[0] = $med[0] \n";
    print "medium_qcx= $medium_qcx \n";




    if( $control ne "ins" ){
	my $row= "$stationid~$qcx~$medium_qcx~$language~$checkname~$checksignature~$active~$fromtime";

	$tofile = '>'.$tofile;
	open(TOFILE,$tofile) or die "Can't open $tofile: $!\n";
	select(TOFILE);
	print $row;
	close(TOFILE);
	select(STDOUT);

	my $checks_manual_path=  get_checks_manual_path();
	my $cvs_checks_manual_path= get_cvs_checks_manual_path();
	print "checks_manual_path=  $checks_manual_path \n";
	print "cvs_checks_manual_path=  $cvs_checks_manual_path \n";

	my @paths=( $checks_manual_path, $cvs_checks_manual_path );
	my $dir = cwd();

	my $counter=0;
	foreach my $path ( @paths ){

	    my $katalog="driftskatalogen";
	    if( $counter == 1 ){
		$katalog="CVS";
	    }
	    $counter++;

	    if( $med[0] eq "QC2d" ){
		if( "${path}/QC2d" ne $dir ){ 
		    copy( $fromfile, "${path}/QC2d");
		}else{
		    print "st�r i $katalog katalogen \n";
		}
	    }elsif( $med[0] eq "QC1" ){
		if( $med[1] eq "2" ){
		    if( "${path}/QC1-2" ne $dir ){
			copy( $fromfile, "${path}/QC1-2");
		    }else{
			print "st�r i $katalog katalogen \n";
		    }
		}elsif( $med[1] eq "6" ){
		    if( "${path}/QC1-6" ne $dir ){
			copy( $fromfile, "${path}/QC1-6");
		    }else{
			print "st�r i $katalog katalogen \n";
		    }
		}else{
		    if( "${path}/QC1_rest"  ne $dir ){
			copy( $fromfile, "${path}/QC1_rest");
		    }else{
			print "st�r i $katalog katalogen \n";
		    }
		}
	    }else{    
		if( $path ne $dir ){
		    copy( $fromfile, $path);
		}else{
		    print "st�r i $katalog katalogen \n";
		}
	    }

	}
    }


    insert_DB( $stationid, $qcx, $medium_qcx, $language, $checkname, $checksignature, $active, $fromtime );
}

sub insert_DB{
  my ( $stationid, $qcx, $medium_qcx, $language, $checkname, $checksignature, $active, $fromtime ) = @_;

  my $sth = $dbh->prepare("SELECT language FROM checks \ 
                           WHERE stationid=$stationid AND qcx='$qcx' AND fromtime='$fromtime'");
  $sth->execute;

  my @row=();
  my @language_already=();

  while (@row = $sth->fetchrow_array) {
    push(@language_already,$row[0]);
  }
  $sth->finish;

  my $len_language=@language_already;
  print "length of language is $len_language\n";
  print "qcx=$qcx og fromtime=$fromtime\n";

  if( $len_language > 0 ){
      print "length of language is $len_language\n";
      foreach(@language_already){
	  if($_ eq $language){ 
	      if(  $control eq "ins" || $control eq 'R' ){
		  print " $qcx: Denne checken blir naa replaced";
		  my $sth = $dbh->prepare("UPDATE checks \
                                  SET  checkname = '$checkname',\
                                  checksignature = '$checksignature',\
                                  active         = '$active'\
                                  WHERE qcx='$qcx' AND fromtime='$fromtime'");
                  $sth->execute;
                  $sth->finish;
                  return;
	      }
              else{
	        print " $checkname: Dette spraaket er $_ og finnes i fra for; ingen oppdateringer \n";
	        exit 0;
	      }
	  }
          else{
	      print " $checkname finnes ogsaa for spraak $_ \n";
	  }
      }
  }

  ########################

    #print " $checkname: Denne algoritmen blir naa replaced";
    #my $sth = $dbh->prepare("UPDATE algorithms \
    #                        SET  signature = '$signature', script = '$script' \
    #                        WHERE language like '$language' AND checkname like '$checkname'");
    #$sth->execute;
    #$sth->finish;




  $sth = $dbh->prepare("INSERT INTO checks VALUES($stationid,'$qcx','$medium_qcx',$language, \
                        '$checkname', '$checksignature', '$active','$fromtime')");
  $sth->execute;
  
  $sth->finish;

  return;
}
