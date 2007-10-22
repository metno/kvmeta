package trim;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(trim default_trim default_trim_lzero trim_lzero );


sub trim{
    my  $line = shift;
    if(defined($line)){
        $line =~ s/^\s*//; #Her utfores en ltrim
        $line =~ s/\s*$//; #Her utfores en rtrim
        return $line;
    }
    return "";
} 


sub default_trim{
    my ($val, $def_val) = @_;
    
    my $temp=trim($val);
    if( $temp eq "" ){ return trim($def_val);}
    else { return $temp;}
}


sub default_trim_lzero{
    my ($val, $def_val) = @_;
    
    my $temp=trim_lzero($val);
    if( $temp eq "" ){ return trim_lzero($def_val);}
    else { return $temp;}
}


sub trim_lzero{
    my  $line = shift;
    if(defined($line)){
	my $tline=trim($line);
        if( length($tline) > 0 ){
           $tline =~ s/^0*//; #Her utfores en ltrim
           if(length($tline) == 0){
	       return 0;
	   }
           #print "$tline \n";
           return $tline;
       }
    }
    return "";
} 



1;






