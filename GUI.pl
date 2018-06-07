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
  our @interTimes = ('00:00:00');                                               # selectionvalues for intermediate time   
  our @tracktimes;
  our @eles;
  our @lats = ();
  our @lons = ();
  our $tick;
  our $elevationout='';
  our $xdistance; # for Plotpreview
  our $tournumber = 'XX';
  our $startlat ='';
  our $startlon ='';
  our $plot_unit = 'time';
    
# defining main window
  our $mw = Tk::MainWindow->new(-title => 'Tourenverzeichnis');
  # Groeße des Fensters:
  my      $windowHeight       = 650;
  my      $windowWidth        = 1200;
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
  $mw->minsize(400, 300);
  
  # cleanup before closing
  $mw->protocol('WM_DELETE_WINDOW' => \&closeing, );

# oberes Auswahlmenue
  my $menuitems = [
      [Cascade => "Datei", -menuitems =>
          [
              [Button => "Neu", -command => \&newActivity],
              [Separator => ""],
              [Button => "Öffnen", -command => \&openActivity],
              [Button => "Speichern", -command => \&save],
          ],
      ],
      [Cascade => "Info", -menuitems =>
          [
              [Button => "About", -command => \&about],
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
  	-text => 'Höhenprofil',  
  )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "bottom");
  
# Beschreibung und Kommentar  
  my $BeschruKommen = $bottomright->Labelframe(
      -width => 100,
      -height => 200,
  	-text => 'Beschreibung und Kommentar',
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
  $beschreibung->insert('end',"Hier Beschreibung eingeben...");
  
  our $begleitung = $textmid->Scrolled('Text',-scrollbars => 'e', -wrap => 'word',)->pack(-fill => 'both', -expand => 1,);
  $begleitung->insert('end',"Hier Begleitung eingeben...");
  
  our $kommentar = $textbottom->Scrolled('Text',-scrollbars => 'e', -wrap => 'word',)->pack(-fill => 'both', -expand => 1,);
  $kommentar->insert('end',"Hier Kommentar eingeben...");
  
  my $writeTourButton = $bottomright->Button(
        -text => "Tour speichern",
        -command => \&save,
        -background => 'green',
    )->pack(-fill => 'both', -expand => 0,);
    
# Eigenschaften
  my $f_details = $topleft->Labelframe(
      -width => 75,
      -height => 100,
  	-text => 'Details',
  )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
  # Filemanager
    my $f_select = $topleft->Labelframe(
        -width => 100,
        -height => 100,
    	-text => 'Trackdatei',  
    )->pack(-padx => 5, -pady => 5, -fill => 'both', -expand => 1, -side => "top");
    my $file = $f_select->Label(
        -text => 'Falls kein Track existiert leer lassen.',
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -expand => 1, -side => 'left',);
    my $file_select = $f_select->Button(
        -text => "Track auswählen \n Support für mehrere Tracks fehlt noch",
        -command => \&show_file_dialog,
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -side => 'left',);
    our $trackpath='';
    my $readFitButton = $f_select->Button(
        -text => "Track einlesen",
        -command => \&readFIT,
    )->pack(-padx => 5, -pady => 5, -fill => 'x', -side => 'left',);
  # Attribute input
    # Name
      our $Goal = '';
      my $name = $f_details->Label(
          -text => 'Ziel:',
      )->grid(-row=>'0', -column=>'0', -padx => 5, -pady => 5, );
      my $name_inp = $f_details->Entry(-textvariable => \$Goal, -width => 100,)->grid(-row=>'0', -column=>'1', -columnspan=>'5', -padx => 5, -pady => 5, );
      our $number = $f_details->Label(
          -text => 'Tour: XX',
      )->grid(-row=>'0', -column=>'6', -padx => 5, -pady => 5, );
    # Type
      my $type = $f_details->Label(
          -text => 'Art:',
      )->grid(-row=>'1', -column=>'0', -padx => 5, -pady => 5, );
      my @types = ('Skitour', 'Bergsteigen', 'Rennrad', 'Telemark-Skitour', 'Klettersteig', 'Wandern', 'Mountainbike', 'Wandern-Zipfelbob');
      our $sel_type = 'Skitour';
      my $type_inp = $f_details->JComboBox(
     -entrybackground => 'white',
     -mode => 'editable',
     -relief => 'sunken',
     -choices => \@types, 
     -textvariable => \$sel_type)->grid(-row=>'1', -column=>'1', -padx => 5, -pady => 5, );
    # Date
      my $date = $f_details->Label(
          -text => 'Datum (JJJJ-MM-TT):',
      )->grid(-row=>'1', -column=>'2', -padx => 5, -pady => 5, );
      our $Activity_date = '';
      my $date_inp = $f_details->Entry(-textvariable => \$Activity_date
      )->grid(-row=>'1', -column=>'3', -padx => 5, -pady => 5, );
      my $cal_pic = $mw->Photo(-file => "$FindBin::Bin/PICs/Calendar.jpg");
      my $b_ok = $f_details->Button(
      	#-text => "Select Date",
        -image => $cal_pic,
      	-command => \&selectDate,
      )->grid(-row=>'1', -column=>'4', -padx => 5, -pady => 5, );
    # Location
    our $location='';
      my $loc = $f_details->Label(
          -text => 'Ort:',
      )->grid(-row=>'2', -column=>'0', -padx => 5, -pady => 5, );
      our $loc_inp = $f_details->Entry(-textvariable => \$location)->grid(-row=>'2', -column=>'1', -padx => 5, -pady => 5, );
      $loc_inp->bind('<ButtonPress>'    , \&locationSelect);
      my $childPID;
      $loc_inp->bind('<Key-Return>'     , sub{
                                                searchLocation();
                                          });
    # Distance
      my $dist = $f_details->Label(
          -text => 'Distanz:',
      )->grid(-row=>'2', -column=>'2', -padx => 5, -pady => 5, );
      our $distance='';
      my $dist_inp = $f_details->Entry(-textvariable => \$distance)->grid(-row=>'2', -column=>'3', -padx => 5, -pady => 5, );
      our $distance_unit = 'hm';
      my $distance_unit_radio_hm = $f_details->Radiobutton(-text => 'hm', -value => 'hm', -variable => \$distance_unit,)->grid(-row=>'2', -column=>'4', -padx => 5, -pady => 5, );
      my $distance_unit_radio_km = $f_details->Radiobutton(-text => 'km', -value => 'km', -variable => \$distance_unit,)->grid(-row=>'2', -column=>'5', -padx => 5, -pady => 5, );
    # Start_Time
      my $s_time = $f_details->Label(
          -text => 'Startzeit (hh:mm:ss):',
      )->grid(-row=>'3', -column=>'0', -padx => 5, -pady => 5, );
      our $Start_time = '';
      my $s_time_inp = $f_details->Entry(-textvariable => \$Start_time)->grid(-row=>'3', -column=>'1', -padx => 5, -pady => 5, );
    # Inter_Time
      my $i_time = $f_details->Label(
          -text => 'Aufstieg (hh:mm:ss):',
      )->grid(-row=>'3', -column=>'2', -padx => 5, -pady => 5, );
      our $interTime = '00:00:00';
      my $i_time_inp = $f_details->JComboBox(
     -entrybackground => 'white',
     -mode => 'editable',
     -relief => 'sunken',
     -choices => \@interTimes,
     -textvariable => \$interTime,
  )->grid(-row=>'3', -column=>'3', -padx => 5, -pady => 5, );
    # End_Time
      my $e_time = $f_details->Label(
          -text => 'Gesamtzeit (hh:mm:ss):',
      )->grid(-row=>'3', -column=>'4', -padx => 5, -pady => 5, );
      our $endTime = '';
      my $e_time_inp = $f_details->Entry(-textvariable => \$endTime)->grid(-row=>'3', -column=>'5', -padx => 5, -pady => 5, );
      
# Bilderauswahl
  our $tlist = $topright->Scrolled('TList',
  	-scrollbars => 'os',
  	-orient => 'vertical',
  )->pack(-fill => 'both', -expand => 1,);
  my $folderpicture = $topright->Photo(-file => "$FindBin::Bin/PICs/PIC.png");
  
  our @picFiles = '-';
  
  my $selectPICs = $topright->Button(
    -text => "Bilder auswählen",
    -command => \&selPics,
  )->pack();

# Speicherdialog
  my $saveDialog = $mw->Dialog(
  	-title => 'Info zum Speichervorgang',
  	-text => "Sollten Datum und Name mit einer anderen Tour identisch sein, so werden Bilder und Tracks überschrieben.
      Bist du dir sicher, dass du mit dem Speichern fortfahren möchtest?",
  	-bitmap => 'warning',
  	-buttons => ['Ja', 'Nein'],
  	-default_button => 'Nein',
  );
# Enddialog
  our $finishDialog = $mw->Dialog(
  	-title => 'Info zum Speichervorgang',
  	-text => "Eintrag wurde gespeichert.\n Soll das PDF erstellt werden?",
  	-bitmap => 'info',
  	-buttons => ['Ja', 'Nein'],
  	-default_button => 'Ja',
  );
# Saving failed dialog
  our $DataDialog = $mw->Dialog(
  	-title => 'Info zum Speichervorgang',
  	-text => 'Es fehlen Informationen zu diesem Eintrag. Bitte ergänzen und erneut speichern.',
  	-bitmap => 'error',
  	-buttons => ['Ok'],
  	-default_button => 'Ok',
  );
  
# Toolbar
  my $tb = $mw->ToolBar(
  	-movable => 0, 
  	-side => 'top', 
  );
  my $save_pic = $mw->Photo(-file => "$FindBin::Bin/PICs/SAVE.png");
  my $generate_pic = $mw->Photo(-file => "$FindBin::Bin/PICs/RUN.png");
  $tb->ToolButton( -image   => 'filenew22',
                    -tip     => 'neue Tour anlegen',
                    -command => \&newActivity);
  $tb->ToolButton( -image   => 'fileopen22',
                    -tip     => 'Tour öffnen',
                    -command => \&openActivity);
  $tb->ToolButton( -image   => $save_pic,
                    -tip     => 'Tour speichern',
                    -command => \&save);
  $tb->ToolButton( -image   => $generate_pic,
                    -tip     => 'PDF erstellen',
                    -command => \&generatePDF);

# Statusbar --------------------------------------------------------------------
    
    our ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter) = getStatus();

    my $sb= $mw->StatusBar();
    $sb->addLabel(
        -relief         => 'flat',
        -text           => join('', 'Jahresüberblick ', $status_year, ' (Winter ', $status_winter, ' bei Skitouren)'),
        );
    $sb->addLabel(
        -text           => join(' ','Touren gesamt: ',$status_total),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ','Skitouren: ',$status_ski),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ','Radtouren: ',$status_bike),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ','Wanderungen: ',$status_mountain),
        -anchor         => 'center',
        -width          => '25',
        );
    $sb->addLabel(
        -text           => join(' ','Klettern: ',$status_klettern),
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
          ["All track files",    [qw/.fit .FIT .gpx .GPX/]],
          ["All files",           ['*']],
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
    -xlabel     => 'Zeit o. Distanz',
    -ylabel     => 'Höhe',
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
    if( $save_response eq 'Ja' ) {
      our $bgl = $begleitung->get('1.0', 'end');
      our $bschr = $beschreibung->get('1.0', 'end');
      our $com = $kommentar->get('1.0', 'end');
	  saveTour($Activity_date, $sel_type, $Goal, $location, $distance, $distance_unit, forcehhmmss($Start_time), forcehhmmss($interTime), forcehhmmss($endTime), $bgl, $bschr, $com);
	}elsif ( $save_response eq 'Nein' ) {
      print "Der Speichervorgang wurde abgebrochen.\n";
    }
      
  }

