#!perl
use strict;
use warnings;
#use diagnostics;
use utf8;
use POSIX;
require "./subs/readGPX.pl";
require "./subs/writeGPX.pl";
require "./subs/saveActivity.pl";
require "./subs/writePDF.pl";
require "./subs/Status.pl";
require "./subs/openTour.pl";
require "./subs/forcehhmmss.pl";
require "./subs/LocationSelect.pl";
require "./subs/text_variables.pl";
use Tk;
use Tk::Labelframe;
require Tk::MiniCalendar;
use Tk::Chart::Lines;
use Tk::JComboBox;
use Tk::Text;
use Tk::Radiobutton;
use Tk::Dialog;
use Tk::TList;
use Tk::PNG;
use Tk::JPEG;
use FindBin;
use Tk::Menu;
use File::Copy;
use File::Path;
use Tk::ToolBar;
use Tk::StatusBar;

# Variables
  our $elemin;                                                                  # for axislimits
  our $elemax;
  my $chart;                                                                    # chart plot - to be deletet before generating new one
  our @interTimes = (our $C_INTER_TIME);                                               # selectionvalues for intermediate time   
  our @tracktimes;
  our @eles;
  our @lats = our @C_LATS;
  our @lons = our @C_LONS;
  our $tick;
  our $elevationout=our $C_ELEVATION;
  our $xdistance; # for Plotpreview
  our $tournumber = join ('', our $L_TOUR, our $C_TOURNBR);
  our $startlat = our $C_STARTLAT;
  our $startlon = our $C_STARTLON;
  our $plot_unit = our $C_PLOT_UNIT_X;
    
# defining main window
  our $mw = Tk::MainWindow->new(-title => our $L_TITLE);
  # Groeße des Fensters:
  my      $windowHeight       = our $C_MW_HEIGHT;
  my      $windowWidth        = our $C_MW_WIDTH;
  # Bildschirmgroeße holen:
  my      $screenHeight       = $mw->screenheight;
  my      $screenWidth        = $mw->screenwidth;
  # MainGUI zentrieren:
  $mw->geometry($windowWidth."x".$windowHeight);
  $mw->geometry("+" .
                     int($screenWidth/2 - $windowWidth/2) .
                     "+" .
                     int(($screenHeight - $windowHeight)/8)
                     #int(0)
                    );
  # minimale Groeße festlegen:
  $mw->minsize(our $C_MW_WIDTH_MIN, our $C_MW_HEIGHT_MIN);
  
  # cleanup before closing
  $mw->protocol('WM_DELETE_WINDOW' => \&closeing, );

# oberes Auswahlmenue
  my $menuitems = [
      [Cascade => our $B_FILE, -menuitems =>
          [
              [Button => our $B_NEW, -command => \&newActivity],
              [Separator => ""],
              [Button => our $B_OPEN, -command => \&openActivity],
              [Button => our $B_SAVE, -command => \&save],
          ],
      ],
      [Cascade => our $B_INFO, -menuitems =>
          [
              [Button => our $B_ABOUT, -command => \&about],
          ],
      ],
  ];
       
  my $menu = $mw->Menu(-menuitems => $menuitems);
  $mw->configure(-menu => $menu);

# Fenstereinteilung
  my $splitv = $mw->Panedwindow(
    -orient => 'v',
  )->pack(-fill => 'both', -expand => 1,);
  
  my $top = $splitv->Frame( -height => 250);
  my $bottom = $splitv->Frame( -height => 200);
  
  $splitv->add($top, -height => 250);
  $splitv->add($bottom, -height => 200);
  
  my $splithtop = $top->Panedwindow(
    -orient => 'h',
  )->pack(-fill => 'both', -expand => 1,);
  
  my $topleft = $splithtop->Frame( -width => 1000);
  my $topright = $splithtop->Frame( -width => 100);
  
  $splithtop->add($topleft, -width => 1000);
  $splithtop->add($topright, -width => 100);
  
  my $splithbottom = $bottom->Panedwindow(
    -orient => 'h',
  )->pack(-fill => 'both', -expand => 1,);
  
  my $bottomleft = $splithbottom->Frame( -width => 800);
  my $bottomright = $splithbottom->Frame( -width => 100);
  
  $splithbottom->add($bottomleft, -width => 800);
  $splithbottom->add($bottomright, -width => 100);

