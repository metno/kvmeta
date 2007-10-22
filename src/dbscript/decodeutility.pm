package decodeutility;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( VV HL HS V456 );

use strict;

sub VV{
    my $spVal= shift;
    $spVal= trim($spVal);

    if(!length($spVal)){
       return "";
    }

    my $iVV = $spVal;

        if($iVV==0){
          $spVal=0;
        }elsif($iVV>0 && $iVV<=50){
          $spVal=$iVV*100;
        }elsif($iVV>50 && $iVV<=80){
          $spVal=($iVV-56+6)*1000;
        }elsif($iVV>80 && $iVV<89){
          $spVal=((($iVV-81)*5)+35)*1000;
        }elsif($iVV == 89 ){
          $spVal="75000";
        }else{
          $spVal="";
        }

   return $spVal;
}



sub HL{ 
    my $spVal = shift;
    $spVal = trim($spVal);

    if( length($spVal) !=1 ){
             return "";
    }
    
    if($spVal==0)     { return 0;}
    elsif($spVal==1)  { return 50;}
    elsif($spVal==2)  { return 100;}
    elsif($spVal==3)  { return 200;}
    elsif($spVal==4)  { return 300;}
    elsif($spVal==5)  { return 600;}
    elsif($spVal==6)  { return 1000;}
    elsif($spVal==7)  { return 1500;}
    elsif($spVal==8)  { return 2000;}
    elsif($spVal==9)  { return 2500;}
    elsif($spVal eq "X" )  { return "X";}
  
   return $spVal;
}



sub HS{
   my $spVal = shift;
   $spVal = trim($spVal);

   #print "$spVal \n";

   if(!length($spVal)){
       return "";
    }

   if( !($spVal =~ /\D/) ){ #contains only digits
       if($spVal<= 50){ return ($spVal*30);}
       elsif($spVal >= 56 && $spVal <=80){ return (($spVal - 56)*300 + 1800);}
       elsif($spVal >= 81 && $spVal<89){ return (($spVal - 81)*1500 + 10500);}
       elsif($spVal >= 89){ return 21000;}
   }

   return "";
}
  


sub V456{
    my $spVal=shift;
    $spVal = trim($spVal);

  
    if($spVal==12 )   {return 1;}
    elsif($spVal==11) {return 2;}
    elsif($spVal==10) {return 3;}
    elsif($spVal==16) {return 4;}
    elsif($spVal==15) {return 5;}
    elsif($spVal==14) {return 7;}
    elsif($spVal==13) {return 8;}
    elsif($spVal==17) {return 10;}
    elsif($spVal==18) {return 12;}
    elsif($spVal==19) {return 17;}
    elsif($spVal==20) {return 20;}
    elsif($spVal==21) {return 29;}
    
    return -1;
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


1;




















