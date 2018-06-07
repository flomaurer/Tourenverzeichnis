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
  require "./subs/calcDistance.pl";

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
    if (our $startlat eq '' && our $startlon eq ''){ #only suggest location for new tours
        locationSelect();
        searchLocationbyCoordinates($lats[0],$lons[0]);
    }
    #overwrites selection with values of GPS-Track (more accurate for MAP-Overview)
    our $startlat =$lats[0];
    our $startlon =$lons[0];
  }
  
    # extract plot limits
      (our $elemin, our $elemax) = minmax @eles; 
      
    my @x_axis;
    our @tracktimes;
# TIMEvalues in track?
    if ($#times > 2){
      my $i=0;
      for (@times){
        @x_axis[$i] = timestringtoseconds($times[$i]);
        $i++;
      }  
      @x_axis = map { $_ - $x_axis[0] } @x_axis;
    # plot times for PDF ------------------------------------------------------------------ need modification, if no Timestamp for @tracktimes: here and in PDF (plot.tex)
      @tracktimes = @x_axis;
      our $endTime = max @x_axis;
    # extract details
      our $Activity_date = substr($times[0],0,10);
      
      our $Start_time =  substr($times[0],11,8);
      
      $endTime = secondstotimestringhhmmss($endTime);
      
# ONLY done if times exist (based on FIT2GPX)      
      # Extract intertimes ----------------------------------------------------------------------  
        our @interTimes;
        foreach my $lap ($xpc->findnodes('//gpxdata:elapsedTime')) {
          #say $lap->to_literal();
          push @interTimes, secondstotimestringhhmmss($lap->to_literal());
        }
      # Extract activity infos ------------------------------------------------------------------  
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
    }else {
        @x_axis[0] = 0; 
        for (my $ind =1; $ind <= $#lons; $ind++){
            @x_axis[$ind] = $x_axis[$ind-1]+distance($lats[$ind-1], $lons[$ind-1], $lats[$ind], $lons[$ind], "K")*1000; #using meters here
            #printf (join(' ',$lats[$ind-1], $lons[$ind-1], $lats[$ind], $lons[$ind], "K", "\n")); 
            #printf "$x_axis[$ind]\n";
        }
        my $x_val_i = 0;
        foreach my $x_val (@x_axis){
            @tracktimes[$x_val_i] = $x_axis[$x_val_i]/1000;
            $x_val_i++;
        }
        our $plot_unit = 'distance';
    }
  
  # PLOT Optimization ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $t_max = int((minmax(@x_axis))[1]);
  my $freq = int(($t_max/(scalar @x_axis)*20)+0.5);     # jeder 20te Wert  
  my $t=0;
  my $j=0;
  my $k=0;
  my @x_axis_plot;
  my @eles_plot;
  while ($t <= $t_max){
    while ($x_axis[$k] < $t){
        $k++;
    }
    if ($x_axis[$k] == $t or $x_axis[$k]-$t < $t-$x_axis[$k-1]){
        $x_axis_plot[$j] = $x_axis[$k]; 
        $eles_plot[$j] = $eles[$k];
        #printf "Write:j=$j k=$x_axis[$k] t=$t\n";
    }else{
        $x_axis_plot[$j] = $x_axis[$k-1];
        $eles_plot[$j] = $eles[$k-1];
        #printf "Write:j=$j k=$x_axis[$k-1] t=$t\n";
    }
    $j++;  
    $t=$t+$freq;
    #printf "$t \n";
  }
  
  our $xdistance = int((scalar @x_axis_plot)/10); # xdistance in plot-preview
  
    if ($#times > 2){ # do just, if time values and not distances
      # convert timevalues (seconds) to strings (hh:mm:ss) for previewplot
      foreach my $x (@x_axis_plot) { $x = secondstotimestringhhmm($x); }
    } else { #convert to km (XX.y km)
        foreach my $x (@x_axis_plot) { 
            $x = int($x/100)/10; 
            $x =~ s/(^[0-9])\.(.)/0$1.$2/;            
            $x =~ s/(^[0-9]$)/0$1.0/;
            $x =~ s/(^[0-9]{2,}$)/$1.0/;
        }
    }

  my @plot = (
    [@x_axis_plot],
    [@eles_plot]
  );
  return(@plot);
}
1;
