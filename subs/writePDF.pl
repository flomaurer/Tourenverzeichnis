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
        -txt1 => our $T_WD_PDF_TEXT1,
	    -txt2 => our $T_WD_PDF_TEXT2, #default would be 'Please Wait'
        -title => our $L_WD_PDF_TITE,
    );
#    $wd->configure(-foreground => 'blue',-background => 'white');
#    $wd->configure(-cancelroutine => sub {
#    	print "\nI'm canceling....\n";
#    	$wd->unShow;
#    });

    # Finishdialog
    my $finishDialog = $mw->Dialog(
    	-title => our $L_FD_PDF_TITLE,
    	-text => our $T_FD_PDF_TEXT,
    	-bitmap => 'info',
    	-buttons => [our $B_YES, our $B_NO],
    	-default_button => $B_YES,
    );
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Read DB
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    readDBpdf($_[0], $_[1], $_[2], $_[3], $_[4]);
   
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Call PERLTEX
    move(join('',our $G_DBG_PATH,"Tourenverzeichnis.aux"), "Tourenverzeichnis.aux") ;
    move(join('', $G_DBG_PATH,"Tourenverzeichnis.log"), "Tourenverzeichnis.log") ;
    move(join('', $G_DBG_PATH,"Tourenverzeichnis.out"), "Tourenverzeichnis.out") ;
    move(join('', $G_DBG_PATH,"Tourenverzeichnis.synctex.gz"), "Tourenverzeichnis.synctex.gz") ;
    move(join('', $G_DBG_PATH,"Tourenverzeichnis.toc"), "Tourenverzeichnis.toc") ;
        
    $wd->Show();
    sleep(0.5); #(to finish reading DB)
    system("pdflatex.exe",' -synctex=1 -interaction=nonstopmode "./subs/Tourenverzeichnis".tex');
    system("pdflatex.exe",' -synctex=1 -interaction=nonstopmode "./subs/Tourenverzeichnis".tex'); # for a correct table of contents
    $wd->unShow();
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ move Texfiles for debugging
    move("Tourenverzeichnis.aux", join('', $G_DBG_PATH,"Tourenverzeichnis.aux")) or die "Copy failed: $!";
    move("Tourenverzeichnis.log", join('', $G_DBG_PATH,"Tourenverzeichnis.log")) or die "Copy failed: $!";
    move("Tourenverzeichnis.out", join('', $G_DBG_PATH,"Tourenverzeichnis.out")) or die "Copy failed: $!";
    move("Tourenverzeichnis.synctex.gz", join('', $G_DBG_PATH,"Tourenverzeichnis.synctex.gz")) or die "Copy failed: $!";
    move("Tourenverzeichnis.toc", join('', $G_DBG_PATH,"Tourenverzeichnis.toc")) or die "Copy failed: $!";
    copy("Tourenverzeichnis.pdf", join('', $G_DBG_PATH,"Tourenverzeichnis.pdf")) or die "Copy failed: $!";
    
    my $finish=$finishDialog->Show();
    if( $finish eq $B_YES ) {
        system("Tourenverzeichnis.pdf");
    }
    #system("perl",'GUI.pl');
    #exit;
    return(1);
}
1;