# sub for selectiong corresponding PICs  
  sub selPics {
      use strict;
      use warnings;
     my @types = (
       ['Pictures',       ['.jpeg', '.JPEG', '.jpg', '.JPG', '.png', '.PNG', '.gif', '.GIF']],
       ["All files",           ['*']]
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
    	-text => "Ok",
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
    our $tournumber = 'XX';
    our $number->configure(-text => join(' ', 'Tour: ','XX'));
    $Goal = '';
    $sel_type = 'Skitour';
    $Activity_date = '';
    $location = '';
    $distance = '';
    $distance_unit = 'hm';
    $Start_time = '';
    $interTime = '00:00:00';
    $endTime = '';
    $chart->destroy if Tk::Exists($chart); 
    $beschreibung->Contents("Hier Beschreibung eingeben...");
    $begleitung->Contents("Hier Begleitung eingeben...");
    $kommentar->Contents("Hier Kommentar eingeben...");
    our @interTimes = ('00:00:00'); 
    $file->configure(-text => "Falls kein Track existiert leer lassen.");
    our $trackpath='';
    our @picFiles = '-';
    our $tlist->delete(0,'end');
    our $startlat ='';
    our $startlon ='';
    our $plot_unit = 'time';
    our @lats = ();
    our @lons = ();
    our @eles = ();
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
    rmtree(join('',$FindBin::Bin,"/tmp"));
    exit;
  }  
# sub to clean up temp
  sub clean {
      use strict;
      use warnings;
    rmtree(join('',$FindBin::Bin,"/tmp"));
  }
  
# sub to load existing tour
  sub loadTour {
      use strict;
      use warnings;
    our $tournumber = $_[0];
    our $number->configure(-text => join(' ', 'Tour: ',$tournumber));
    
    # -------------------------------------------------------------------------- Read Tour
    
    # MySQL database configurations
    my $dsn = "DBI:SQLite:dbname=data/Tourenverzeichnis.sqlite3";
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my @tours;
    
    # read data from the table
    my $sql = join('',"SELECT date, kind, goal, place, distance, unit, start_time, active_time, total_time, companionship, text, comment, lat, lon FROM tours WHERE link_id ==", $tournumber);
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
    our $trackpath=join('','./tracks/raw/',$Activity_date,'_', $Goal,'.FIT');
    if (-f $trackpath){
        $file->configure(-text => $trackpath);
        readFIT();
    }else{
        $trackpath=join('','./tracks/raw/',$Activity_date,'_', $Goal,'.gpx');
        if (-f $trackpath){
            $file->configure(-text => $trackpath);
            readFIT();
        }else{
            $file->configure(-text => "Falls kein Track existiert leer lassen.");
        }
    }
    # overwrite readFit with old values of DB
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        our $Goal = $row[2];
        our $sel_type = $row[1];
        our $Activity_date = $row[0];
        our $location = $row[3];
        our $distance = $row[4];
        our $distance_unit = $row[5];
        our $Start_time = $row[6];
        our $interTime = $row[7];
        our $endTime = $row[8]; 
        our $beschreibung->Contents($row[10]);
        our $begleitung->Contents($row[9]);
        our $kommentar->Contents($row[11]);
    }
    
    # disconnect from the MySQL database
    $dbh->disconnect();
    #get Pictures
    my $directory = join('','./Bilder/',$Activity_date,'_', $Goal);
    if (-e $directory){
      opendir DIR, $directory;
      our @picFiles = grep { $_ ne '.' && $_ ne '..' && $_ !~ m/.ini/} readdir DIR;
      closedir DIR;
      $tlist->delete(0,'end');
      my $i = 0;
      foreach my $pic ( @picFiles ) {
        $pic=join('','./Bilder/',$Activity_date,'_', $Goal,'/',$pic);
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
        our @picFiles='-';
    }
  }
  
  sub about {
    use strict;
    use warnings;
    use Tk;
    use Tk::ROText;
    my $aboutWindow = our $mw->Toplevel (-title => 'Programminformation');  
    my $some_text = "Diese Implementierung ist in Perl geschrieben."
    . "Neben einigen Perl-Modulen wurden folgende Elemente verwendet, auf deren"
    . " Quellen hier hingewiesen wird:\n"
    . "* Geonames.org (Lizenz: https://creativecommons.org/licenses/by/3.0/us/deed.de)\n"
    . "* Icons (Quellen: http://www.iconarchive.com/show/pretty-office-7-icons-by-custom-icon-design/Calendar-icon.html;\n"
    . "                  https://commons.wikimedia.org/wiki/File:Picture_icon-72a7cf.svg;\n"
    . "                  http://www.clker.com/clipart-running-icon-on-transparent-background-5.html;\n"
    . "                  https://www.iconsdb.com/soylent-red-icons/save-icon.html\n"
    . "        (Lizenzen: https://creativecommons.org/publicdomain/zero/1.0/; \n"
    . "                   https://creativecommons.org/licenses/by-nd/3.0/\n"
    . "* Garmin-FIT (Lizenz: https://github.com/mrihtar/Garmin-FIT/blob/master/LICENSE_LGPL_v2.1.txt)";
    my $rot = $aboutWindow->ROText(
    	-width => 150,
    	-height => 10,
    	-wrap => 'word',
    )->pack();
$rot->insert("end", $some_text);
  }
  
exit(0);
