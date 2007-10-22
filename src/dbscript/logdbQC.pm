package logdbQC;

use POSIX;
use strict;


sub new{
    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->{"param_zero"}={};
    $self->{"not_exist_station"}={};
    $self->{"not_exist_param"}={};
    $self->{"not_exist_obs_pgm"}={};
    $self->{"duplikate_rader"}=[];

    return $self;
}



sub print_log{
  my $self=shift; 
  my $QCX=shift;

  
  
   my $r_param_zero        = $self->{"param_zero"};
   my $r_not_exist_station = $self->{"not_exist_station"};
   my $r_not_exist_param   = $self->{"not_exist_param"};
   my $r_not_exist_obs_pgm = $self->{"not_exist_obs_pgm"};
   my $r_duplikate_rader = $self->{"duplikate_rader"};


   my %param_zero=  %{$r_param_zero};


#LOG

my $key;

my $dupfile=">duplikater".$QCX;
open(MYDUP,$dupfile) or die "Can't open $dupfile: $!\n";
select(MYDUP);

foreach $key (@{$r_duplikate_rader}) {
    print "$key\n";
}

close(MYDUP);

my $logfile=">log".$QCX;
  open(MYLOG,$logfile) or die "Can't open $logfile: $!\n";
  select(MYLOG);


print "listing av parametere kategorisert etter hvorvidt det eksisterer stationid=0 for den parameteren\n";
   
      foreach $key (keys (%param_zero)) {
	  print "$key : $param_zero{$key} \n";
      }

print "listing av parametere som ikke eksisterer i tabellen param: \n";
foreach $key (keys (%{$r_not_exist_param})) {
    print "paramid=$key \n";
}

print "listing av stasjoner som ikke eksisterer i tabellen station: \n";
foreach $key (keys (%{$r_not_exist_station})) {
    print "stationid=$key \n";
}   

print "listing av stationid, paramid kombinasjoner som finnes for metadataene og som ikke finnes i tabellen obs_pgm: \n";
foreach $key (keys (%{$r_not_exist_obs_pgm})) {
    print "obs_pgm=$key \n";
}

close(MYLOG);

}



sub not_auto{
    my ($self, $stationid, $paramid, $month, $r_param, $r_station, $r_obs_pgm, $r_station_param ) = @_;
    #print "stationid=$stationid paramid=$paramid month=$month \n";
      if( !exists $r_param->{"$paramid"} ) { $self->{"not_exist_param"}->{$paramid}=1;}
      
      else{
	        my $r_param_zero = $self->{"param_zero"};
		if( $stationid==0){
                    #print "STATIONID paramid=$paramid\n ";
                    if( !exists $r_param_zero->{$paramid} ){
	      	         $r_param_zero->{$paramid}=1;
		    }else{
		       if( $r_param_zero->{$paramid} != 1 ){
			   $r_param_zero->{$paramid} = 3;
		       }
		    }
		}else{
		    if( !exists $r_station->{"$stationid"} ){
                        $self->{"not_exist_station"}->{"$stationid"}=1;
			#print "NOT EXISTS stationid=$stationid \n ";
		    }else{			
		        if( !exists $r_param_zero->{$paramid} ){
	      	             $r_param_zero->{$paramid}=2;
		        }else{
		             if( $r_param_zero->{$paramid} == 1 ){
			         $r_param_zero->{$paramid} = 3;
		             }
			}
                
		        if( !exists  $r_obs_pgm->{"$stationid,$paramid"} ){
			    $self->{"not_exist_obs_pgm"}->{"$stationid,$paramid"}=1;
			    #print "NOT EXISTS m_obs_pgm: $stationid,$paramid \n";   
		        }
		    }
		}
		$self->{"param_zero"} = $r_param_zero;
	    }

    my $elem="";
         if( $month !=0 ){
	      if( exists $r_station_param->{"$stationid,$paramid,$month"} ){	  
                    $elem= "DUPLIKATE rader: stationid=$stationid paramid=$paramid month=$month";
		    #my $r_duplikate_rader = @$self->{"duplikate_rader"};
		    #push( @{$self->{"duplikate_rader"}} , $elem );
                }
	  }
	 else{
	      if( exists $r_station_param->{"$stationid,$paramid"} ){
                    $elem= "DUPLIKATE rader: stationid=$stationid paramid=$paramid\n";
		    #push( @{$self->{"duplikate_rader"}}, $elem );
                }
	  }

    if( $elem ne ""){
	push( @{$self->{"duplikate_rader"}} , $elem );
    }

    return;
}


1;















