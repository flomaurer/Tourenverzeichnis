sub locationSelect{
    use Tk;
    use Tk::HList;
    use strict;
    use warnings;
    use Tk::StayOnTop;
    
    if (! Exists(our $locationWindow)) {
        $locationWindow = our $mw->Toplevel (-title => 'Auswahl der Touren fürs PDF');  
        $locationWindow->stayOnTop;
        my      $screenHeight       = $mw->screenheight;
        my      $screenWidth        = $mw->screenwidth;
        $locationWindow->geometry("+" .
                     int($screenWidth/2 - 100/2) .
                     "+" .
                     int(($screenHeight - 50)/8)
                     #int(0)
                    );
            
        #++++++++++++++++++++++++++++ TABLE ++++++++++++++++++++++++++++++++++++++++
        my $tourlist = $locationWindow->Scrolled('HList',
    	   -scrollbars => 'se',
    	   -columns => 4,
    	   -header => 1,
    	   -width => 75,
    	   -height => 10,
    	   -selectmode => 'extended',
        )->pack(-fill => 'both', -expand => 1,);
        
        our $location_hlist = $tourlist->Subwidget('scrolled');
        our $location_selected=0;
        $location_hlist->configure(-browsecmd => 
            sub{
                my @selected_items = $location_hlist->info('selection');
                $location_selected= $selected_items[0];
                },
            );
        $location_hlist->header(
    	   'create', 0,
    	   -text   => 'Ort',
        );
        $location_hlist->header(
    	   'create', 1,
    	   -text   => 'Land',
        );
        $location_hlist->header(
    	   'create', 2,
    	   -text   => 'lon',
        );
        $location_hlist->header(
    	   'create', 3,
    	   -text   => 'lat',
        );
        $location_hlist->columnWidth(0, '');
        $location_hlist->columnWidth(1, '');
        $location_hlist->columnWidth(2, '');
        $location_hlist->columnWidth(3, '');
        # +++++++++++++++++++++++++ OK +++++++++++++++++++++++++++++++++++++++++++++
        my $b_ok = $locationWindow->Button(
          	-text => "OK",
          	-command => \&EnterLocation,
          )->pack();    
    }
}

sub searchLocation {
    use strict;
    use warnings;
    use Geo::GeoNames;
    my $geo = Geo::GeoNames->new( username => 'floschreibt' );
    
    our $hit;
    if (! defined $hit) {
        $hit = 0;
    } else {
        $hit= ($hit+1) % 3;
    }
    
    if ($hit == 2){
      # make a query based on placename
      our $result = $geo->search(q => our $loc_inp->get, maxRows => 10);
      if (! defined $result->[0]->{name}) {
          $result = $geo->search(name_startsWith => $loc_inp->get, maxRows => 10);
      }
      
      our $location_hlist;
      $location_hlist->delete('all');
      for my $i ( 0 .. 9 ) {
          $location_hlist->add($i);
          $location_hlist->item('create', $i, 0, -text => $result->[$i]->{name}); 
          $location_hlist->item('create', $i, 1, -text => $result->[$i]->{countryName}); 
          $location_hlist->item('create', $i, 2, -text => $result->[$i]->{lng}); 
          $location_hlist->item('create', $i, 3, -text => $result->[$i]->{lat});            
      }
    }
}

sub EnterLocation{
    use warnings;
    use strict;
    our $locationWindow->destroy();
    our $location_selected;
    our $result;
    our $location = join('; ',$result->[$location_selected]->{name},$result->[$location_selected]->{countryName},$result->[$location_selected]->{lng},$result->[$location_selected]->{lat});
}
1;
