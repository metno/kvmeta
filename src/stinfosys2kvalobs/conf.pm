package conf;

use strict;
use trim;

# This module is a parser of a simle config file on the format KEY=VALUE
# written by Terje Reite@met.no

sub new {
  my $class = shift;
  my $confname=shift;		#st-info-sys.conf
  my $confenv=shift;		#"ST_INFO_SYS"
  my $Conf="";

  if ( defined( $ENV{$confenv} ) ) {
    $Conf = $ENV{$confenv} . "/etc/$confname";
  } else {
    $Conf = $ENV{"HOME"} . "/etc/$confname";
  }

  my $self = parse_config_file($Conf);
  bless $self, $class;

  return $self;
}


sub get{
  my $self=shift;
  my $key=shift;
  return  $self->{"$key"};
}


sub parse_config_file{
  my $Conf=shift;
  open(MYFILE, $Conf) or die "Can't open $Conf $!\n";
  my %h;

  my $line;
  while ( defined($line=<MYFILE>) ) {
    $line= trim($line);
    if ( length($line)>0 ) {
      my @sline=split /=/,$line;
      my $len=@sline;
      if ($len>1) {
	if ( defined($sline[1]) && defined($sline[0]) ) {
	  $sline[0]=trim($sline[0]);$sline[1]=trim($sline[1]);
	  $h{$sline[0]}=$sline[1];
	}
      }
    }
  }

  return \%h;
}

1;
