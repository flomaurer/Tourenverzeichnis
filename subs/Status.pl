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
  
  our @D_OV_SKITOUR;
  $sql = join('', "SELECT date, distance FROM tours WHERE ( date LIKE ", "'",$status_year,"%'", "OR date LIKE '", $status_year+$month, "')"," AND kind LIKE '", $D_OV_SKITOUR[0],"' OR kind LIKE '", $D_OV_SKITOUR[1],"' OR kind LIKE '", $D_OV_SKITOUR[2],"'");
  my $status_ski = join('',join(' (',(readDBstatusWinter($sql, $status_year, $month))),' hm)');
  
  our @D_OV_BIKE;
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '",$D_OV_BIKE[0],"' OR kind LIKE '",$D_OV_BIKE[1],"' OR kind LIKE '",$D_OV_BIKE[2],"'");
  my $status_bike = join('',join(' (',(readDBstatusYear($sql))),' km)');
  
  our @D_OV_MOUNTAIN;
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '",$D_OV_MOUNTAIN[0],"' OR kind LIKE '",$D_OV_MOUNTAIN[1],"' OR kind LIKE '",$D_OV_MOUNTAIN[2],"'");
  my $status_mountain = join('',join(' (',(readDBstatusYear($sql))),' hm)');
  
  our @D_OV_CLIMB;
  $sql = join('', "SELECT distance FROM tours WHERE date LIKE ", "'",$status_year,"%'", " AND kind LIKE '",$D_OV_CLIMB[0],"' OR kind LIKE '",$D_OV_CLIMB[1],"' OR kind LIKE '",$D_OV_CLIMB[2],"'");
  my $status_klettern = (readDBstatusYear($sql))[0];
  
  return ($status_year, $status_total, $status_ski, $status_bike, $status_mountain, $status_klettern, $status_winter);
}
1;