# Hoehenprofil
  my $f_plot = $bottomleft->Labelframe(
      -width => 50,
      -height => 60,
  	-text => our $L_ELEVATION_PROFILE,  
  )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "bottom");
  
# Beschreibung und Kommentar  
  my $BeschruKommen = $bottomright->Labelframe(
      -width => 100,
      -height => 200,
  	-text => our $L_DESCRIPTION_COMMENT,
  )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
  
  my $splittext = $BeschruKommen->Panedwindow(
    -orient => 'v',
  )->pack(-fill => 'both', -expand => 1,);
  
  my $texttop = $splittext->Frame( -height => 100);
  my $textmid = $splittext->Frame( -height => 50);
  my $textbottom = $splittext->Frame( -height => 50);
  
  $splittext->add($texttop, -height => 100);
  $splittext->add($textmid, -height => 50);
  $splittext->add($textbottom, -height => 50);
  
  our $beschreibung = $texttop->Scrolled('Text',-scrollbars => 'e', -wrap => 'word',)->pack(-fill => 'both', -expand => 1,);
  $beschreibung->insert('end', our $T_DESCRIPTION);
  
  our $begleitung = $textmid->Scrolled('Text',-scrollbars => 'e', -wrap => 'word',)->pack(-fill => 'both', -expand => 1,);
  $begleitung->insert('end',our $T_BEGLEITUNG);
  
  our $kommentar = $textbottom->Scrolled('Text',-scrollbars => 'e', -wrap => 'word',)->pack(-fill => 'both', -expand => 1,);
  $kommentar->insert('end', our $T_COMMENT);
  
  my $writeTourButton = $bottomright->Button(
        -text => $B_SAVE,
        -command => \&save,
        -background => 'green',
    )->pack(-fill => 'both', -expand => 0,);
    
