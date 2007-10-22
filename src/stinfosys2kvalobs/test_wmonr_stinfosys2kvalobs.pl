use wmonr_stinfosys2kvalobs;

foreach  my $stationid ( keys %stationid_fromtime ){
  foreach  my $fromtime ( keys %{$stationid_fromtime{$stationid}} ){
     print "$stationid $fromtime= $stationid_fromtime{$stationid}{$fromtime}\n";
   }
}
