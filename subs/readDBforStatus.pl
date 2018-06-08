sub readDBstatusYear{
      use strict;
      use warnings;
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    my $sql = $_[0];
    
    # MySQL database configurations
    my $dsn = join('',"DBI:SQLite:dbname=",our $G_DB_PATH);
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my $total_distance=0;
    my $total_tours=0;
    
    # read data from the table
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        my $dis = $row[0];
        $dis =~ s/,/\./g;
        $total_distance = $total_distance + $dis;
        $total_tours++;
    }


    # disconnect from the MySQL database
    $dbh->disconnect();
    
    return ($total_tours, $total_distance);
}
sub readDBstatusWinter{
      use strict;
      use warnings;
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    my ($sql, $year, $month) = @_;
    
    # MySQL database configurations
    my $dsn = join('',"DBI:SQLite:dbname=", our $G_DB_PATH);
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my $total_distance=0;
    my $total_tours=0;
    
    # read data from the table
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        if ($month == 1) {
            $total_distance = $total_distance + $row[1];
            $total_tours++;
        } else{
            if ((substr($row[0],0,4)==$year && substr($row[0],5,2)<=7) || (substr($row[0],0,4)==$year-1 && substr($row[0],5,2)>7)){
                $total_distance = $total_distance + $row[1];
                $total_tours++;
            }
        }
    }


    # disconnect from the MySQL database
    $dbh->disconnect();
    
    return ($total_tours, $total_distance);
}
1;