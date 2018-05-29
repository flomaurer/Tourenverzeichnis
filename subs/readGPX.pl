sub readGPX{
  use 5.010;
  use strict;
  use warnings;
  
  use XML::LibXML;
  use XML::LibXML::XPathContext;
  
  use List::MoreUtils qw( minmax );
  use List::Util qw( max );
  
  require "./subs/seconds2timestring.pl";
  require "./subs/timestring2seconds.pl";
  require "./subs/MapPreview.pl";

  our @eles = ();
  my @times = ();
  our @lats = ();
  our @lons = ();
  my $filename = $_[0];
  my $dom = XML::LibXML->load_xml(location => $filename);
  my $xpc = XML::LibXML::XPathContext->new($dom);
  $xpc->registerNs('gpxx',  'http://www.topografix.com/GPX/1/1');
  
  foreach my $ele ($xpc->findnodes('//gpxx:ele')) {
#      say $ele->to_literal();
      push @eles, $ele->to_literal();
  }
  foreach my $time ($xpc->findnodes('//gpxx:trkpt/gpxx:time')) {
#      say $time->to_literal();
      push @times, $time->to_literal();
  }
  foreach my $pt ($xpc->findnodes('//gpxx:trkpt')) {
    my $lon = $pt->findvalue('./@lon');
    my $lat = $pt->findvalue('./@lat');
    if ($lon ne '0' && $lat ne '0') {
        push @lons, $lon;
        push @lats, $lat;
    }
  }
  
  if ($#lons > 2 && $#lats > 2){
    #---------------------------------------
    # Show map preview
    MapPreview();
    #---------------------------------------
    # search for startpoint
    locationSelect();
    searchLocationbyCoordinates($lats[0],$lons[0]);
    #overwrites selection with values of GPS-Track (more accurate for MAP-Overview)
    our $startlat =$lats[0];
    our $startlon =$lons[0];
  }
  my @timess;
  my $i=0;
  for (@times){
    @timess[$i] = timestringtoseconds($times[$i]);
    $i++;
  }  
  @timess = map { $_ - $timess[0] } @timess;
  our @tracktimes = @timess;
  our $endTime = max @timess;
# extract plot limits
  (our $elemin, our $elemax) = minmax @eles; 
# extract details
  our $Activity_date = substr($times[0],0,10);
  
  our $Start_time =  substr($times[0],11,8);
  
  $endTime = secondstotimestringhhmmss($endTime);
  
  our @interTimes;
  foreach my $lap ($xpc->findnodes('//gpxdata:elapsedTime')) {
    #say $lap->to_literal();
    push @interTimes, secondstotimestringhhmmss($lap->to_literal());
  }
  
  if ($xpc->findnodes('//gpxx:type') eq 'Mountaineering'){
    our $sel_type = 'Skitour';
    our $distance = 0;
    my @summaries;
    my @summary = $xpc->findnodes('//gpxdata:summary');        
    foreach my $dis (@summary) {
      push @summaries, $dis->findvalue('./@name');
    }
    my @idxs = grep { $summaries[$_] ~~ 'total_ascent' } 0 .. $#summaries;          
    foreach my $idx (@idxs) {
      $distance=$distance+ $summary[$idx]->to_literal();
    }    
    our $distance_unit = 'hm';
        
  }elsif ($xpc->findnodes('//gpxx:type') eq 'Cycling') {
    our $sel_type = 'Rennrad';
    our $distance = 0;
    my @summary = $xpc->findnodes('//gpxdata:distance');        
    foreach my $dis (@summary) {
      $distance=$distance+ $dis->to_literal();
    }
    $distance = int($distance/1000+0.5);
    our $distance_unit = 'km';
  }
  
  # PLOT Optimization ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $t_max = (minmax(@timess))[1];
  my $freq = int($t_max/(scalar @timess)*20);     # jeder 20te Wert    
  my $t=0;
  my $j=0;
  my $k=0;
  my @timess_plot;
  my @eles_plot;
  while ($t <= $t_max){
    while ($timess[$k] < $t){
        $k++;
    }
    if ($timess[$k] == $t or $timess[$k]-$t < $t-$timess[$k-1]){
        $timess_plot[$j] = $timess[$k];
        $eles_plot[$j] = $eles[$k];
        #printf "Write:j=$j k=$timess[$k] t=$t\n";
    }else{
        $timess_plot[$j] = $timess[$k-1];
        $eles_plot[$j] = $eles[$k-1];
        #printf "Write:j=$j k=$timess[$k-1] t=$t\n";
    }
    $j++;  
    $t=$t+$freq;
  }
  
  our $xdistance = int((scalar @timess_plot)/10);
  
  # convert timevalues (seconds) to strings (hh:mm:ss) for previewplot
  foreach my $x (@timess_plot) { $x = secondstotimestringhhmm($x); }

  my @plot = (
    [@timess_plot],
    [@eles_plot]
  );
  return(@plot);
}
1;
