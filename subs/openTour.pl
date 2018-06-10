sub openTour{
      use strict;
      use warnings;
    use Tk;
    use Tk::Spinbox;
    use Tk::JComboBox;
    use Tk::HList;
    
    our $selectWindow = our $mw->Toplevel (-title => our $B_OPEN);  
    my $attributes = $selectWindow->Labelframe(
        -width => 100,
        -height => 200,
  	    -text => our $L_OT_FILTER,
    )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
    
    # YEAR
    my $yearlabel = $attributes->Label(
        -text => our $C_SA_YEAR,
        )->grid(-row=>'0', -column=>'0', -padx => 5, -pady => 5, );
    our $sel_year = our $C_OT_YEAR;
    my $yearselect = $attributes->Spinbox(
        -from => our $C_SA_YEAR_MIN,
        -to   => our $C_SA_YEAR_MAX,
        -textvariable => \$sel_year,
        -increment => 1,
        )->grid(-row=>'0', -column=>'1', -padx => 5, -pady => 5, );
    
    # TYPE
    my $typelabel = $attributes->Label(
        -text => our $L_KIND,
        )->grid(-row=>'0', -column=>'2', -padx => 5, -pady => 5, );
    my @types = our @S_TYPES;
    our $sel_kind = '';
    my $type_inp = $attributes->JComboBox(
       -entrybackground => 'white',
       -mode => 'editable',
       -relief => 'sunken',
       -choices => \@types, 
       -textvariable => \$sel_kind
       )->grid(-row=>'0', -column=>'3', -padx => 5, -pady => 5, );
    
    #NAME
    our $sel_Goal = '';
    my $namelabel = $attributes->Label(
        -text => our $L_GOAL,
        )->grid(-row=>'0', -column=>'4', -padx => 5, -pady => 5, );
    my $name_inp = $attributes->Entry(
        -textvariable => \$sel_Goal, 
        -width => 20,
        )->grid(-row=>'0', -column=>'5', -padx => 5, -pady => 5, );
    
    #MINDIS
    our $sel_mindistance = '';
    my $mindislabel = $attributes->Label(
        -text => our $L_OT_DIST_MIN,
        )->grid(-row=>'0', -column=>'6', -padx => 5, -pady => 5, );
    my $min_dis_inp = $attributes->Entry(
        -textvariable => \$sel_mindistance, 
        -width => 10,
        )->grid(-row=>'0', -column=>'7', -padx => 5, -pady => 5, );
    
    #MAXDIS
    our $sel_maxdistance = '';
    my $maxdislabel = $attributes->Label(
        -text => our $L_OT_DIST_MAX,
        )->grid(-row=>'0', -column=>'8', -padx => 5, -pady => 5, );
    my $max_dis_inp = $attributes->Entry(
        -textvariable => \$sel_maxdistance, 
        -width => 10,
        )->grid(-row=>'0', -column=>'9', -padx => 5, -pady => 5, );
        
    #MINtime
    our $sel_mintime = '';
    my $mintimelabel = $attributes->Label(
        -text => our $L_OT_TIME_MIN,
        )->grid(-row=>'0', -column=>'10', -padx => 5, -pady => 5, );
    my $min_time_inp = $attributes->Entry(
        -textvariable => \$sel_mintime, 
        -width => 10,
        )->grid(-row=>'0', -column=>'11', -padx => 5, -pady => 5, );
    
    #MAXtime
    our $sel_maxtime = '';
    my $maxtimelabel = $attributes->Label(
        -text => our $L_OT_TIME_MAX,
        )->grid(-row=>'0', -column=>'12', -padx => 5, -pady => 5, );
    my $max_time_inp = $attributes->Entry(
        -textvariable => \$sel_maxtime, 
        -width => 10,
        )->grid(-row=>'0', -column=>'13', -padx => 5, -pady => 5, );
        
    #++++++++++++++++++++++++++++ TABLE ++++++++++++++++++++++++++++++++++++++++
    my $tourlist = $selectWindow->Scrolled('HList',
	   -scrollbars => 'se',
	   -columns => 8,
	   -header => 1,
	   -width => 200,
	   -height => 20,
	   -selectmode => 'extended',
    )->pack(-fill => 'both', -expand => 1,);
    
    our $real_hlist = $tourlist->Subwidget('scrolled');
    our $selected_tour=0;
    $real_hlist->configure(-browsecmd => 
        sub{
            my @selected_items = $real_hlist->info('selection');
            $selected_tour= $selected_items[0];
            },
        );
    $real_hlist->header(
	   'create', 0,
	   -text   => our $L_DATE,
    );
    $real_hlist->header(
	   'create', 1,
	   -text   => our $L_KIND,
    );
    $real_hlist->header(
	   'create', 2,
	   -text   => our $L_GOAL,
    );
    $real_hlist->header(
	   'create', 3,
	   -text   => our $L_LOCATION,
    );
    $real_hlist->header(
	   'create', 4,
	   -text   => our $L_OT_COMPAN,
    );
    $real_hlist->header(
	   'create', 5,
	   -text   => our $L_DISTANCE,
    );
    $real_hlist->header(
	   'create', 6,
	   -text   => our $L_OT_UNIT,
    );
    $real_hlist->header(
	   'create', 7,
	   -text   => our $L_TOTAL_TIME,
    );
    # +++++++++++++++++++++++++ OK +++++++++++++++++++++++++++++++++++++++++++++
    my $b_ok = $selectWindow->Button(
      	-text => our $B_OK,
      	-command => \&EnterTour,
      )->pack();    
    
    #+++++++++++++++++++++++++++ FUNCTIONS +++++++++++++++++++++++++++++++++++++        # instead of loop: Tk::Bind should reduce workload - but problem with JComboBox to solve first
    
    our $search_loop = $selectWindow->repeat(100, sub{search($sel_year, $sel_kind, $sel_Goal, $sel_maxdistance, $sel_mindistance, $sel_mintime, $sel_maxtime)});# cleanup before closing
    $selectWindow->protocol('WM_DELETE_WINDOW' => sub{$search_loop->cancel(); $selectWindow->withdraw();}, );

}

