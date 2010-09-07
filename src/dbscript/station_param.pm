package station_param;
require Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw( readstfile execute_program );

use POSIX;
use strict;
use File::Copy;
use DBI;
use dbQC;
use Cwd qw(cwd);
use Benchmark;

sub readstfile {

    #my $t0 = new Benchmark;

    my $dbh      = shift;
    my $fromfile = shift;
    my $control  = shift;

    #my $splitter= "\\s+";
    my $splitter = ":";
    print "fromfile= $fromfile \n";

    if ( $control eq "" ) {
        $control = " ";
    }

    open( MYFILE, $fromfile ) or die "Can't open $fromfile: $!\n";

    my $line;
    my $counter = 0;

    my $stationid = 0;
    my $paramid;
    my $level   = 0;
    my $sensor  = '0';
    my $fromday = 1;
    my $today   = 365;
    my $hour    = -1;
    my $qcx;
    my $metadata;
    my $desc_metadata = "";
    my $fromtime      = get_fromtime();

    my $is_metadata = 0;
    my $is_ready    = 0;
    while ( defined( $line = <MYFILE> ) ) {
        $line = trim($line);

        if ( length($line) > 0 ) {
            my $a     = trim($line);
            my @arr   = split /#/, $a;           # skigard er her kommentar
            my $t     = trim( $arr[0] );
            my @words = split /$splitter/, $t;
            my $len   = @words;

            #print $t; print "\n";
            if ( $len > 0 ) {
                my $r = trim( $words[0] );

                #print $r; print "\n";
                if ( $r eq "stationid" ) {
                    if ($is_ready) {
                        if (
                            !execute_program(
                                $dbh,           $fromfile, $control,
                                $stationid,     $paramid,  $level,
                                $sensor,        $fromday,  $today,
                                $hour,          $qcx,      $metadata,
                                $desc_metadata, $fromtime
                            )
                          )
                        {
                            return 0;
                        }
                        $is_ready = 0;
                    }
                    $is_metadata = 0;
                    $stationid = default_trim( $words[1], $stationid );
                    $counter++;
                    print "stationid=$stationid  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "paramid" ) {

                    #print "is_ready=$is_ready\n";
                    if ($is_ready) {
                        if (
                            !execute_program(
                                $dbh,           $fromfile, $control,
                                $stationid,     $paramid,  $level,
                                $sensor,        $fromday,  $today,
                                $hour,          $qcx,      $metadata,
                                $desc_metadata, $fromtime
                            )
                          )
                        {
                            return 0;
                        }
                        $is_ready = 0;
                    }
                    $is_metadata = 0;
                    $paramid     = trim_lzero( $words[1] );
                    $counter++;
                    print "paramid=$paramid  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "level" ) {
                    $is_metadata = 0;
                    $level       = trim( $words[1] );
                    $counter++;
                    print "level=$level  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "fromday" ) {
                    $is_metadata = 0;
                    $fromday     = trim( $words[1] );
                    $counter++;
                    print "fromday=$fromday  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "today" ) {
                    $is_metadata = 0;
                    $today       = trim( $words[1] );
                    $counter++;
                    print "today=$today  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "hour" ) {
                    $is_metadata = 0;
                    $hour        = trim( $words[1] );
                    $counter++;
                    print "hour=$hour  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "qcx" ) {
                    $is_metadata = 0;
                    $qcx         = trim( $words[1] );
                    $counter++;
                    print "qcx=$qcx  counter= $counter";
                    print "\n";
                }
                elsif ( $r eq "metadata" ) {
                    $is_metadata = 1;
                    $is_ready    = 1;
                    $metadata    = trim( $words[1] );
                    $counter++;
                    print "metadata=$metadata  counter= $counter m0";
                    print "\n";
                }
                elsif ( $r eq "" ) {
                    if ( $is_metadata == 1 ) {
                        $metadata .= "\n" . trim( $words[1] );
                        # $metadata = "E\'$metadata\'";
                        print "metadata=$metadata  counter= $counter m1";
                        print "\n";
                    }
                }
                elsif ( $r eq "desc_metadata" ) {
                    $desc_metadata = trim( $words[1] );
                    $counter++;
                    $is_metadata = 0;
                }
                elsif ( $r eq "fromtime" ) {
                    $is_metadata = 0;
                }
                if ( $len == 1 ) {
                    if ( $is_metadata == 1 ) {
                        $metadata .= "\n" . trim( $words[0] );
			# $metadata = "E\'$metadata\'";
                        print "metadata=$metadata  counter= $counter m2";
                        print "\n";
                    }
                }
            }
        }    # else{ $is_ready = 1; }
    }

    close(MYFILE);
    return execute_program(
        $dbh,           $fromfile, $control, $stationid,
        $paramid,       $level,    $sensor,  $fromday,
        $today,         $hour,     $qcx,     $metadata,
        $desc_metadata, $fromtime
    );

}