# Eigenschaften
  my $f_details = $topleft->Labelframe(
      -width => 75,
      -height => 100,
  	-text => our $L_DETAILS,
  )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
  # Filemanager
    my $f_select = $topleft->Labelframe(
        -width => 100,
        -height => 100,
    	-text => our $L_TRACKFILE,  
    )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
    my $file = $f_select->Label(
        -text => our $T_TRACKFILE,
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -expand => 1, -side => 'left',);
    my $file_select = $f_select->Button(
        -text => our $B_TRACK_SELECT,
        -command => \&show_file_dialog,
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -side => 'left',);
    our $trackpath='';
    my $readFitButton = $f_select->Button(
        -text => our $B_READ_TRACK,
        -command => \&readFIT,
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -side => 'left',);
  # Attribute input
    # Name
      our $Goal = our $C_GOAL;
      my $name = $f_details->Label(
          -text => our $L_GOAL,
      )->grid(-row=>'0', -column=>'0', -padx => 5, -pady => 5, );
      my $name_inp = $f_details->Entry(-textvariable => \$Goal, -width => 100,)->grid(-row=>'0', -column=>'1', -columnspan=>'5', -padx => 5, -pady => 5, );
      our $number = $f_details->Label(
          -text => $tournumber,
      )->grid(-row=>'0', -column=>'6', -padx => 5, -pady => 5, );
    # Type
      my $type = $f_details->Label(
          -text => our $L_KIND,
      )->grid(-row=>'1', -column=>'0', -padx => 5, -pady => 5, );
      my @types = our @S_TYPES;
      our $sel_type = our $C_TYPE;
      my $type_inp = $f_details->JComboBox(
     -entrybackground => 'white',
     -mode => 'editable',
     -relief => 'sunken',
     -choices => \@types, 
     -textvariable => \$sel_type)->grid(-row=>'1', -column=>'1', -padx => 5, -pady => 5, );
    # Date
      my $date = $f_details->Label(
          -text => our $L_DATE,
      )->grid(-row=>'1', -column=>'2', -padx => 5, -pady => 5, );
      our $Activity_date = our $C_DATE;
      my $date_inp = $f_details->Entry(-textvariable => \$Activity_date
      )->grid(-row=>'1', -column=>'3', -padx => 5, -pady => 5, );
      my $cal_pic = $mw->Photo(-file => our $G_CAL_PATH);
      my $b_ok = $f_details->Button(
      	#-text => "Select Date",
        -image => $cal_pic,
      	-command => \&selectDate,
      )->grid(-row=>'1', -column=>'4', -padx => 5, -pady => 5, );
    # Location
    our $location=our $C_LOCATION;
      my $loc = $f_details->Label(
          -text => our $L_LOCATION,
      )->grid(-row=>'2', -column=>'0', -padx => 5, -pady => 5, );
      our $loc_inp = $f_details->Entry(-textvariable => \$location)->grid(-row=>'2', -column=>'1', -padx => 5, -pady => 5, );
      $loc_inp->bind('<ButtonPress>'    , \&locationSelect);
      my $childPID;
      $loc_inp->bind('<Key-Return>'     , sub{
                                                searchLocation();
                                          });
    # Distance
      my $dist_hm = $f_details->Label(
          -text => our $L_DISTANCE_HM,
      )->grid(-row=>'2', -column=>'2', -padx => 5, -pady => 5, );
      our $distance_hm=our $C_DISTANCE_HM;
      my $dist_hm_inp = $f_details->Entry(-textvariable => \$distance_hm)->grid(-row=>'2', -column=>'3', -padx => 5, -pady => 5, );
      my $dist_km = $f_details->Label(
          -text => our $L_DISTANCE_KM,
      )->grid(-row=>'2', -column=>'4', -padx => 5, -pady => 5, );
      our $distance_km=our $C_DISTANCE_KM;
      my $dist_km_inp = $f_details->Entry(-textvariable => \$distance_km)->grid(-row=>'2', -column=>'5', -padx => 5, -pady => 5, );
    # Start_Time
      my $s_time = $f_details->Label(
          -text => our $L_START_TIME,
      )->grid(-row=>'3', -column=>'0', -padx => 5, -pady => 5, );
      our $Start_time = our $C_START_TIME;
      my $s_time_inp = $f_details->Entry(-textvariable => \$Start_time)->grid(-row=>'3', -column=>'1', -padx => 5, -pady => 5, );
    # Inter_Time
      my $i_time = $f_details->Label(
          -text => our $L_INTER_TIME,
      )->grid(-row=>'3', -column=>'2', -padx => 5, -pady => 5, );
      our $interTime = $C_INTER_TIME;
      my $i_time_inp = $f_details->JComboBox(
     -entrybackground => 'white',
     -mode => 'editable',
     -relief => 'sunken',
     -choices => \@interTimes,
     -textvariable => \$interTime,
  )->grid(-row=>'3', -column=>'3', -padx => 5, -pady => 5, );
    # End_Time
      my $e_time = $f_details->Label(
          -text => our $L_TOTAL_TIME,
      )->grid(-row=>'3', -column=>'4', -padx => 5, -pady => 5, );
      our $endTime = our $C_TOTAL_TIME;
      my $e_time_inp = $f_details->Entry(-textvariable => \$endTime)->grid(-row=>'3', -column=>'5', -padx => 5, -pady => 5, );
      
# Bilderauswahl
  our $tlist = $topright->Scrolled('TList',
  	-scrollbars => 'os',
  	-orient => 'vertical',
  )->pack(-fill => 'both', -expand => 1,);
  my $folderpicture = $topright->Photo(-file => our $G_PIC_PATH);
  
  our @picFiles = '-';
  
  my $selectPICs = $topright->Button(
    -text => our $B_SELECT_PIC,
    -command => \&selPics,
  )->pack();

