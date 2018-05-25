#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

sub timestringtoseconds{   
  use DateTime;
  my $dt = $_[0];
  
  my ($y,$m,$d, $h, $min, $sec) = $dt =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2}).([0-9]{2}).([0-9]{2}).([0-9]{2})/;
  $dt = DateTime->new(
     year      => $y,
     month     => $m,
     day       => $d,
     hour      => $h,
     minute    => $min,
     second    => $sec,
  );

  my $seconds = $dt->epoch;
  
  return $seconds;
}
1;