sub execute_program {
    my (
        $dbh,           $fromfile, $control, $stationid,
        $paramid,       $level,    $sensor,  $fromday,
        $today,         $hour,     $qcx,     $metadata,
        $desc_metadata, $fromtime
      )
      = @_;

    if (
        !legal_values(
            $stationid, $paramid,       $level, $sensor,
            $fromday,   $today,         $hour,  $qcx,
            $metadata,  $desc_metadata, $fromtime
        )
      )
    {
        return 0;
    }

#print "$fromfile,$control, $stationid, $paramid, $level, $sensor, $fromday, $today, $hour, $qcx, $metadata, $desc_metadata, $fromtime \n";
    if ( $control ne "ins" ) {
        outfile(
            $fromfile, $control, $stationid, $paramid,
            $level,    $sensor,  $fromday,   $today,
            $hour,     $qcx,     $metadata,  $desc_metadata,
            $fromtime
        );
    }
    return insert_update_DB(
        $dbh,   $control, $stationid, $paramid,
        $level, $sensor,  $fromday,   $today,
        $hour,  $qcx,     $metadata,  $desc_metadata,
        $fromtime
    );

}

sub legal_values {
    my (
        $stationid, $paramid, $level, $sensor, $fromday,
        $today,     $hour,    $qcx,   $metadata
      )
      = @_;

    # This function assumes that trim functions has been done

    # has_value:
    my @has_value = (
        $stationid, $paramid, $level, $sensor, $fromday,
        $today,     $hour,    $qcx,   $metadata
    );
    foreach (@has_value) {
        if ( !defined )    { print "ERROR nodef has_value\n"; return 0; }
        if ( length == 0 ) { print "ERROR l has_value\n";     return 0; }
    }

    #is_number:
    my @is_number =
      ( $paramid, $stationid, $level, $sensor, $fromday, $today, $hour );
    foreach (@is_number) {
        if (/[^0-9\-]/) { print "ERROR is_number: $_"; return 0; }
    }

    #interval:
    if ( ( $fromday < 1 ) or ( $fromday > 366 ) ) {
        print "ERROR interval fromday=$fromday \n";
        return 0;
    }
    if ( ( $today < 1 ) or ( $today > 366 ) ) {
        print "ERROR interval today=$today \n";
        return 0;
    }
    if ( $hour < -1 or $hour > 23 ) {
        print "ERROR interval hour =$hour \n";
        return 0;
    }

    #konsistens
    if ( $fromday > $today ) { print "ERROR konsistens"; return 0; }

    return 1;
}

