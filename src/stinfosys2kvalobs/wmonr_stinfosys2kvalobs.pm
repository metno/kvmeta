package wmonr_stinfosys2kvalobs;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( %stationid_fromtime %wmono_filter );



use strict;
use DBI;
use stinfosysdb;
use trim;

our %wmono_filter;
$wmono_filter{99700}=1;
$wmono_filter{71530}=1;
$wmono_filter{99940}=1;
$wmono_filter{44550}=1;


my %exists_many_wmo;
my %station_wmo;



my $stname=  st_name();
    my $sthost=  st_host();
    my $stport= st_port();
    my $stuser=  st_user();
    my $stpasswd=st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

my $dbh = DBI->connect("dbi:Pg:dbname=$stname;host=$sthost;port=$stport", "$stuser", "$stpasswd",{RaiseError => 1}) or die "Vi får ikke forbindelse med databasen";

my $sth=$dbh->prepare("select stationid,wmono,fromtime,totime from station") or die "Can't prep\n";
$sth->execute;

my %many_wmo;
while (my @row = $sth->fetchrow()) {
  my $len=@row;
	    if($len > 2 ){
	      if( exists $wmono_filter{$row[0]} ) {
		next;
	      }
	      my $stationid=$row[0];
	      my $wmonr=$row[1];
	      my $fromtime=$row[2];
              my $totime=$row[3];
	      if( ! defined $totime ){
		#print "IKKE DEFINERT \n";
		$totime="\\N";
	      }
	      if( defined $wmonr && $wmonr ne "\\N" ) {
		# print "$stationid, $fromtime har wmonr:$wmonr\n";
		$station_wmo{$wmonr}{$stationid}{$fromtime}=$totime;
		
		if( exists $many_wmo{$wmonr} ){
		   # print "MANGE EKSISTERER $stationid, $fromtime, wmonr:$wmonr\n";
		   $many_wmo{$wmonr}++;
		   $exists_many_wmo{$wmonr}=$many_wmo{$wmonr};
		}else{
		  $many_wmo{$wmonr}=1;
		}
	      }else{
		# print "$stationid, $fromtime\n";
	      }
	    }
}
$sth->finish;
$dbh->disconnect;



our %stationid_fromtime;
my $ctrl="";


foreach my $wmonr ( keys %exists_many_wmo ){
  if( $ctrl eq "v" ){
      print "eksisterer: $exists_many_wmo{$wmonr} \n";
  }

   my $neweststationid;
   my $newestfromtime="1500-01-01";
   my $ntermstationid;
   my $ntermfromtime="1500-01-01";
   my $existnontotime=0;
   foreach my $stationid ( keys %{$station_wmo{$wmonr}} ){
     #print "$wmonr,$stationid:\n";
     foreach my $fromtime ( keys %{$station_wmo{$wmonr}{$stationid}} ){
        if( $ctrl eq "v" ){
	    print "  $wmonr,$stationid,$fromtime :  $station_wmo{$wmonr}{$stationid}{$fromtime}\n";
	}
        my $totime= $station_wmo{$wmonr}{$stationid}{$fromtime};
	if( $totime eq "\\N" ){
	   $existnontotime=1;
	  if ( greater_than ($fromtime, $newestfromtime )){
	    $neweststationid = $stationid;
	    $newestfromtime= $fromtime;
	  }
	 }elsif( ! $existnontotime ){
	  if ( greater_than ($fromtime, $ntermfromtime )){
	    $ntermstationid = $stationid;
	    $ntermfromtime= $fromtime;
	  }
	}
	$stationid_fromtime{$stationid}{$fromtime}=0;
     }
   }
  if($existnontotime){
    $stationid_fromtime{$neweststationid}{$newestfromtime}=1;
  }else{
    #print "$wmonr er ikke i bruk:$ntermstationid  \n";
    $stationid_fromtime{$ntermstationid}{$ntermfromtime}=1;
  }
 }





sub greater_than{
  my $l=shift;
  my $r=shift;
  if((defined $l ) && (defined $r) ){
    if( $l eq $r ){
      return 0;
    }
    #my @sline=split /$splitter/,$line;
    #split  /\\s+/,$terminate
    if( $l gt  $r ){
      #print "$l gt  $r\n";
      return 1;
    }
  }

  return 0;
}

1;
