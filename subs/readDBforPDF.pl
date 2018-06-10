sub readDBpdf{
      use strict;
      use warnings;
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    my ($date, $kind, $goal, $maxdistance, $mindistance) = @_;
    
    # MySQL database configurations
    my $dsn = join('',"DBI:SQLite:dbname=", our $G_DB_PATH);
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my %tours;
    
    # read data from the table
    my $sql = join('',"SELECT date, start_time, goal, tex FROM tours WHERE date LIKE ",$date, " AND kind LIKE ", $kind, ' AND goal LIKE ',$goal);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        #printf "$row[0]\n";
        $tours{join(':', $row[0], $row[1], $row[2])} = $row[3];
    }
    
    
    # Generate Overview
    our ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter);
    my $ski = join(' & ',substr($status_ski,0, index($status_ski,' ')), substr($status_ski, index($status_ski, '(')+1, -3));
    my $bike = join(' & ',substr($status_bike,0, index($status_bike,' ')), substr($status_bike, index($status_bike, '(')+1, -3));
    my $mountain = join(' & ',substr($status_mountain,0, index($status_mountain,' ')), substr($status_mountain, index($status_mountain, '(')+1, -3));
    my $klettern = $status_klettern;
    our @T_OV_TEX;
    my $overview = join('','\begin{center}{\Large \textbf{ ',$T_OV_TEX[0] ,$status_year,'\footnote{',$T_OV_TEX[1] ,$status_winter,"  $T_OV_TEX[2]}}} \n",
                        "\\addcontentsline{toc}{section}{",$T_OV_TEX[3],"}\n\n~\n\n",
                        "\\begin{tabular}{lrr}\n",
                        	$T_OV_TEX[4],' & ',$ski,"\\si{h\\meter}\\\\\n",
                        	$T_OV_TEX[5], '& ',$bike,"\\si{\\kilo\\meter}\\\\\n",
                        	$T_OV_TEX[6], '& ',$mountain,"\\si{h\\meter}\\\\\n",
                        	$T_OV_TEX[7], '& ',$klettern,"&\\\\\\hline\n",
                        	$T_OV_TEX[8], '& ',$status_total," &\n".
                        '\end{tabular}\end{center}\newpage');
    # connect to TEX-input
    my $filename = our $G_TOUR_PATH;
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        print $fh "$overview \n";    
    foreach my $tour (sort keys %tours) { # sort tours by date
        print $fh "$tours{$tour} \n";
    }
    close $fh;

    # disconnect from the MySQL database
    $dbh->disconnect();
    
    return 1;
}
1;