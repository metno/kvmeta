#!/usr/bin/perl -w

# Genererer fil for utesperring av parametere for en stasjon

## use trim;
use strict;
use DBI;
use warnings;
use diagnostics;
use Data::Dumper;
use conf;

my $sth=0;
my $dbh=0;

my $sth2=0;
my $dbh2=0;

my $h=new conf ("kro.conf","");

my $PGHOST= $h->get("PGHOST");
my $PGNAME= $h->get("PGNAME");
my $PGUSER= $h->get("PGUSER");
my $PGPORT= $h->get("PGPORT");
my $PGPASSWD= $h->get("PGPASSWD");

my $h2=new conf ("kvalobs.conf","");

my $PGHOST2= $h2->get("PGHOST");
my $PGNAME2= $h2->get("PGNAME");
my $PGUSER2= $h2->get("PGUSER");
my $PGPORT2= $h2->get("PGPORT");
my $PGPASSWD2= $h2->get("PGPASSWD");

#print "ttt=$PGHOST    \n";

#-------------------------------------------------------------------
####            BEGIN HOVEDPROGRAM

$dbh = DBI->connect("dbi:Pg:dbname=$PGNAME;host=$PGHOST;port=$PGPORT", $PGUSER, $PGPASSWD) or die "Vi får ikke forbindelse med databasen";
$dbh2 = DBI->connect("dbi:Pg:dbname=$PGNAME2;host=$PGHOST2;port=$PGPORT2", $PGUSER2, $PGPASSWD2) or die "Vi får ikke forbindelse med databasen";
my %hh;
    $sth2 = $dbh2->prepare("select stationid, qcx, fromtime, active from checks where checkname='push6flag'") or die $dbh2->errstr;
    $sth2->execute;
    while (my @row2 = $sth2->fetchrow()) { 
	#print "@row\n";
	my $stationid=$row2[0];
        my $qcx=$row2[1];
        my $fromtime=$row2[2];
        my $active=$row2[3];
        # print "$stationid $qcx $fromtime -> $active \n";
        $hh{$stationid}{$qcx}{$fromtime}=$active;
    }
    $sth2->finish;

my %param=fill_param();

simple_utesperring_update();
simple_friskmelding_update();
advanced_utesperring_update();
advanced_friskmelding_update();

$dbh->disconnect; #Kutter database
$dbh2->disconnect; #Kutter database

# print "Her kommer dollarkl: $kl\n"; 

###           SUB-RUTINER I HOVEDPROGRAM            
###########################################################
#-------------------------------


sub simple_utesperring_update { 
    $sth = $dbh->prepare("select stationid, paramid, fromtime from operational where totime is NULL and hlevel=0 and message_formatid=0 and sensor=0") or die $dbh->errstr;
    $sth->execute;
    
    while (my @row = $sth->fetchrow()) { 
	#print "@row\n";
	my $stationid=$row[0];
        my $paramid=$row[1];
        my $fromtime=$row[2];
        my $para_name=$param{$paramid};
	my $qcx="QC1-0-$paramid";
	if( exists $hh{$stationid}{$qcx}{$fromtime} ){
            # print "simple_utesperring_update :: $stationid $qcx $fromtime \n";
	    if ( $hh{$stationid}{$qcx}{$fromtime} ne '* * * * *' ){
		 print "update checks set active='* * * * *' where stationid=$stationid and qcx='$qcx' and checkname='push6flag';" . "\n";
	    }
	}				     
    } 
    $sth->finish;
    return;
}


sub simple_friskmelding_update { 
    $sth = $dbh->prepare("select stationid, paramid, fromtime from operational where totime is NOT NULL and hlevel=0 and message_formatid=0 and sensor=0") or die $dbh->errstr;
    $sth->execute;
    
    while (my @row = $sth->fetchrow()) { 
	#print "@row\n";
	my $stationid=$row[0];
        my $paramid=$row[1];
        my $fromtime=$row[2];
        my $para_name=$param{$paramid};
	my $qcx="QC1-0-$paramid";
	if( exists $hh{$stationid}{$qcx}{$fromtime} ){
	    if ( $hh{$stationid}{$qcx}{$fromtime} ne '0 0 0 0 0' ){
		print "update checks set active='0 0 0 0 0' where stationid=$stationid and qcx='QC1-0-$paramid' and checkname='push6flag';" . "\n";
	    }
	}
    }
    $sth->finish;
    return;
}


