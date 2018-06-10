sub downloadosmtracktile{
      use strict;
      use warnings;
# download tile: input: lat(from,to), Lon(from,to), preview?
use 5.006001;
use strict;
use warnings;
use Geo::OSM::Tiles qw( :all );
use LWP::Simple;
use File::Path;
use File::Basename;
use Cwd qw(cwd);
use Getopt::Long;
use Math::Trig;
use POSIX ();

our $linkrgoffs = 350.0;

our $lwpua = LWP::UserAgent->new;
$lwpua->env_proxy;

my $zoommin=0;
my $zoommax=17;

# beacause of tex supported range
my $latmin = $_[0]/100;
my $latmax = $_[1]/100;
my $lonmin = $_[2]/100;
my $lonmax = $_[3]/100;

my ($south, $west, $north, $east);

my $zoom;
my $out;

my $plot='';
my @positions;
# proove how many tiles are needed for zoom level
  for ($zoom=$zoommax; $zoom>=$zoommin; $zoom=$zoom-1) {
    
    my $txmin = floor(($lonmin+180)/360*2**$zoom);
    my $txmax = floor(($lonmax+180)/360*2**$zoom);
    my $tymax = floor((1-(log(tan($latmin*pi/180)+1/cos($latmin*pi/180)))/pi)*2**($zoom-1));
    my $tymin = floor((1-(log(tan($latmax*pi/180)+1/cos($latmax*pi/180)))/pi)*2**($zoom-1));

    my $ntx = $txmax - $txmin + 1;
    my $nty = $tymax - $tymin + 1;
    #printf "Download %d (%d x %d) tiles for zoom level %d ...\n",
    #printf "x: $txmax - $txmin \n";
    #printf "y: $tymax - $tymin \n";
    
    if (($ntx<=5 && $nty <= 5 && $_[4] != 1) || ($ntx<=3 && $nty <= 3)) {       # different resolution for mappreview and final PDF
      my $n = 2**$zoom;
      my $x = $txmin;
      my $y = $tymin;
      my $xx= $txmin;
      my $yy= $tymin;
      while ($x <= $txmax){                                                        # besser mit forloop
        $yy= $tymin;
        $y= $tymin;
        my @ipositions;
        while ($y <= $tymax){
          my @iiposition;
          our $G_MAPS_PATH;
          my $save=join('','$G_MAPS_PATH',$zoom,'_',$xx,'_',$yy,'.png');
          # prove if tile exists
          if (not -f $save){
#            printf "--- DOWNLOAD needed --- \n";
	          $out=downloadtile($lwpua, $xx, $yy, $zoom, $save);
          } else
          {
            #printf "no Download needed \n";
          }
          $west=$xx/$n*360-180;
          $north=atan(sinh(pi*(1-2*$yy/$n)))*180/pi;
          $east=($xx+1)/$n*360-180;
          $south=atan(sinh(pi*(1-2*($yy+1)/$n)))*180/pi;
          $plot=join('',$plot,'\addplot[] graphics[xmin=',$west*100,',ymin=',$south*100,',xmax=',$east*100,',ymax=',$north*100,'] {',$save,'};');
          @iiposition=($west, $south, $save, $east, $north);
          $ipositions[$y-$tymin]= [@iiposition];
          $yy=$yy+1;
          $y=$y+1;
        }
        $positions[$x-$txmin] = [@ipositions];
        $xx=$xx+1;  
        $x=$x+1;  
      }
      last;
	}    ;

  
  }
  if ($_[4] == 1) {
    return @positions;
  }else{
    return $plot;
  }
}
sub downloadtile
{
      use strict;
      use warnings;
    
    my $baseurl= our $G_BASEURL;
    my $api = our $G_API;
    my $destdir = cwd;

    my ($lwpua, $tilex, $tiley, $zoom, $out) = @_;
    my $path = tile2path($tilex, $tiley, $zoom);
    my $url = "$baseurl/$path$api";
    my $fname = "$destdir/$out";
 
    mkpath(dirname($fname));
    my $res = $lwpua->get($url, ':content_file' => $fname);
    die $res->status_line
	   unless $res->is_success;
  return $out;
}
1;