sub search {
      use warnings;
    use strict;
    use Tk::DialogBox;
    
    require "./subs/readDBforSearch.pl";
    require "./subs/forcehhmmss.pl";
    our @entries;
    our $real_hlist;

    my ($select_year, $select_kind, $select_Goal, $select_maxdistance, $select_mindistance, $select_mintime, $select_maxtime) = @_;
     #++++++++++++++++++++ PROCESSING
    if ($select_year eq '') {
        $select_year = "'%'";
    }else{
        $select_year = join('',"'",$select_year,"%'");
    }
    if ($select_kind eq '') {
        $select_kind = "'%'";
    }else{
        $select_kind = join('',"'%",$select_kind,"%'");
    }
    if ($select_Goal eq '') {
        $select_Goal = "'%'";
    }else{
        $select_Goal = join('',"'%",$select_Goal,"%'");
    }
    if ($select_maxdistance eq '') {
        $select_maxdistance = our $U_OT_DIST_MAX;
    }
    if ($select_mindistance eq '') {
        $select_mindistance = our $U_OT_DIST_MIN;
    }
    if ($select_maxtime eq '') {
        $select_maxtime = our $U_OT_TIME_MAX;
    }
    if ($select_mintime eq '') {
        $select_mintime = our $U_OT_TIME_MIN;
    }
    
    $select_mintime=forcehhmmss($select_mintime);
    $select_maxtime=forcehhmmss($select_maxtime);
    
    if ($select_mintime eq 'error' || $select_maxtime eq 'error') {
        our $search_loop->cancel();
        my $timeError = our $selectWindow->DialogBox(
        	-title => our $L_TE_TITLE,
        	-buttons => [our $B_OK],
        	-default_button => $B_OK,
        );
        my $t=$timeError->add('Label', 
        	-text => our $T_TE_TEXT)->pack();
        $timeError->Show();
        $selectWindow->withdraw();
        openTour();
    }
    
    my @newentries = readDBsearch($select_year, $select_kind, $select_Goal, $select_mindistance, $select_maxdistance, $select_mintime, $select_maxtime);
    
    if (@newentries != @entries){
        @entries = @newentries;
        $real_hlist->delete('all');
        for my $i ( 0 .. $#entries ) {
            $real_hlist->add($i);
            for my $j ( 1 .. $#{ $entries[$i] } ) {
                my $in = $entries[$i][$j];
                $in =~ s/\n//g;
                $real_hlist->item('create', $i, $j-1, -text => $in);
            }
            
        }
    }
    
}

sub EnterTour{
      use strict;
      use warnings;
    our $search_loop->cancel();
    our $selectWindow->withdraw();
    our $selected_tour;
    our @entries;
    my $id = $entries[$selected_tour][0];
    loadTour($id);
}
1;
