#!/usr/bin/perl
sub getTypes{
    use warnings;
    use strict;
    require "./subs/readDBforSearch.pl";
    my @types = @_;
    my @values = readDBsearch("'%'","'%'","'%'",0,999999,0,999999,0,999999);
    for (my $i=0; $i <= $#values; $i++){
        if (grep {$_ eq $values[0][2]} @types){}else{
            push @types, $values[0][2];
        }
    }
    return @types;
}
1;