# Speicherdialog
  my $saveDialog = $mw->Dialog(
  	-title => our $L_SD_TITLE,
  	-text => our $T_SD_TEXT,
  	-bitmap => 'warning',
  	-buttons => [our $B_YES, our $B_NO],
  	-default_button => $B_NO,
  );
# Enddialog
  our $finishDialog = $mw->Dialog(
  	-title => our $L_FD_TITLE,
  	-text => our $T_FD_TEXT,
  	-bitmap => 'info',
  	-buttons => [$B_YES, $B_NO],
  	-default_button => $B_NO,
  );
# Saving failed dialog
  our $DataDialog = $mw->Dialog(
  	-title => our $L_MD_TITLE,
  	-text => our $T_MD_TEXT,
  	-bitmap => 'error',
  	-buttons => [our $B_OK],
  	-default_button => $B_OK,
  );
  
# Toolbar
  my $tb = $mw->ToolBar(
  	-movable => 0, 
  	-side => 'top', 
  );
  my $save_pic = $mw->Photo(-file => our $G_SAVE_PATH);
  my $generate_pic = $mw->Photo(-file => our $G_GENERATE_PATH);
  $tb->ToolButton( -image   => 'filenew22',
                    -tip     => $B_NEW,
                    -command => \&newActivity);
  $tb->ToolButton( -image   => 'fileopen22',
                    -tip     => $B_OPEN,
                    -command => \&openActivity);
  $tb->ToolButton( -image   => $save_pic,
                    -tip     => $B_SAVE,
                    -command => \&save);
  $tb->ToolButton( -image   => $generate_pic,
                    -tip     => our $B_GENERATE,
                    -command => \&generatePDF);

# Statusbar --------------------------------------------------------------------
    
    our ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter) = getStatus();

    my $sb= $mw->StatusBar();
    $sb->addLabel(
        -relief         => 'flat',
        -text           => join('', our $L_OV_YEAR, $status_year, our $L_OV_EINTER, $status_winter, our $L_OV_SKITOUR),
        );
    $sb->addLabel(
        -text           => join(' ',our $L_OV_TTOUR , $status_total),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ',our $L_OV_STOUR , $status_ski),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ', our $L_OV_BTOUR, $status_bike),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ', our $L_OV_HTOUR, $status_mountain),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ', our $L_OV_CTOUR, $status_klettern),
        -anchor         => 'center',
        -width          => '25',
        );
# -------------------------------------------------------------------- Statusbar
  
$mw->MainLoop;

# sub for generating PDF
    sub generatePDF {
        use strict;
        use warnings;
        setupWritePDF();
    }
# sub for selecting Track
  sub show_file_dialog {
      use strict;
      use warnings;
      my @ext = (
          [our $C_TFILE,    [qw/.fit .FIT .gpx .GPX/]],
          [our $C_AFILE,    ['*']],
      );
      my $trackfile = $mw->getOpenFile(
          -filetypes => \@ext,
      );
      $file->configure(-text => $trackfile);
      $trackpath = $trackfile;
  }

# sub for reading fit file (converting to gpx and extracting values)
  sub readFIT {
      use strict;
      use warnings;
    my $tmptrack = join('',$FindBin::Bin,"/tmp");
    mkdir($tmptrack);
    copy("$trackpath", "$tmptrack") or die "Copy failed: $!";
    $trackpath = join('/tmp',$FindBin::Bin,substr($trackpath, rindex($trackpath, '/')));
    if ($trackpath =~ /.fit/ | $trackpath =~ /.FIT/){
        writeGPX($trackpath);
    }
    (our $GPXpath = $trackpath) =~ s/.fit$/.gpx/i;
    my (@ele) = readGPX($GPXpath);
    $chart->destroy if Tk::Exists($chart);                                      # that only a single chart exists in window
    $chart = $f_plot->Lines(
    -xlabel     => our $L_EP_XAXIS,
    -ylabel     => our $L_EP_YAXIS,
    -linewidth  => 1,
    -background => 'white',
    -yminvalue => floor($elemin/10)*10,
    -ymaxvalue => ceil($elemax/10)*10,
    -yticknumber => 10,
    -xlabelskip => $xdistance,
    -xvaluevertical => 0,
  )->pack(qw / -fill both -expand 1 /);
    #my @legends = ( 'height' );
    #$chart->set_legend( -data => \@legends, );
    $chart->plot( \@ele );
  }
  
