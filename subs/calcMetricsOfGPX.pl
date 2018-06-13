#!/usr/bin/perl
sub calcElevationGain{
    use warnings;
    use strict;
    
    my $elevationthreshold = 0.75;     #in m
    
    my @elevations = @_;
    my $elevationGain = 0;
    my $elevationGainINV = 0;
    my $direction = 1;  # 1 = ascending; -1 = descending
    my $newDirection = 0;    # distance to current expected direction
    
    my $min = $elevations[0];
    my $max = $elevations[0];
    
    foreach my $ele (@elevations) {
        if ($direction == 1){
            if ($ele > $max){
                $max = $ele;
            }elsif ($ele < $max) {
                if ($max-$ele >= $elevationthreshold){
                    $elevationGain = $elevationGain + ($max - $min);
                    $min = $ele;
                    $direction = -1;
                }
            }
        }elsif ($direction == -1) {
            if ($ele < $min) {
                $min = $ele;
            }elsif ($ele > $min) {
                if ($ele - $min > $elevationthreshold){
                    $elevationGainINV = $elevationGainINV + ($max - $min);
                    $max = $ele;
                    $direction = 1;
                }
            }
        }
    }
    
    return int($elevationGain);
}

sub calcDistance{ 
    use warnings;
    use strict;
    require "./subs/calcDistance.pl";
    
    our @lats;
    our @lons;
    
    my $distance = 0;
    
    for (my $ind =1; $ind <= $#lons; $ind++){
        $distance = $distance+distance($lats[$ind-1], $lons[$ind-1], $lats[$ind], $lons[$ind], "K"); 
    }
    
    return int($distance+0.5);
}
1;