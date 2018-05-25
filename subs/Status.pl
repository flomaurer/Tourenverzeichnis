sub getStatus{
  use 5.010;
  use strict;
  use warnings;
  use FindBin;
  require './subs/readDBforStatus.pl';
  
  my $status_year = (localtime(time))[5]+1900;  
  my $status_winter;
  my $month;
  if ((localtime(time))[4] <=7) {
    $status_winter = join('', $status_year-1,'/',substr($status_year,2));
    $month = -1;
  }else{
    $status_winter = join('', $status_year,'/',substr($status_year+1,2));
    $month = 1;
  }
  
  
  my $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'");
  my $status_total = (readDBstatusYear($sql))[0];
  
  $sql = join('', "SELECT date, distance FROM tours WHERE ( date LIKE ", "'",$status_year,"%'", "OR date LIKE '", $status_year+$month, "')"," AND kind LIKE '%kitou%'");
  my $status_ski = join('',join(' (',(readDBstatusWinter($sql, $status_year, $month))),' hm)');
  
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '%ennra%' OR kind LIKE '%ountainbik%'");
  my $status_bike = join('',join(' (',(readDBstatusYear($sql))),' km)');
  
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '%ander%' OR kind LIKE '%ergtou%'");
  my $status_mountain = join('',join(' (',(readDBstatusYear($sql))),' hm)');
  
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '%etter%' ");
  my $status_klettern = (readDBstatusYear($sql))[0];
  
  return ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter);
}
1;