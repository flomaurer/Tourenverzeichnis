sub setupWritePDF{
      use strict;
      use warnings;
    require "./subs/selectAttributes.pl";

    our ($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance);
    selectAttributes();
    
}
sub writePDF{
    use 5.010;
    use strict;
    use warnings;
    require "./subs/readDBforPDF.pl";
    
    use Tk::WaitBoxFixed;
    use File::Copy;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Setup Dialogs
    my $wd = our $mw->WaitBoxFixed(
        -bitmap =>'hourglass',
        -txt1 => "Das Erstellen des PDFs dauert noch an.",
	    -txt2 => 'Sollte es ungewöhnlich lange dauern, überprüfe deine Internetverbindung.', #default would be 'Please Wait'
        -title => 'PDF wird erstellt',
    );
#    $wd->configure(-foreground => 'blue',-background => 'white');
#    $wd->configure(-cancelroutine => sub {
#    	print "\nI'm canceling....\n";
#    	$wd->unShow;
#    });

    # Finishdialog
    my $finishDialog = $mw->Dialog(
    	-title => 'Info zum PDF',
    	-text => "Das PDF des Tourenbuchs wurde erstellt. Soll es geoeffnet werden?",
    	-bitmap => 'info',
    	-buttons => ['Ja', 'Nein'],
    	-default_button => 'Ja',
    );
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Read DB
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    readDBpdf($_[0], $_[1], $_[2], $_[3], $_[4]);
   
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Call PERLTEX
    move("./dbg/Tourenverzeichnis.aux", "Tourenverzeichnis.aux") ;
    move("./dbg/Tourenverzeichnis.log", "Tourenverzeichnis.log") ;
    move("./dbg/Tourenverzeichnis.out", "Tourenverzeichnis.out") ;
    move("./dbg/Tourenverzeichnis.synctex.gz", "Tourenverzeichnis.synctex.gz") ;
    move("./dbg/Tourenverzeichnis.toc", "Tourenverzeichnis.toc") ;
        
    $wd->Show();
    sleep(0.5); #(to finish reading DB)
    system("pdflatex.exe",' -synctex=1 -interaction=nonstopmode "./subs/Tourenverzeichnis".tex');
    system("pdflatex.exe",' -synctex=1 -interaction=nonstopmode "./subs/Tourenverzeichnis".tex'); # for a correct table of contents
    $wd->unShow();
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ move Texfiles for debugging
    move("Tourenverzeichnis.aux", "./dbg/Tourenverzeichnis.aux") or die "Copy failed: $!";
    move("Tourenverzeichnis.log", "./dbg/Tourenverzeichnis.log") or die "Copy failed: $!";
    move("Tourenverzeichnis.out", "./dbg/Tourenverzeichnis.out") or die "Copy failed: $!";
    move("Tourenverzeichnis.synctex.gz", "./dbg/Tourenverzeichnis.synctex.gz") or die "Copy failed: $!";
    move("Tourenverzeichnis.toc", "./dbg/Tourenverzeichnis.toc") or die "Copy failed: $!";
    copy("Tourenverzeichnis.pdf", "./dbg/Tourenverzeichnis.pdf") or die "Copy failed: $!";
    
    my $finish=$finishDialog->Show();
    if( $finish eq 'Ja' ) {
        system("Tourenverzeichnis.pdf");
    }
    #system("perl",'GUI.pl');
    #exit;
    return(1);
}
1;