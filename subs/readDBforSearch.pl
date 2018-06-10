sub readDBsearch{
      use strict;
      use warnings;
    #($sel_year, $sel_kind, $sel_goal, $sel_maxdistance, $sel_mindistance)
    my ($date, $kind, $goal, $min, $max, $tmin, $tmax) = @_;
    
    $tmin =~ s/://g;
    $tmax =~ s/://g;
    
    # MySQL database configurations
    my $dsn = join('',"DBI:SQLite:dbname=", our $G_DB_PATH);
    my $username = "";
    my $password = '';
    # connect to MySQL database
    my %attr = (PrintError=>0,RaiseError=>1 );
    my $dbh = DBI->connect($dsn,$username,$password,\%attr);
     
    my @tours;
    
    # read data from the table
    my $sql = join('',"SELECT link_id, date, kind, goal, place, companionship, distance, unit, active_time FROM tours WHERE date LIKE ",$date, " AND kind LIKE ", $kind, ' AND goal LIKE ',$goal);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $i = 0;
    while (my @row = $sth->fetchrow_array) {
        my $dis = $row[6];
        my $time = $row[8];
        $dis =~ s/,/./;
        $time =~ s/://g;
        if ($dis >= $min && $dis <= $max && $time >= $tmin && $time <= $tmax) {
            $tours[$i]=[@row];
            $i++;
        }
    }
    
    # disconnect from the MySQL database
    $dbh->disconnect();
    
    return @tours;
}
1;