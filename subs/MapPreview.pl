#!/usr/bin/perl
sub MapPreview {

    #use strict;                                                                # can't use strict, as pictures generated in forloop
    use warnings;

    use List::MoreUtils qw( minmax );
    use Net::Ping;
    use Tk::WaitBoxFixed;
    
    my $wd = our $mw->WaitBoxFixed(
        -bitmap =>'hourglass',
        -txt1 => "Das Erstellen der Karte dauert noch an",
	    -txt2 => 'Sollte es ungewöhnlich lange dauern, überprüfe deine Internetverbindung.', #default would be 'Please Wait'
        -title => 'Kartenvorschau',
    );
    
    $wd->Show();
    # prove internetconnection
    #my $ping = Net::Ping->new("tcp");
    #$ping->port_number("80");
    #if ( $ping->ping( 'www.google.com', '10' ) ) {
    
        require "./subs/downloadosmtracktile.pl";
        
        # Initialize Graphic
        our $mapWindow = $mw->Toplevel (-title => 'Karte - Mercator-Projektion (nicht  flächen- oder richtungstreu, aber winkeltreu)');  
        
        my $canvas = $mapWindow->Scrolled('Canvas',
            -bg => 'white',
            # Bildlaufleisten unten und rechts
            -scrollbars => 'se',
        )->pack(
            -fill => 'both',
            -expand => 1,
        );
    
        # DOWNLOAD Tiles
        my (@lon)= our @lons;
        my (@lat) = our @lats;
        
        my ($minlat, $maxlat) = minmax(@lat);
        my ($minlon, $maxlon) = minmax(@lon);
        
        #printf "lon: $minlon, $maxlon; lat: $minlat, $maxlat\n";
        
        my @positions=downloadosmtracktile($minlat*100, $maxlat*100, $minlon*100, $maxlon*100,1); # *100, as use of old funktion, which uses tex supportet plot range
        
        # SCALE Coordinates to Window
        my $scale = 700/max(abs($maxlat-$minlat), abs($maxlon-$minlon));
        
        
        # calculate axis-transformation for Mercator projection
        my $sc_x=abs(($positions[0][0][0]-$positions[0][0][3])/256 * $scale);
        #printf "$sc_x\n";
        my $sc_y=abs(($positions[0][0][1]-$positions[0][0][4])/256 * $scale);
        #printf "$sc_y\n";
        
        # Process Tiles
        for my $j (0 .. $#positions) {
            for my $k (0 .. $#{$positions[$j]}) {
                our $var= "pic_x".$j."_y".$k; 
                $$var=$mapWindow->Photo(-file => $positions[$j][$k][2]);
                # display Tiles
                $canvas->createImage($positions[$j][$k][0]*$scale/$sc_x, -$positions[$j][$k][1]*$scale/$sc_y, -image =>$$var, -anchor =>'sw');
            }
        }
        
        my @path;
        my $i = 0;
        foreach my $x (@lon) {
                push @path, $x*$scale/$sc_x;
                push @path, -$lat[$i]*$scale/$sc_y;
            $i++;
        }
        
    
        
        #track drüberlegen
        $canvas->createLine(@path, -fill => 'red', -width => 3);
        
        $canvas->configure(-scrollregion => [ $canvas->bbox("all") ]);
        
        # Groeße des Fensters:
        my      $windowHeight       = 256*($#{$positions[0]}+1);
        my      $windowWidth        = 256*($#positions+1);
        # Bildschirmgroeße holen:
        my      $screenHeight       = $mw->screenheight;
        my      $screenWidth        = $mw->screenwidth;
        # MainGUI zentrieren:
        $mapWindow->geometry($windowWidth."x".$windowHeight);
        $mapWindow->geometry("+" .
                           int($screenWidth/2 - $windowWidth/2) .
                           "+" .
                           int(($screenHeight - $windowHeight)/8)
                           #int(0)
                          );
        
        $wd->unShow();
        
        # cleanup before closing
        $mapWindow->protocol('WM_DELETE_WINDOW' => \&cleanMapPreview);    
        
    #} else {
    #    my $noPreviewMapDialog = $mw->Dialog(
    #    	-title => 'Info zur Kartenvorschau',
    #    	-text => "Es konnte kein Kartenmaterial heruntergeladen werden.
#Bitte überprüfe deine Internetverbindung und versuche es ggf. erneut.",
#        	-bitmap => 'info',
#        	-buttons => ['OK'],
#        	-default_button => 'OK',
#        );
#        $wd->unShow();
#        $noPreviewMapDialog->Show();
#    }
#    $ping->close();
    
}
sub cleanMapPreview { # NOT REALY WORKING - results in no RAM optimization
    
    for my $j (0 .. $#positions) {
        for my $k (0 .. $#{$positions[$j]}) {
            our $var= "pic_x".$j."_y".$k; 
            $$var->delete();
        }
    }
    
    our $mapWindow->destroy();
}

1;