package base_station_param;
require Exporter;#use Exporter ();
@ISA = qw(Exporter);
@EXPORT = qw(insert_DB);

use POSIX;
use strict;
use DBI;

#select(STDERR);


sub insert_DB{
  my ( $control, $stationid, $paramid, $level, $sensor, $fromday, $today, $qcx, $metadata, $desc_metadata, $fromtime ) = @_;

  my $kvpasswd=get_passwd();
  my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
	die "Connect failed: $DBI::errstr";


  #################

  my $sth = $dbh->prepare("SELECT level, sensor, fromday, today FROM station_param \ 
                           WHERE  stationid = $stationid AND paramid = $paramid AND \
                                  qcx = '$qcx' AND fromtime = '$fromtime'");
  $sth->execute;

  my @row=();
  my @station_param=();

  while (@row = $sth->fetchrow_array) {
    my @val=@row;
    push(@station_param,\@val);
  }
  $sth->finish;

  my $len_station_param=@station_param;

  if( $len_station_param > 0 ){
      print "length of  station_param is $len_station_param\n";
      my $ref;
      foreach $ref (@station_param){
          print "station_param: level = $ref->[0] \n";
          print "station_param: sensor = $ref->[1] \n";
      }
  }

  if( $len_station_param > 0 ){
      print "length of  station_param is $len_station_param\n";
      foreach(@station_param){     
         if( $control eq 'R' ){
	      if( $_->[0] eq $level && $_->[1] eq $sensor && $_->[2] eq $fromday && $_->[3] eq $today ){ 
		  print "1: $stationid, $paramid, $qcx, $metadata: Denne raden i station_param tabellen blir naa replaced \n";
		    my $sth = $dbh->prepare("UPDATE station_param \
                                  SET   metadata = '$metadata', desc_metadata = '$desc_metadata' \
                                  WHERE stationid = $stationid AND paramid = $paramid AND \
                                        qcx = '$qcx' AND fromtime = '$fromtime'");
                    $sth->execute;
                    $sth->finish;
		    $dbh->disconnect;
                    return;
                }else{
                print "2: $stationid, $paramid, $qcx, $metadata: Denne raden i station_param tabellen blir naa replaced \n";
                    my $sth = $dbh->prepare("UPDATE station_param \
                                  SET  level =  '$level', sensor = '$sensor', \
                                       fromday = '$fromday', today = '$today', \
                                       metadata = '$metadata', desc_metadata = '$desc_metadata' \
                                  WHERE stationid = $stationid AND paramid = $paramid AND \
                                        qcx = '$qcx' AND fromtime = '$fromtime'");
                    $sth->execute;
                    $sth->finish;
                    $dbh->disconnect;
                    return;
                }
	  }# end if( $control eq 'R' )
	  else{
             print "$stationid, $paramid, $qcx: Denne raden har verdier i fra for; ingen oppdateringer \n";
             $dbh->disconnect;
             return;
          }
     }
  }

  ########################


  #$stationid, $paramid, $level, $sensor, $fromday, $today, $qcx, $metadata, $desc_metadata, $fromtime
  print "3: $stationid, $paramid, $qcx, $metadata: denne raden blir naa lagt til \n"; 
  $sth = $dbh->prepare("INSERT INTO station_param VALUES('$stationid','$paramid','$level','$sensor','$fromday','$today',\
                                                  '$qcx','$metadata','$desc_metadata','$fromtime')");
  $sth->execute;
  
  $sth->finish;

  $dbh->disconnect;
  return;
}



1;











