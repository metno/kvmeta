package TIME_export;
require Exporter;#use Exporter ();
@ISA = qw(Exporter);
@EXPORT = qw( simple subdir );

use POSIX;
use strict;


sub simple{
    my $criteria = shift;
    my $path     = shift;

    print "criteria= $criteria \n";
    print "path= $path \n";
    #my $cr="*.pl";
    
    my $f;

    foreach $f (< $criteria >){
        print $f; 
        my $min = -M $f;
        my $tt= " days since last changed: " . $min;
 
        my $file = $path . "/$f";
  
        if( -e $file ){
            if( -M $f <= -M $file ){
                print "$tt TO dir ";
                system("cp $f $file");
            }
        }else{
            print "$tt new TO dir ";
            system("cp $f $file");
        }
        print "\n";
    
    
    }
    return;
}


sub subdir{
    my( $criteria, $path, @subd )= @_;    

    my $sub;  
    foreach $sub (@subd){  

	my $path_sub = $path . "/$sub";
	if( -e $path_sub ){
	    print "Exist $path_sub \n";
	}else{
	    system("mkdir $path_sub");
	    print "Created $path_sub \n";
	}

	chdir $sub;
	my $f;
	foreach $f (< $criteria >){
	     print $f; 
	     my $min = -M $f;
	     my $tt= " days since last changed: " . $min;
 
	     my $file = $path . "/$sub" . "/$f";
  
	     if( -e $file ){
		 if( -M $f <= -M $file ){
		     print "$tt TO dir ";
		     system("cp $f $file");
		 }
	     }else{
		 print "$tt new TO dir ";
		 system("cp $f $file");
	     }
	     print "\n";
	 }

      chdir "..";
    }
return;
}


1;