# sub for saving Tour
  sub save {
      use strict;
      use warnings;
      my $save_response = $saveDialog->Show();
      if( $save_response eq $B_YES ) {
          our $bgl = $begleitung->get('1.0', 'end');
          our $bschr = $beschreibung->get('1.0', 'end');
          our $com = $kommentar->get('1.0', 'end');
  	  saveTour($Activity_date, $sel_type, $Goal, $location, $distance_hm, $distance_km, forcehhmmss($Start_time), forcehhmmss(our $interTime), forcehhmmss(our $endTime), $bgl, $bschr, $com);
  	  }elsif ( $save_response eq $B_NO ) {
          print our $T_SD_RESULT;
      }
      our ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter) = getStatus();
  }

# sub for selectiong corresponding PICs  
  sub selPics {
      use strict;
      use warnings;
     my @types = (
       [our $C_PFILE,       ['.jpeg', '.JPEG', '.jpg', '.JPG', '.png', '.PNG', '.gif', '.GIF']],
       [our $C_AFILE,           ['*']]
     );
     our @picFiles = $mw->getOpenFile(-filetypes=>\@types, -multiple=>1);
    foreach my $pic ( @picFiles ) {
      my $item = substr($pic, -20);
      our $tlist->insert('end',
        -itemtype => 'imagetext',
        -image => $folderpicture,
        -text => "$item",
      );
    }
  }
  
# sub for minicalendar
  sub selectDate {
      use strict;
      use warnings;
    my $Calendar_Frame = $mw -> Toplevel();
    my $minical = $Calendar_Frame->MiniCalendar->pack;
    my $b_ok = $Calendar_Frame->Button(
    	-text => our $B_OK,
    	-command => sub {
    	  my ($year, $month, $day) = $minical->date();
        $Activity_date = "$year-$month-$day";
    	},
    )->pack();
  }
  
# sub for resetting values (create new activity)
  sub newActivity {
      use strict;
      use warnings;
    our $tournumber = our $C_TOURNBR;
    our $number->configure(-text => join(' ', our $L_TOUR, $C_TOURNBR));
    $Goal = our $C_GOAL;
    $sel_type = our $C_TYPE;
    $Activity_date = our $C_DATE;
    $location = our $C_LOCATION;
    $distance_hm = our $C_DISTANCE_HM;
    $distance_km = our $C_DISTANCE_KM;
    $Start_time = our $C_START_TIME;
    $interTime = our $C_INTER_TIME;
    $endTime = our $C_TOTAL_TIME;
    $chart->destroy if Tk::Exists($chart); 
    $beschreibung->Contents(our $T_DESCRIPTION);
    $begleitung->Contents(our $T_BEGLEITUNG);
    $kommentar->Contents(our $T_COMMENT);
    our @interTimes = ($C_INTER_TIME); 
    $file->configure(-text => our $T_TRACKFILE);
    our $trackpath=our $C_TRACK_PATH;
    our @picFiles = our @C_PIC_FILES;
    our $tlist->delete(0,'end');
    our $startlat = our $C_STARTLAT;
    our $startlon = our $C_STARTLON;
    our $plot_unit = our $C_PLOT_UNIT_X;
    our @lats = our @C_LATS;
    our @lons = our @C_LONS;
    our @eles = our @C_ELES;
    return;
  }
  
