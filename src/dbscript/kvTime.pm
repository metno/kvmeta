package kvTime;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( isoTime getHour getDate isLeap daysInYear daysInMonth  dayOfYear );

use POSIX;
use strict;
use trim;

my $julianDayZero=1721425;

my @monthLength={
   0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 0 };

my @cum_ml=(
  [ 0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365, 400, 0 ],
  [ 0, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366, 400, 0 ]);

#static inline long lfloor(const long a, const long b) // assumes b positive
#{ return a>=0 ? a/b: (a%b==0)-1-labs(a)/b; }

sub isLeap
{ my $y=shift; return (($y%4==0 && $y%100!=0) || $y%400==0); }


sub daysInYear
{ my $Year=shift;return 365+isLeap($Year); }


sub daysInMonth
{ my $Year=shift;my $Month=shift; return $monthLength[$Month]+($Month==2 && isLeap($Year)); }


sub dayOfYear{
  my $time=shift;
  my ( $Year, $Month, $Day ) = getDate($time);
  return $cum_ml[isLeap($Year)][$Month]+$Day;
}


sub isoTime{
    my( $year, $month, $day, $h, $min, $s )= @_;

    if(!defined($year)){
	#print "not defined year";
	$year=1500;
    }

    if(!defined($month)){
	#print "not defined month";
	$month=1;
    }

    if(!defined($day)){
	#print "not defined day";
	$day=1;
    }

    if(  $month == 0){
	$month=1;
    }

    if(  $day == 0){
	 $day = 1;
    }

    $month= sprintf("%02d",$month);
    $day  = sprintf("%02d",$day);
    $h  = sprintf("%02d",$h);
    $min  = sprintf("%02d",$min);
    $s    = sprintf("%02d",$s);
    #return "$year-$month-$day $h:00:00+00";
    return "$year-$month-$day $h:00:00";
}



sub getDate{
  my ( $isotime )=  @_;

  $isotime= trim($isotime);
  
  if( length($isotime)>0 ){
        my @sline=split /\s+/,$isotime;
        my $len=@sline;
        #print "len=$len \n";
	#print "sline0= $sline[0] \n";
	#print "sline1= $sline[1] \n";
	
        if($len >0){
	
	  my @date=split /-/,$sline[0];
	  my $len=@date;
	  $date[0]= trim_lzero($date[0]);
	  $date[1]= trim_lzero($date[1]);
	  $date[2]= trim_lzero($date[2]);
          return @date;
      }
    }
  return (0,0,0);
}


sub getHour{
  my ( $isotime )=  @_;

  $isotime= trim($isotime);
  
  if( length($isotime)>0 ){
        my @sline=split /\s+/,$isotime;
        my $len=@sline;
        #print "len=$len \n";
	#print "sline0= $sline[0] \n";
	#print "sline1= $sline[1] \n";
	
        if($len>1){
	  #my $tt= $sline[1];
	
	  my @clock=split /:/,$sline[1];
	  my $len=@clock;

	  if($len==3){
	      return trim_lzero($clock[0]);
	  }
	  else{
	      return 1;
	  }
      }
      }

}






1;



