sub Pic_progress{
      use strict;
      use warnings;

    use Image::ExifTool qw(:Public);
    
    # select pictures
    my $pic_nr_one=0;
    my $pic_nr_two=0;
    
    our @picFiles;
    
    # select different ones
    my $iterations = 0;
    while ($pic_nr_one == our $pic_nr_two && $iterations < 5) {
        $pic_nr_one=floor(rand(scalar @picFiles));
        $pic_nr_two=floor(rand(scalar @picFiles));
    }
    
    $pic_nr_one = $picFiles[$pic_nr_one];
    $pic_nr_two = $picFiles[$pic_nr_two];
    
    # get rotation information PIC one
    my $exifTool = new Image::ExifTool;
    my $info= $exifTool->ImageInfo($pic_nr_one, 'Orientation');
    my $pic_nr_one_rotation;
    foreach (keys %$info) {
      $pic_nr_one_rotation = "$_ => $$info{$_}\n";
    }
    if ($pic_nr_one_rotation =~ /Rotate.90.CW/) {
        $pic_nr_one_rotation = -90;
    }elsif ($pic_nr_one_rotation =~ /Rotate.90/) {
        $pic_nr_one_rotation = 90;
    }else{
        $pic_nr_one_rotation = 0;
    }
    # get rotation information PIC two
    $exifTool = new Image::ExifTool;
    $info= $exifTool->ImageInfo($pic_nr_two, 'Orientation');
    my $pic_nr_two_rotation;
    foreach (keys %$info) {
      $pic_nr_two_rotation = "$_ => $$info{$_}\n";
    }
    if ($pic_nr_two_rotation =~ /Rotate.90.CW/) {
        $pic_nr_two_rotation = -90;
    }elsif ($pic_nr_one_rotation =~ /Rotate.90/) {
        $pic_nr_two_rotation = 90;
    }else{
        $pic_nr_two_rotation = 0;
    }
    
    # get PICs names
    $pic_nr_one=substr($pic_nr_one, rindex($pic_nr_one, '/'));
    $pic_nr_two=substr($pic_nr_two, rindex($pic_nr_two, '/'));
        
    return($pic_nr_one, $pic_nr_one_rotation, $pic_nr_two, $pic_nr_two_rotation);
}
1;