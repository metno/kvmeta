package intodb;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( fintodb flintodb dtodb static_intodb all_intodb );


use POSIX;
use strict;
use DBI;
use dbQC;


sub flintodb{
    my ( $path, $tablename, $outfilename, $del, @qcx_list ) = @_;

    foreach my $qcx (@qcx_list){
      print "qcx= $qcx \n";
      fimport("delete from $tablename where qcx like '$qcx%'");
    }
    todb($path,$tablename, $outfilename,$del);

    return;
}


sub fintodb{
    my $path  =   shift;
    my $tablename=   shift;
    my $outfilename= shift;
    my $qcx= shift;
    my $del= shift;

    fimport("delete from $tablename where qcx like '$qcx%'");
    todb($path,$tablename, $outfilename,$del);

    return;
}


sub dtodb{
    my $tablename= shift;
    my $outfilename= shift;
    my $del= shift;
    todb("",$tablename, $outfilename,$del);

    return;
}



sub static_intodb{
    my $path  =   shift;
    my $tablename=   shift;
    my $outfilename= shift;
    my $del= shift;

    fimport("delete from $tablename where static=true");
    todb($path,$tablename, $outfilename,$del);
    return;
}




sub all_intodb{
    my $path  =   shift;
    my $tablename=   shift;
    my $outfilename= shift;
    my $del= shift;

    fimport("truncate table $tablename");
    todb($path,$tablename, $outfilename,$del);
    return;
}




sub todb{
    my $path  =   shift;
    my $tablename=   shift;
    my $outfilename= shift;
    my $del= shift;
    my $path_outfilename;

    

    if( $path ne "" ){
       $path_outfilename= $path . "/$outfilename";
   }else{
       $path_outfilename=$outfilename
   }

    #my $hostname= $ENV{"HOSTNAME"};
    my $pghost=   $ENV{"PGHOST"};

    #print "hostname= $hostname \n";
    print "pghost= $pghost \n";

    $ENV{"PGPASSWORD"}=get_passwd();
    print "path_outfilename=  $path_outfilename\n";
    system("cp  $path_outfilename /tmp/$outfilename");
    print "psql -a -d kvalobs -U kvalobs -c \"\\copy $tablename from \'/tmp/$outfilename\' DELIMITER \'$del\'\" \n";
    system("psql -a -d kvalobs -U kvalobs -c \"\\copy $tablename from \'/tmp/$outfilename\' DELIMITER \'$del\'\"");

    # system("./run_copy '$del' $outfilename $tablename");
    delete $ENV{"PGPASSWORD"};

    system("rm /tmp/$outfilename");

    return;
}



sub fimport{
    my $command=shift;
    select(STDOUT);
    print "$command \n";

    #use DBI;
    my $kvpasswd=get_passwd();
    my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs",$kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";

    my $sth= $dbh->prepare("$command");    
    $sth->execute;
    $sth->finish; 
    $dbh->disconnect;

    return;
}



1;