sub advanced_utesperring_update{
    $sth = $dbh->prepare("select stationid, paramid, hlevel, message_formatid, sensor, fromtime from operational where totime is NULL and ( hlevel<>0 or message_formatid<>0 or sensor<>0 )") or die $dbh->errstr;
    $sth->execute;
    
    while (my @row = $sth->fetchrow()) { 
	#print "@row\n";
	my $stationid=$row[0];
        my $paramid=$row[1];
	my $hlevel=$row[2];
	my $message_formatid=$row[3];
	my $sensor=$row[4];
	my $fromtime=$row[5];
        my $para_name=$param{$paramid};

        if( $hlevel == 0 ){
	    $hlevel="";
	}
	if( $message_formatid == 0 ){
	    $message_formatid=""; 
	}
	if( $sensor == 0 ){
	    $sensor="";
	}
	# print "hlevel=$hlevel \n";
        # print "message_formatid=$message_formatid \n";

        my $checksignature="obs;$para_name&$hlevel&$sensor&$message_formatid;;";
	my $qcx="QC1-0-$paramid";

        if( $hlevel ne "" ){
	   $qcx .= "_l" . $hlevel; 
        }
	if( $sensor ne "" ){
	    $qcx .= "_s" . $sensor;
	}
	if( $message_formatid ne "" ){
            $qcx .= "_" . $message_formatid;
	}
        
	#print "insert into checks values ($stationid,'$qcx','QC1-0','1','push6flag','$checksignature','* * * * *','$fromtime');" . "\n";
	if( exists $hh{$stationid}{$qcx}{$fromtime} ){
	    if ( $hh{$stationid}{$qcx}{$fromtime} ne '* * * * *' ){
		 print "update checks set active='* * * * *' where stationid=$stationid and qcx='$qcx' and checkname='push6flag';" . "\n";
	    }
	}				     
    } 
    $sth->finish;
    return;

}


sub advanced_friskmelding_update{
    $sth = $dbh->prepare("select stationid, paramid, hlevel, message_formatid, sensor, fromtime from operational where totime is NOT NULL and ( hlevel<>0 or message_formatid<>0 or sensor<>0 )") or die $dbh->errstr;
    $sth->execute;
    
    while (my @row = $sth->fetchrow()) { 
	#print "@row\n";
	my $stationid=$row[0];
        my $paramid=$row[1];
	my $hlevel=$row[2];
	my $message_formatid=$row[3];
	my $sensor=$row[4];
	my $fromtime=$row[5];
        my $para_name=$param{$paramid};

        if( $hlevel == 0 ){
	    $hlevel="";
	}
	if( $message_formatid == 0 ){
	    $message_formatid=""; 
	}
	if( $sensor == 0 ){
	    $sensor="";
	}
	# print "hlevel=$hlevel \n";
        # print "message_formatid=$message_formatid \n";

        my $checksignature="obs;$para_name&$hlevel&$sensor&$message_formatid;;";
	my $qcx="QC1-0-$paramid";

        if( $hlevel ne "" ){
	   $qcx .= "_l" . $hlevel; 
        }
	if( $sensor ne "" ){
	    $qcx .= "_s" . $sensor;
	}
	if( $message_formatid ne "" ){
	    $qcx .= "_" . $message_formatid;
	}
        
	#print "insert into checks values ($stationid,'$qcx','QC1-0','1','push6flag','$checksignature','* * * * *','$fromtime');" . "\n";
	if( exists $hh{$stationid}{$qcx}{$fromtime} ){
	    if ( $hh{$stationid}{$qcx}{$fromtime} ne '0 0 0 0 0' ){
		 print "update checks set active='0 0 0 0 0' where stationid=$stationid and qcx='$qcx' and checkname='push6flag';" . "\n";
	    }
	}				     
    } 
    $sth->finish;
    return;
}

sub fill_param {
    my $sth  = $dbh->prepare("select paramid, name from param");
    $sth->execute;
    my %param;

    while ( my @row = $sth->fetchrow_array ) {
        $param{"$row[0]"} = $row[1];
    }

    $sth->finish;

    return %param;
}
