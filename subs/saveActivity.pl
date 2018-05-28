sub saveTour{
  use 5.010;
  use strict;
  use warnings;
  use DBI;
  use FindBin;
  use File::Copy;
  use Tk::Dialog;
  use Text::CSV_XS;
  
  require "./subs/tex.pl";
  require "./subs/picture_progressing.pl";
  require "./subs/downloadosmtracktile.pl";
  
  my $tourname = join('',$_[0],"_",$_[2]);
  
  my $map ='';
  my $gpxout = '';
  my ($scale, $latmin, $latmax, $lonmin, $lonmax);
  
# COPY PICs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  our @picFiles;
  my @picInit = '-';
  my ($pic_nr_one, $pic_nr_one_rotation, $pic_nr_two, $pic_nr_two_rotation);
  my $pic_amount;
  my $PICfolder;
  # proove if PICs are selected
  if (@picFiles eq @picInit){
    $pic_amount = 0;
  } else {                                           
    $PICfolder = join('',"$FindBin::Bin/Bilder","/",$tourname);
    mkdir($PICfolder);
    foreach my $PIC (@picFiles) {
        if (-f $PIC) {} else {
            copy("$PIC","$PICfolder") or die "Copy failed: $!";
        }
    }
    
    # select PICs and extract rotation
    ($pic_nr_one, $pic_nr_one_rotation, $pic_nr_two, $pic_nr_two_rotation)=Pic_progress();
    $pic_nr_one = join ("",$PICfolder,$pic_nr_one);
    $pic_nr_two = join ("",$PICfolder,$pic_nr_two);
    
    # proove if they are different
    if ($pic_nr_one eq $pic_nr_two) {
        $pic_amount = 1;
    }else {
        $pic_amount = 2;
    }
  }

# COPY / PROCESS + WRITE TRACK +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (our $trackpath ne ''){
    our @tracktimes;
    if ($trackpath =~ /.fit/ | $trackpath =~ /.FIT/){
        copy($trackpath, "$FindBin::Bin/tracks/raw/$tourname.FIT") or die "Copy failed: $!";
    }else{
        copy($trackpath, "$FindBin::Bin/tracks/raw/$tourname.gpx") or die "Copy failed: $!";
    }
    
    #write CSV for elevation pgfplot 
    our $elevationout = "$FindBin::Bin/tracks/src/$tourname.csv";
    my $csv1 = Text::CSV_XS->new ({ binary => 1, eol => $/, sep_char => "\t" });
    open my $fh, ">", $elevationout or die "$elevationout: $!";
    my $i=0;
    our @eles;
    for (@tracktimes) {
        $csv1->print ($fh, [$tracktimes[$i], $eles[$i]]) or $csv1->error_diag;
        $i++;
    }
    close $fh;
    
    our $tick= $tracktimes[scalar @tracktimes -1]/10;
    
    # PROCESS GPX-POSITIONS ---------------------------
    our @lons = grep {$_} @lons;
    our @lats = grep {$_} @lats;
    
    # bring in by tex supported range
    if (scalar @lons != 0) {
      foreach my $x (@lons) { $x = $x * 100; }
      foreach my $x (@lats) { $x = $x * 100; }
      ($lonmin, $lonmax) = minmax @lons;
      ($latmin, $latmax) = minmax @lats;
      if (($lonmax-$lonmin)>=($latmax-$latmin)){
        $scale= ($lonmax-$lonmin);
      }
      else{
        $scale = ($latmax-$latmin);
      }
      
      # prove internetconnection
      #my $ping = Net::Ping->new("tcp");
      #$ping->port_number("80");
      #if ( $ping->ping( 'www.google.com', '10' ) ) {
          # download OSM-tiles and generate tex-code to plot
          $map=downloadosmtracktile($latmin, $latmax, $lonmin, $lonmax, 0);
      #} else {
      #  my $noMapDialog = our $mw->Dialog(
      #  	-title => 'Info zum Speichervorgang',
      #  	-text => "Es konnte kein Kartenmaterial heruntergeladen werden.
#Bitte überprüfe deine Internetverbindung und update diesen Eintrag gegebenfalls.
#Das Speichern wird ohne Kartenmaterial fortgesetzt.",
#        	-bitmap => 'error',
#        	-buttons => ['OK'],
#        	-default_button => 'OK',
#        );
#        $noMapDialog->Show();
#      }
    
    # WRITE GPX-POSITONS
      $gpxout = "$FindBin::Bin/tracks/src/$tourname.gpx.csv";
      open my $fh, ">", $gpxout or die "$gpxout: $!";
      $i=0;
      for (@lats) {
        $csv1->print ($fh, [ $lons[$i], $lats[$i] ]) or $csv1->error_diag;
        $i++;
      }
      close $fh; 
    }
    
    sleep(0.5); # to wait till all files are writeable again
    clean(); # clean up tmp
  }
  
  
# Generate TEX +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #generate TexCode
  my $tex = tex($pic_amount, $pic_nr_one, $pic_nr_one_rotation, $pic_nr_two, $pic_nr_two_rotation, $PICfolder, $map, $scale, $latmin, $latmax, $lonmin, $lonmax, $gpxout);       # Texcode

# WRITE TO DATABASE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
  # MySQL database configurations
  my $dsn = "DBI:SQLite:dbname=data/Tourenverzeichnis.sqlite3";
  my $username = "";
  my $password = '';
   
  
  # prove if data valid
  if ($_[0] eq '' | $_[1] eq '' | $_[2] eq '' | $_[3] eq '' | $_[5] eq ''){
    our $DataDialog->Show();
  }else {
  
    # remove standard text    
    my $besch = $_[10];
    $besch =~ s/Hier Beschreibung eingeben...//g;
    my $ct = $_[11];
    $ct =~ s/Hier Kommentar eingeben...//g;
    my $cs = $_[9];
    $cs =~ s/Hier Begleitung eingeben...//g;
   
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
    
    our $tournumber;
    if ($tournumber !~ m/[0-9]{1,4}/) {
        # insert data into the table
        my $sql = "INSERT INTO tours (date,kind,goal,place,distance,unit,start_time,active_time,total_time,companionship,text,comment,tex,lat,lon)
            VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
         
        my $stmt = $dbh->prepare($sql);
         
        # execute the query  
        if($stmt->execute($_[0], $_[1], $_[2],$_[3],$_[4],$_[5],$_[6],$_[7],$_[8],$cs,$besch,$ct,$tex,our $startlat,our $startlon)){
          say "Done";
          my $finish_response=our $finishDialog->Show();
          newActivity();
          if( $finish_response eq 'Ja' ) {
      	     generatePDF();
          }
        }
           
        $stmt->finish();
    } else {
        # update tour entry in table
        my $sql = "UPDATE tours SET date =?, kind =?, goal =?, place =?, distance =?, unit =?, start_time =?, active_time =?, total_time =?, companionship =?, text =?, comment =?, tex =? WHERE link_id == $tournumber";
         
        my $stmt = $dbh->prepare($sql);
         
        # execute the query  
        if($stmt->execute($_[0], $_[1], $_[2],$_[3],$_[4],$_[5],$_[6],$_[7],$_[8],$_[9],$_[10],$_[11],$tex)){
          say "Done";
          my $finish_response=our $finishDialog->Show();
          newActivity();
          if( $finish_response eq 'Ja' ) {
      	     generatePDF();
          }
        }
           
        $stmt->finish();
    }
     
    # disconnect from the MySQL database
    $dbh->disconnect();
  } 
  
    
  return(0);
}
1;