# sub for opening existing activity
  sub openActivity {
      use strict;
      use warnings;
    our @entries;
    our @selected_items;
    openTour();
  }
  
# sub for closeing
  sub closeing {
      use strict;
      use warnings;
      clean();
      exit;
  }  
# sub to clean up temp
  sub clean {
      use strict;
      use warnings;
      rmtree(join('',$FindBin::Bin, our $G_TMP_PATH));
  }
  
# sub to load existing tour
  sub loadTour {
      use strict;
      use warnings;
    our $tournumber = $_[0];
    our $number->configure(-text => join(' ', our $L_TOUR ,$tournumber));
    
    # -------------------------------------------------------------------------- Read Tour
    
    # MySQL database configurations
    my $dsn = join('',"DBI:SQLite:dbname=", our $G_DB_PATH);
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my @tours;
    
    # read data from the table
    my $sql = join('',"SELECT date, kind, goal, place, distance_hm, distance_km, start_time, active_time, total_time, companionship, text, comment, lat, lon FROM tours WHERE link_id ==", $tournumber);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        $Goal = $row[2];
        $Activity_date = $row[0];
        # get overwritten if OK is pressed in Location selection window
        if (! defined $row[12]){
            our $startlat = '';
            our $startlon = '';
        }else {
            our $startlat = $row[12];
            our $startlon = $row[13];
        }
    }
    
    
    # read Trackfile
    $chart->destroy if Tk::Exists($chart); 
    our $trackpath=join('', our $G_TRAW_PATH, $Activity_date,'_', $Goal,'.FIT');
    if (-f $trackpath){
        $file->configure(-text => $trackpath);
        readFIT();
    }else{
        $trackpath=join('',$G_TRAW_PATH ,$Activity_date,'_', $Goal,'.gpx');
        if (-f $trackpath){
            $file->configure(-text => $trackpath);
            readFIT();
        }else{
            $file->configure(-text => our $T_TRACKFILE);
            $trackpath = '';
        }
    }
    # overwrite readFit with old values of DB
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        our $Goal = $row[2];
        our $sel_type = $row[1];
        our $Activity_date = $row[0];
        our $location = $row[3];
        our $distance_hm = $row[4];
        our $distance_km = $row[5];
        our $Start_time = $row[6];
        our @interTimes = ($row[7]); 
        our $interTime = $row[7];
        our $endTime = $row[8]; 
        our $beschreibung->Contents($row[10]);
        our $begleitung->Contents($row[9]);
        our $kommentar->Contents($row[11]);
    }
    
    # disconnect from the MySQL database
    $dbh->disconnect();
    #get Pictures
    my $directory = join('',our $G_IMG_PATH, $Activity_date,'_', $Goal);
    if (-e $directory){
      opendir DIR, $directory;
      our @picFiles = grep { $_ ne '.' && $_ ne '..' && $_ !~ m/.ini/} readdir DIR;
      closedir DIR;
      $tlist->delete(0,'end');
      my $i = 0;
      foreach my $pic ( @picFiles ) {
        $pic=join('', $G_IMG_PATH, $Activity_date,'_', $Goal,'/',$pic);
        my $item = substr($pic, -20);
         $tlist->insert('end',
          -itemtype => 'imagetext',
          -image => $folderpicture,
          -text => "$item",
        );
        @picFiles[$i] = $pic;
        $i++;
      }
    }else{
        $tlist->delete(0,'end');
        our @picFiles= our @C_PIC_FILES;
    }
  }
  
  sub about {
    use strict;
    use warnings;
    use Tk;
    use Tk::ROText;
    my $aboutWindow = our $mw->Toplevel (-title => our $L_AD_TITLE);  
    my $some_text = our $T_AD_TEXT;
    my $rot = $aboutWindow->ROText(
    	-width => 150,
    	-height => 10,
    	-wrap => 'word',
    )->pack();
$rot->insert("end", $some_text);
  }
  
exit(0);
