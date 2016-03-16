#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id: checks_auto 5372 2015-07-02 17:32:30Z terjeer $
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

# This is the speed optimised version of insert_update_delete_table.pl

use DBI;
# use dbQC;
use strict;
# use trim;

my $len=@ARGV;
if( $len < 5 ){
    die "to few arguments, the arguments are values of: host port tablename filename unique/primary";
}
# host=localhost;port=5432'
my $host=$ARGV[0];
my $port=$ARGV[1];

print "host=$host \n";
print "port=$port \n";

my $kvpasswd=get_passwd();
my $dbh = DBI->connect("dbi:Pg:dbname=kvalobs;host=$host;port=$port","kvalobs",$kvpasswd,{RaiseError => 1}) ||
        die "Connect failed: $DBI::errstr";

my $line;

my $insert=0;

my $tablename=$ARGV[2];
my $unique_or_primary=$ARGV[4];
my $var="indis" . $unique_or_primary;

# -- https://wiki.postgresql.org/wiki/Retrieve_primary_key_columns
# i.indisprimary OR i.indisunique

my $sth = $dbh->prepare("SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type   \
FROM   pg_index i \
JOIN   pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) \
WHERE  i.indrelid = '$tablename'::regclass AND i.$var");

$sth->execute();
my @pkey=();
while ( my @row = $sth->fetchrow_array) {
    push( @pkey, $row[0] );
}

print join(',',@pkey) , "\n";

###############