sub outfile {
    my (
        $fromfile, $control, $stationid, $paramid,
        $level,    $sensor,  $fromday,   $today,
        $hour,     $qcx,     $metadata,  $desc_metadata,
        $fromtime
      )
      = @_;

#print "$fromfile,$control, $stationid, $paramid, $level, $sensor, $fromday, $today, $hour, $qcx, $metadata, $desc_metadata, $fromtime \n";

    # copy string to file
    my $row =
"$stationid~$paramid~$level~$sensor~$fromday~$today~$hour~$qcx~$metadata~$desc_metadata~$fromtime\n";

    my $remove_from_fromname = 5;
    my $tofile               = $fromfile;
    for ( my $i = $remove_from_fromname ; $i > 0 ; $i-- ) {
        chop($tofile);
    }

    $tofile = '>' . $tofile;
    open( TOFILE, $tofile ) or die "Can't open $tofile: $!\n";
    print TOFILE $row;
    close(TOFILE);

    # copy fromfile from current place to right place in structure
    my $station_param_manual_path     = get_station_param_manual_path();
    my $cvs_station_param_manual_path = get_cvs_station_param_manual_path();
    print "station_param_manual_path= $station_param_manual_path \n";
    print "cvs_station_param_manual_path= $cvs_station_param_manual_path \n";

    my @med = split /-/, $qcx;
    my $mQcx;
    if ( $med[0] eq "QC2d" ) { $mQcx = "QC2d"; }
    elsif ( $med[0] eq "QC1" ) {
        $mQcx = "$med[0]-$med[1]";
    }    # if $med[1] eq 2,6,rest

    print "mQcx=$mQcx \n";

    my @paths = ( $station_param_manual_path, $cvs_station_param_manual_path );
    my @subpaths = qw( QC2d QC1-2 QC1-6 QC1_rest );

    my $dir =
      cwd(); #NB! Denne sammenligningen holder ikke, må sammenligne med fromfile
             #print "dir=$dir \n";
    my $fromdir = $fromfile;
    $fromdir =~ s/\/[\w.]*$//;

    #print "fromdir=$fromdir \n";
    my $counter = 0;
    foreach my $path (@paths) {

        my $katalog = "driftskatalogen";
        if ( $counter == 1 ) { $katalog = "CVS"; }
        $counter++;

        my %tpaths;
        foreach my $subpath (@subpaths) {
            my $tpath = "${path}/$subpath";

            #print  "tpath=$tpath\n";
            $tpaths{$tpath} = $subpath;
        }

        if ( !exists $tpaths{$fromdir} ) {
            print "copy $fromfile ${path}/$mQcx \n";

            #copy( $fromfile, "${path}/$mQcx" );
        }
        else {
            print "nocopy $fromfile ${path}/$mQcx   \n";
            my $subpath = $tpaths{$fromdir};

            #print "subpath=$subpath\n";
            #print "mQcx= $mQcx\n";
            if ( $mQcx eq $subpath ) {
                print "leser fromfile fra $katalog katalogen \n";
            }
        }

    }    #foreach my $path ( @paths )
}

#sub insert_DB{
#  my ( $dbh,$control, $stationid, $paramid, $level, $sensor, $fromday, $today, $hour, $qcx, $metadata, $desc_metadata, $fromtime ) = @_;
#  my $t0 = new Benchmark;
#  my $sth = $dbh->prepare("delete from station_param where stationid=$stationid AND paramid=$paramid AND level=$level AND \
#                                  fromday=$fromday AND today=$today AND hour=$hour AND \
#                                  qcx like '$qcx' AND fromtime = '$fromtime'");
#  $sth->execute;
#  $sth->finish;
#  $sth = $dbh->prepare("INSERT INTO station_param VALUES('$stationid','$paramid','$level','$sensor','$fromday','$today',\
#                                                  '$hour','$qcx','$metadata','$desc_metadata','$fromtime')");
#  if( ! $sth->execute ){ print "noe er galt!";}
#  $sth->finish;
#  return;
#}

