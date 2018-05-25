sub forcehhmmss{
    use 5.010;
    use strict;
    use warnings;
    
    my $time = $_[0];
    
    # remove whitespaces
    $time =~ s/\ //g;
    $time =~ s/:$//;
    
    # check any combination
    $time =~ s/^([0-9]{2,}):([0-9]{2}):([0-9]{2})$/$1:$2:$3/;                       # right combination
    $time =~ s/^(|[0-9]|[0-9]{2,}):(|[0-9]|[0-9]{2})$/$1:$2:00/;                    # no s  
    $time =~ s/^(|[0-9]|[0-9]{2,}):(|[0-9]|[0-9]{2}):([0-9])$/$1:$2:0$3/;           # only one s
    $time =~ s/^(|[0-9]|[0-9]{2,}):():([0-9]{2})$/$1:00:$3/;                        # no m
    $time =~ s/^(|[0-9]|[0-9]{2,}):([0-9]):([0-9]{2})$/$1:0$2:$3/;                  # only one m
    $time =~ s/^():([0-9]{2}):([0-9]{2})$/00:$2:$3/;                                # no h
    $time =~ s/^([0-9]):([0-9]{2}):([0-9]{2})$/0$1:$2:$3/;                          # only one h
    
    
    $time =~ s/^([0-9]{2,}):([0-9]{3,}):([0-9]{2})$/error/;                         # digit error min
    $time =~ s/^([0-9]{2,}):([0-9]{2}):([0-9]{3,})$/error/;                         # digit error sec
    
    if ($time =~ m/[^\d:]/) {                                                       # non digit
        $time = 'error';
    }                                                                          
                                                                                    # s / m >59
    if ($time =~ m/^([0-9]{2,}):([0-9]{2}):([0-9]{2})$/ && (substr($time, -5,2) > 59 || substr($time, -2) > 59)) {  
        $time = 'error';
    }
     
    return $time;   

}
1;