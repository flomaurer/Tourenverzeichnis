#!/usr/bin/perl
sub secondstotimestringhhmmss{
      use strict;
      use warnings;
  my $x = $_[0];
  my $string = join(':',sprintf ("%02d",int($x/60/60)),sprintf ("%02d",int(($x-int($x/60/60)*(60*60))/60)),sprintf ("%02d",int($x-int($x/60/60)*(60*60)-int(($x-int($x/60/60)*(60*60))/60)*60)));
  return $string;
}

sub secondstotimestringhhmm{
      use strict;
      use warnings;
  my $x = $_[0];
  my $string = join(':',sprintf ("%02d",int($x/60/60)),sprintf ("%02d",int(($x-int($x/60/60)*(60*60))/60)));
  return $string;
}
1;