# -- http://dba.stackexchange.com/questions/22362/how-do-i-list-all-columns-for-a-specified-table
$sth = $dbh->prepare("
SELECT attrelid::regclass, attnum, attname, format_type(atttypid, atttypmod) AS data_type  \
FROM   pg_attribute  \
WHERE  attrelid = '$tablename'::regclass \ 
AND    attnum > 0 \  
AND    NOT attisdropped  \
ORDER  BY attnum");

$sth->execute();
my @col=();
my %is_boolean;
while ( my @row = $sth->fetchrow_array) {
    push( @col, $row[2] );
    if( $row[3] eq "boolean" ){
	$is_boolean{$row[2]}=$row[1];
    }   
}

print join(',',@pkey) , "\n";
print join(',',@col) , "\n";

my %pkey;
my %nkey;
my %hcol;

foreach my $key( @pkey ){
    $pkey{$key}=" ";
}
my @pkeyindx;
for( my $i=0; $i< scalar(@col); $i++ ){
    if( exists $pkey{$col[$i]} ){
	$pkey{$col[$i]} = $i;
	push( @pkeyindx, $i );
    }else{
	$nkey{$col[$i]} = $i;
    }
    $hcol{$col[$i]}= $i;
}

print "############### \n";
foreach my $key ( keys %pkey){
    print "$key : $pkey{$key} \n";
} 

print "############### \n";

#########################
my @nkeyindx;
my @nkeyarr;
my %nkeyarr_boolean;

my $k=0;
foreach my $key ( keys %nkey ){
    push(@nkeyindx,$nkey{$key});
    push(@nkeyarr,$key);
    if( exists $is_boolean{$key} ){
	$nkeyarr_boolean{$k}=$key;
    }
    $k++;
}
my $nkeystr=join(",", @nkeyarr);
my $nkeyupdate=join(" = ?, ", @nkeyarr); $nkeyupdate .= " = ?";

print "nkeystr=$nkeystr \n";
print "nkeyupdate=$nkeyupdate \n";
print join(",",@nkeyindx), "\n";

my %hpval;

  my  ( @sql_primary_arr );
  for my $col ( keys %pkey ){ 
      push @sql_primary_arr, "$col = ?";  
  }
  my $sql_clause = join(" AND ", @sql_primary_arr);
  $sth = $dbh->prepare(qq{
       SELECT count(*) FROM $tablename WHERE $sql_clause
  });
  #$sth->execute(@sql_bind);	 
  print "SELECT count(*) FROM $tablename WHERE $sql_clause \n";

### need for UPDATE ?
my $sth_nkeystr = $dbh->prepare(qq{
		  SELECT $nkeystr FROM $tablename WHERE $sql_clause
		  });

#### UPDATE
  my $sth_update = $dbh->prepare(qq{
		     	  UPDATE $tablename SET $nkeyupdate WHERE $sql_clause
  });

### INSERT
  my $qmark = join "," => ("?") x @col;
  # print $qmark;
  my $sth_insert = $dbh->prepare("insert into $tablename values($qmark)");

#######################################################################
    open(MYFILE,$ARGV[3] ) or die "Can't open $ARGV[3] $!\n";#datafil
    while( defined($line=<MYFILE>) ){
        my $line2=trim($line);  
	if( ! length($line2)){ print "ERROR empty line \n"; next;}

        my @a;
        my $seq='\|';
        if( $line=~ $seq ){ 
                     # exception (?<!foo)bar
                     # "(?<!pattern)"
                     # A zero-width negative look-behind assertion.  For example
                     # "/(?<!bar)foo/" matches any occurrence of "foo" that does
                     # not follow "bar".  Works only for fixed-width look-
                     # behind.
	   @a=split /(?<!\\)\|/, $line; # titte mer på dette
        }else{
	   @a=split /\|/, $line;
        }

        my $c=0;
        my @b;
        #@b=split /\|/, $line;
        #my $lenb=@b;
        #print "lenb=$lenb \n";

        # my $lena=@a;
        # print "lena=$lena \n";

       foreach my $elem (@a){
	   $elem=trim($elem);
	   if( $elem=~ $seq ){
	       $elem=~ s/\\\|/\|/;
           } 
	   if( (not defined $elem) or ($elem eq "") or ($elem eq '\N') ){
	       $a[$c]=undef;
	       $b[$c]="NULL";
	   }else{
	       $a[$c]=$elem;
	       $b[$c]=$elem; 
	   }
	   $c++;
       }

       print join(',',@b), "\n";	
      
################################## 
## delete :: This puts all the keys into the hash $hpval
	my @pval_a;
	foreach my $i (@pkeyindx){ # This @pkeyindx is sorted from lowest to heighest order of index for primary key
            my $val=$a[$i];
            if( ! defined $a[$i] ){
		$val='NULL';
	    }
	    push(@pval_a, $val);
        }
	my $pval_a_str=join(',',@pval_a);
        # print "EXTRA DELETED $pval_a_str END"; 	
	$hpval{$pval_a_str}=1;

#################################
   
	  my ( @sql_bind );
	  for my $col ( keys %pkey ){
	      push @sql_bind, $a[$pkey{$col}];
	  }
          $sth->execute(@sql_bind);
	 
	#print "SELECT count(*) FROM $tablename WHERE $sql_clause \n";
	  my $exist=2;
	  if (my @row = $sth->fetchrow() ){
	     if( $row[0]> 0 ){
		$exist=1;
	     }elsif(  $row[0]> 1 ){
		$exist=3;
                print " MULTIPLE KEYS";
                next;
	     }else{
		$exist=2;
	     }
	  }else{
	    $exist=0;
	    print " DATABASE ERROR";
            next;
	  }
	  $sth->finish;

	  print "EXIST $exist \n";

	  if( $exist==1 ){ 
	      #my $nkeystr="comment,fromtime,op,tbtime";
              #my @nkeyindx=(2,3,4,5);
	     
	      $sth_nkeystr->execute(@sql_bind);

              print "SELECT $nkeystr FROM $tablename WHERE $sql_clause \n";

	      if ( my @row = $sth_nkeystr->fetchrow() ){
		  my $k=0;
		  foreach my $elem (@row){
		      if( not defined $elem ){
			  $row[$k]="NULL";
		      }
		      $row[$k]=trim($row[$k]);
                      $k++;
		  }
		  foreach my $indx ( keys %nkeyarr_boolean ){
                      #print "\n";  
                      #print "HHH $indx,$row[$indx] HHH  \n"; 
		      if( $row[$indx] eq '1' ){
			  $row[$indx]= 't';
                      }
		      elsif( $row[$indx] eq '0' ){
			  $row[$indx]= 'f';
                      }
                  }
		  my $old=join(",",@row);
                  my $new;
		  foreach my $indx (@nkeyindx){
		      if( defined $new ){
			  $new =  $new . $b[$indx] . ",";
		      }else{
			  print "indx=$indx \n";
                          if( defined $b[$indx] ){
			      $new = $b[$indx] . ",";
			  }else{
			      print "ERROR not defined b with indx $indx";
                          } 
		      }
		  };chop $new;
		   # print "OLD $old \n";
		   # print "NEW $new \n";
		 
		  if( $old ne $new ){ # compare oldvalue in db with new value from file
                      print "OLD $old \n";
		      print "NEW $new \n";
                      if( ( exists $hcol{fromtime} ) and ( exists $hcol{totime} ) ){  
                          my $index_fromtime=$hcol{fromtime};
			  my $index_totime=$hcol{totime};
                          if( ( defined $a[$index_fromtime] ) and ( defined $a[$index_totime] ) ){
                              if( $a[$index_fromtime] eq $a[$index_totime] ){
                                  print "EQUAL INPUT $a[$index_fromtime] :: $a[$index_totime] \n";
			          next;
			      }
			  }
		      }
		      print " UPDATE \n";
		      
		      my @sql_bind_nkey;
		      foreach my $indx (@nkeyindx){
			  push( @sql_bind_nkey, $a[$indx] );
		      }
		      # my $sql_clause er definert over
		      my @sql_bind_update=( @sql_bind_nkey, @sql_bind );
                      #derimot så får vi en ny @sql_bind som omfatter alle
		       
		     
		      $sth_update->execute(@sql_bind_update);
		      $sth_update->finish;
		  }else{
		      	print " UNCHANGED";
		  }
	      
	      }else{
		  $exist=0;
		  print " DATABASE ERROR";$sth_nkeystr->finish;next;
	      }
	      $sth_nkeystr->finish;
	  }elsif($exist==2) {
	    print " INSERT";
	    $sth_insert->execute(@a);
	    $sth_insert->finish;
	  }
       

    print "\n";
} # end  while( defined($line=<MYFILE>) ){

########################################
# delete

if( defined $ARGV[5] ){
    print "ARGV5 $ARGV[5] \n";
    if( $ARGV[5] eq "nd" ){
	exit 0;
    }
}

  # my  @sql_primary_arr=();
  # for my $col ( sort keys %pkey ){
  #    push @sql_primary_arr, "$col = ?";
  # }
  # my $sql_clause = join(" AND ", @sql_primary_arr);
  # my $sth_delete = $dbh->prepare(qq{
  #              delete FROM $tablename WHERE $sql_clause
  #              });

  $sth = $dbh->prepare(qq{
          SELECT * FROM $tablename
       });
  $sth->execute();
	 
  while(my @row = $sth->fetchrow()){
        my @pval_row;
	foreach my $i (@pkeyindx){
	    my $val=$row[$i];
            if( ! defined $row[$i] ){
		$val='NULL';
	    }
	    push(@pval_row, $val);
	    # push(@pval_row, $row[$i])
        }
        my $pval_row_str=join(',',@pval_row);
################
#        my @pval_a;
#	foreach my $i (@pkeyindx){ # This @pkeyindx is sorted from lowest to heighest order of index for primary key
#            my $val=$a[$i];
#            if( ! defined $a[$i] ){
#		$val='NULL';
#	    }
#	    push(@pval_a, $val);
#        }
#	my $pval_a_str=join(',',@pval_a);
###############

        if( ! exists $hpval{$pval_row_str} ){
            ####### 
	    #for my $col ( sort keys %pkey ){
	    #	push(@sql_bind, $row[$pkey{$col}]);
	    #}
	    # my $sql_clause = join(" AND ", @sql_primary_arr);
           

###################

           my  ( @sql_primary_arr, @sql_bind );
           for my $col ( keys %pkey ){
	      if( defined $row[$pkey{$col}] ){ 
		  push @sql_primary_arr, "$col = ?";
		  push @sql_bind, $row[$pkey{$col}];
	      }else{
		  push @sql_primary_arr, "$col is NULL";
	      }
	   }
	   my $sql_clause = join(" AND ", @sql_primary_arr);

	   # my $c=0;
	   # foreach my $elem (@row){
	   #	$elem=trim($elem);
	   #	if( (not defined $elem) or ($elem eq "") or ($elem eq '\N') ){
	   #	    $row[$c]="NULL";
	   #	}else{
	   #	    $row[$c]=$elem;
	   #	}
	   #	$c++;
	   # }
	   # my $tableline=join(',',@row);
	   print "EXTRA TO BE DELETED $pval_row_str :: delete FROM $tablename WHERE $sql_clause :: ";

	   my $sth_delete = $dbh->prepare(qq{
                 delete FROM $tablename WHERE $sql_clause
           });

################

	    print join(',',@sql_bind), "\n";
            $sth_delete->execute(@sql_bind)
	}
	    
  }

  $sth->finish;
########################################

sub nfkey_error{
    my ($nfref,$aref)=@_;
    my @a=@{$aref};
    my %nfkey=%{$nfref};

    foreach my $tablename ( keys %nfkey ){
	#print " $tablename ERROR\n";
	#if( ! defined $f{$tablename} ){ print "$tablename er ikke definert i scriptet EMPTYERROR\n";}
        my $indx=$nfkey{$tablename};
        if( ! defined $a[$indx] ){ return 1; }
	# if( ! defined $f{$tablename}->{$a[$indx]} ){ print " $tablename ERROR\n"; return 0;}
    }	
    return 1;
}


sub fill{
    my ( $id,$name,$table )=@_;
    my $sth = $dbh->prepare("select  $id, $name from $table");
    $sth->execute;
    my %s;

    while (my @row = $sth->fetchrow_array) {
        if( ! defined $row[1]){
          $row[1]="";
         }
        $s{$row[0]}=$row[1];
    }
    $sth->finish;

    return \%s;
}


sub get_passwd{
    my $home;
    if( defined( $home=$ENV{"HOME"}) ){
        my $home=trim($home);
        my $kvpasswd= $home . "/.kvpasswd";
        open(MYFILE,$kvpasswd ) or return "";
        my $line;
        while( defined($line=<MYFILE>) ){
            $line= trim($line);
            if( length($line)>0 ){
                my @sline=split /\s+/,$line;
                my $len=@sline;
                if($len>1){
                    if( defined($sline[1]) ){
                        return trim($sline[1]);
                    }
                }else{
                    return "";
                }
            }
        }
        return "";
    }
}

sub trim{
    my  $line = shift;
    if(defined($line)){
        $line =~ s/^\s*//; #Her utfores en ltrim
        $line =~ s/\s*$//; #Her utfores en rtrim
        return $line;
    }
    return "";
}