sub insert_update_DB {
    my (
        $dbh,   $control, $stationid, $paramid,
        $level, $sensor,  $fromday,   $today,
        $hour,  $qcx,     $metadata,  $desc_metadata,
        $fromtime
      )
      = @_;

    #my $metadataE="E" . "'" . $metadata . "'";
    #print "metadataE=$metadataE \n";
    #$metadata=$metadataE;

    #################
    my $sth;
    my @station_param = ();
    eval {
        $sth = $dbh->prepare(
            "SELECT sensor FROM station_param \
                           WHERE  stationid=? AND paramid=? AND level=? AND \
                                  fromday=? AND today=? AND hour=? AND \
                                  qcx=? AND fromtime=?"
        );

        $sth->execute($stationid,$paramid,$level,$fromday,$today,$hour,$qcx,$fromtime);

        my @row = ();

        while ( @row = $sth->fetchrow_array ) {
            my $val = $row[0];
            push( @station_param, $val );
        }
        $sth->finish;
    };
    warn $@ if $@;

    if ($@) { print "tt0=$@"; return 0; }

    my $len_station_param = @station_param;

    if ( $len_station_param > 0 ) {
        print "length of  station_param is $len_station_param\n";
        my $ref;
        foreach (@station_param) {
            print "station_param: sensor = $_ \n";
        }
    }

    #my $tstart = new Benchmark;
    #my $tdstart = timediff($tstart, $t0);
    #print "update_DB::select control took:",timestr($tdstart),"\n";

    if ( $len_station_param > 0 ) {
        print "length of  station_param is $len_station_param\n";
        foreach (@station_param) {
            if ( $control eq "ins" || $control eq 'R' ) {
                if ( $_ eq $sensor ) {
                    eval {
                        print
"1: $stationid, $paramid, $qcx, $metadata: Denne raden i station_param tabellen blir naa replaced \n";
                        $sth = $dbh->prepare(
                            "UPDATE station_param \
                                  SET   metadata = E'$metadata', desc_metadata = '$desc_metadata' \
                                  WHERE stationid=$stationid AND paramid=$paramid AND level=$level AND \
                                        fromday=$fromday AND today=$today AND hour=$hour AND \
                                        qcx = '$qcx' AND fromtime = '$fromtime'"
                        );
                        $sth->execute;
                        $sth->finish;
                    };
                    if ($@) { print "tt=$@"; return 0; }
                    return 1;
                }
                else {
                    eval {
                        print
"2: $stationid, $paramid, $qcx, $metadata: Denne raden i station_param tabellen blir naa replaced \n";
                        $sth = $dbh->prepare(
                            "UPDATE station_param \
                                  SET   sensor = '$sensor', \
                                        metadata = E'$metadata', desc_metadata = '$desc_metadata' \
                                  WHERE stationid=$stationid AND paramid=$paramid AND level=$level AND \
                                        fromday=$fromday AND today=$today AND hour=$hour AND \
                                        qcx = '$qcx' AND fromtime = '$fromtime'"
                        );
                        $sth->execute;
                        $sth->finish;
                    };
                    if ($@) { print "tt=$@"; return 0; }
                    return 1;
                }
            }    # end if( $control eq 'R' )
            else {
                print
"$stationid, $paramid, $qcx: Denne raden har verdier i fra for; ingen oppdateringer \n";
                return 1;
            }
        }
    }

    ########################

#$stationid, $paramid, $level, $sensor, $fromday, $today, $qcx, $metadata, $desc_metadata, $fromtime
    print
"3: $stationid, $paramid, $qcx, $metadata: denne raden blir naa lagt til \n";
    eval {
        $sth = $dbh->prepare(
        "INSERT INTO station_param VALUES('$stationid','$paramid','$level','$sensor','$fromday','$today',\
                                                  '$hour','$qcx',E'$metadata','$desc_metadata','$fromtime')"
        );
        $sth->execute;
	#    "INSERT INTO station_param VALUES(?,?,?,?,?,?,?,?,?,?,?)"
        #);
        #$sth->execute($stationid,$paramid,$level,$sensor,$fromday,$today,$hour,$qcx,"E\'$metadata\'",$desc_metadata,$fromtime);
	# Fungerer ikke - tilbake til den gode gamle ...





        $sth->finish;
    };
    if ($@) { print "tt=$@"; return 0; }
    return 1;
}

1;
