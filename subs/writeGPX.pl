sub writeGPX{
      use strict;
      use warnings;
    system("perl", "./subs/FIT2GPX/fit2gpx.pl", $_[0]);
}

1;
