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


#		checkname: humid_check
#		signature: obs;X;;|refobs;Xref;;|meta;X_1,X_2,X_3;;
#		qcx: QC2d-4


sub check {
	my @a;
	my ($Q1,$Q2,$Q3);

	Calc_Q1_Q2_Q3(\@X);
	my $UU_Q1 = $Q1;
	my $UU_Q2 = $Q2;	
	my $UU_Q3 = $Q3;

	Calc_Q1_Q2_Q3(\@Xref);
	my $UUref_Q1 = $Q1;
	my $UUref_Q2 = $Q2;	
	my $UUref_Q3 = $Q3;

# sjekk for manglende data
    
	if ($X_missing[0] > 0){
    	# aborter..
		return 0;
	} elsif ($Xref_missing[0] > 0){
    	# aborter..
		return 0;
	}   
	
	my $flag = 1;

	if ($UU_Q1 - $X_1[0] > 7) {
	    $flag = 2;
	} elsif ($X_1[0] - $UU_Q1 > 7) {
    	$flag = 2;
	} elsif ($UU_Q2 - $X_2[0] > 6) {
    	$flag = 2;
	} elsif ($X_2[0] - $UU_Q2 > 6) {
	    $flag = 2;
	} elsif ($UU_Q3 - $X_3[0] > 5) {
    	$flag = 2;
	} elsif ($X_3[0] - $UU_Q3 > 5) {
	    $flag = 2;
	}
	if ($flag == 2) {
		if ($UU_Q1 - $UUref_Q1 > 3.5) {
    		$flag = 2;
		} elsif ($UUref_Q1 - $UU_Q1 > 3.5) {
    		$flag = 2;
		} elsif ($UU_Q2 - $UUref_Q2 > 3) {
    		$flag = 2;
		} elsif ($UUref_Q2 - $UU_Q2 > 3) {
    		$flag = 2;
		} elsif ($UU_Q3 - $UUref_Q3 > 2.5) {
		    $flag = 2;
		} elsif ($UUref_Q3 - $UU_Q3 > 2.5) {
    		$flag = 2;
		} else {
			$flag = 1;
		}
	}

	my @retvector;
	push(@retvector, "X_0_0_flag");
	push(@retvector, $flag);
	my $numout= @retvector; # antall returverdier

	return (@retvector, $numout);

    sub Calc_Q1_Q2_Q3 { 
    	my ($aref)= @_;
    	my $fukt_num = @$aref;
    	Sorter($aref);
    	my @sorted_fukt = @a;
    	
    	my $Q1_num = sprintf("%.0f", ($fukt_num * 0.25 - 1));
    	my $Q2_num = sprintf("%.0f", ($fukt_num * 0.5 - 1));
    	my $Q3_num = sprintf("%.0f", ($fukt_num * 0.75 - 1));
    	
    	$Q1 = $sorted_fukt[$Q1_num];
    	$Q2 = $sorted_fukt[$Q2_num];
    	$Q3 = $sorted_fukt[$Q3_num];
    	return $Q1, $Q2, $Q3; 
    }
    
    sub Sorter {
    	@a=();
    	my ($aref) = @_; #name the parameters
    	my $antall_num = @$aref;
    	my $i = 0;
    	foreach (@$aref) {
    		$a[$i]= $_;
    		$i++;
    	}
    	for ($i=0; $i<$antall_num-1; $i++) {
      		my $min_index = $i+1;
     		for (my $j = $i+2; $j<$antall_num; $j++) {
    			if ($a[$j] < $a[$min_index]) {
    				$min_index = $j;
     			}
      		}
      		if ($a[$i] > $a[$min_index]) {
    			my $temp = $a[$i];
    			$a[$i] = $a[$min_index];
    			$a[$min_index] = $temp;
    		}
    	}
    	return @a;
    }
}
