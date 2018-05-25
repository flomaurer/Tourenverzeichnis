#!/usr/bin/perl
sub selectAttributes{
      use strict;
      use warnings;
    use Tk;
    use Tk::Spinbox;
    use Tk::JComboBox;
    
    our $selectWindow = our $mw->Toplevel (-title => 'Auswahl der Touren fürs PDF');  
    
    # YEAR
    my $yearlabel = $selectWindow->Label(
        -text => 'Jahr:',
        )->grid(-row=>'0', -column=>'0', -padx => 5, -pady => 5, );
    our $sel_year = 2018;
    my $yearselect = $selectWindow->Spinbox(
        -from => 2000,
        -to   => 2200,
        -textvariable => \$sel_year,
        -increment => 1,
        )->grid(-row=>'0', -column=>'1', -padx => 5, -pady => 5, );
    
    # TYPE
    my $typelabel = $selectWindow->Label(
        -text => 'Art:',
        )->grid(-row=>'0', -column=>'2', -padx => 5, -pady => 5, );
    my @types = ('Skitour', 'Bergsteigen', 'Rennrad', 'Klettersteig', 'Wandern', 'Mountainbike');
    our $sel_kind = '';
    my $type_inp = $selectWindow->JComboBox(
       -entrybackground => 'white',
       -mode => 'editable',
       -relief => 'sunken',
       -choices => \@types, 
       -textvariable => \$sel_kind
       )->grid(-row=>'0', -column=>'3', -padx => 5, -pady => 5, );
    
    #NAME
    our $sel_Goal = '';
    my $namelabel = $selectWindow->Label(
        -text => 'Ziel:',
        )->grid(-row=>'0', -column=>'4', -padx => 5, -pady => 5, );
    my $name_inp = $selectWindow->Entry(
        -textvariable => \$sel_Goal, 
        -width => 20,
        )->grid(-row=>'0', -column=>'5', -padx => 5, -pady => 5, );
      
        
    my $b_ok = $selectWindow->Button(
      	-text => "OK",
      	-command => \&Enter,
      )->grid(-row=>'1', -column=>'0', -columnspan=>'6', -padx => 5, -pady => 5, );
    
   
}

sub Enter {
      use strict;
      use warnings;
    require "./subs/writePDF.pl";

    our ($sel_year, $sel_kind, $sel_Goal);
     #++++++++++++++++++++ PROCESSING
    if ($sel_year eq '') {
        $sel_year = "'%'";
    }else{
        $sel_year = join('',"'",$sel_year,"%'");
    }
    if ($sel_kind eq '') {
        $sel_kind = "'%'";
    }else{
        $sel_kind = join('',"'%",$sel_kind,"%'");
    }
    if ($sel_Goal eq '') {
        $sel_Goal = "'%'";
    }else{
        $sel_Goal = join('',"'%",$sel_Goal,"%'");
    }
    
    our $selectWindow->withdraw();
    writePDF($sel_year, $sel_kind, $sel_Goal);
}

1;
