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
use DBI;
use dbQC;
use intodb;



#my $splitter="\\s+";
my $splitter="~";

my $fromfile = $ARGV[0];

my $checks_path = get_checks_path();
print "checks_path =  $checks_path \n";
my $checks_fromfile = $checks_path . "/$fromfile";

open(MYFILE,$checks_fromfile) or die "Can't open $checks_fromfile: $!\n";

my $line;
# does read in the connection between qcx and checks
my %qcx_checks;
my %qcx_param_checks;
my @qcx_list;


my $fromtime = get_fromtime();

while( defined($line=<MYFILE>) ){
    $line =~ s/^\s*(.*)\s*$/$1/;#Her utf?res en trim

	if( length($line)>0 ){
            my @sline=split /$splitter/,$line;
	    my $len = @sline;
	    
            if( $len==3 ){
               my $qcx = trim($sline[0]);
               my $checkname = trim($sline[1]);
	       my $check_signature = trim($sline[2]);
               if( ($checkname ne "") and ($check_signature ne "") ){
		     push(@qcx_list,$qcx);
	             $qcx_checks{$qcx} = [$checkname,$check_signature];
	       }
		 
	   }elsif(  $len==4 ){
	       my $qcx = trim($sline[0]);
	       my $paramid = trim($sline[1]);
               my $checkname = trim($sline[2]);
	       my $check_signature = trim($sline[3]);
	       print "check_signature= $check_signature \n";
	       if( ($checkname ne "") and ($check_signature ne "") ){
	             $qcx_param_checks{$paramid} = [$checkname,$check_signature];
	       }
	       
	   }
      }
}


   close(MYFILE);


   #my @driver_names = DBI->available_drivers;
   #print @driver_names;

    my $kvpasswd=get_passwd();
    my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
	die "Connect failed: $DBI::errstr";

    my $sth = $dbh->prepare('select paramid, name  from param');
    $sth->execute;
    my @row=();
    my %param;
    while (@row = $sth->fetchrow_array) {
	#print "$row[0] : $row[1] \n";
        $param{$row[0]}=$row[1];
    }
    $sth->finish;

    my $qcx;
    my %qcx_param;
    my @ndef_paramid;
    foreach $qcx (@qcx_list){
	#print $qcx; print "\n";
	my $sth = $dbh->prepare("select distinct paramid from station_param where qcx like '$qcx%'");

        $sth->execute;
        my @row=();
        my @param_list=();
        while (@row = $sth->fetchrow_array) {
	    if(defined($param{$row[0]})){
               #print "param_list: $row[0] \n";
	       push(@param_list,$row[0]);
	   }else{
	       #print "ndef_paramid: $row[0] \n";
	       push(@ndef_paramid,$row[0]);
	   }
        }
        $qcx_param{$qcx}=\@param_list;
        $sth->finish;
    }

    $dbh->disconnect;


#################################################################
my $is_qcxsimple=0;

if( defined($ARGV[1])){

    if( $ARGV[1] eq "t" ) {
      open(MYFILE,">make_checks_log") or die "Can't open make_checks_log : $!\n";
      for my $a (@ndef_paramid){ print $a . " : ";}
      close(MYFILE);
    }

   if( $ARGV[1] eq "s" ) {
       #print "s is OK\n";
       $is_qcxsimple=1;
   }

}

      my $outfilename= $ARGV[0].".out";
      my $checks_outfilename = $checks_path . "/$outfilename";
      my $checks_outfile = ">" . $checks_path . "/$outfilename";
      print "checks_outfile= $checks_outfile \n";
      open(MYFILEOUT,$checks_outfile) or die "Can't open  $checks_outfile: $!\n";
      select(MYFILEOUT);


################################################################
  my $checkid=0;
  my $checkname;

  my $stationid=0;
  my $language=1;
  my $active = "* * * * *";


  foreach $qcx (@qcx_list){

      my @qcx_check = @{$qcx_checks{$qcx}};
      my @param_list = @{$qcx_param{$qcx}};
      my $checkname = $qcx_check[0]; 
      my $check_signature = $qcx_check[1];
      my $paramid;
      foreach $paramid (@param_list){
              my $name = $param{$paramid};
              if( !defined($name) ){
		  $name="NOT EXISTS";
	      }
              my $checksignature = $check_signature;
              my $param_template= '\x24\x24'; 
	      #$checksignature =~ s/XX/$name/g;
              #$checksignature =~ s/##/$name/g;
              $checksignature =~ s/$param_template/$name/g;

              if($is_qcxsimple){
                   print "$stationid~$qcx~$qcx~$language~$checkname~$checksignature~$active~$fromtime\n";
	       }else{
		   if( defined $qcx_param_checks{$paramid} ){
		       my @param_check = @{$qcx_param_checks{$paramid}};
		       my $checkname_p = $param_check[0]; 
		       my $checksignature_p = $param_check[1];
		       $checksignature_p =~ s/$param_template/$name/g;
		       print "$stationid~$qcx-$paramid~$qcx~$language~$checkname_p~$checksignature_p~$active~$fromtime\n";
		   }else{
		       print "$stationid~$qcx-$paramid~$qcx~$language~$checkname~$checksignature~$active~$fromtime\n";
		   }
	       }
      }
  }


close(MYFILEOUT);
select(STDOUT);


foreach $qcx (@qcx_list){
  print "qcx= $qcx \n";
}


flintodb( $checks_path, "checks", $outfilename, '~', @qcx_list );




