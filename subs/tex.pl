sub tex{
  use 5.010;
  use strict;
  use warnings;
  use FindBin;
  
  require "./subs/forcehhmmss.pl";
  
  my ($pic_amount, $pic_nr_one, $pic_nr_one_rotation, $pic_nr_two, $pic_nr_two_rotation, $PICfolder, $map, $scale, $latmin, $latmax, $lonmin, $lonmax, $gpxout) = @_;
  
  # controll times
  our $Start_time= forcehhmmss($Start_time);
  our $interTime= forcehhmmss($interTime);
  our $endTime= forcehhmmss($endTime);
  
  # entry code
  our $bgl =~ s/\n//g; # remove newlines in bgl to prevent tex error
  my $tex = join('','\begin{minipage}{\textwidth}','\tour{',our $Goal,
  '}{',our $Activity_date,'}{', $Start_time,'}{',our $sel_type,
  '}[',our $distance,our $distance_unit,'][', $interTime,'][',
   $endTime,'][',$bgl,']\label{',$Activity_date,'-',$Goal,'}',our $bschr,"\n\n ",our $com, '\end{minipage}',);
  
  # add elevation code
  if (our $elevationout ne '') {
    my $label = $Goal; 
    $label =~ s/_/\\_/g; # taking care of underscores for tex
    if (our $plot_unit eq 'time'){ # convert seconds to hh:mm:ss in plot
        $tex =join('', $tex, '\newline\begin{tikzpicture} \pgfplotsset{ seconds to timeformat={x}{\hour:\minute}, }	\begin{axis}[xlabel=', $label, ', xtick distance=', our $tick, ', width=\linewidth, height=4cm, axis lines=left, no markers, grid=major, legend pos=south east]		\addplot [black] table {', $elevationout ,'};	\end{axis}	\end{tikzpicture}');
    } else {
        $tex =join('', $tex, '\newline\begin{tikzpicture} \begin{axis}[xlabel=', $label, ', xtick distance=', our $tick, ', width=\linewidth, height=4cm, axis lines=left, no markers, grid=major, legend pos=south east]		\addplot [black] table {', $elevationout ,'};	\end{axis}	\end{tikzpicture}');
    }
  }
  # add track code
  if ($gpxout ne '' ){
    $tex =join('', $tex, '\begin{center}\begin{tikzpicture}	\begin{axis}[axis on top, width=\linewidth, axis lines=none, no markers, z=0cm, x=\linewidth/',$scale,', y=\linewidth/',$scale,',ymin=',$latmin,', ymax=',$latmax,', xmin=',$lonmin,', xmax=',$lonmax,']',$map,'  \addplot [ultra thick, magenta] table {',$gpxout ,'}; \end{axis} \end{tikzpicture}\end{center}');
  }
  # add PIC code
  my $picture;
  if ($pic_amount==0){}
  else {
    if ($pic_nr_one_rotation == 0){
        my $caption = join('', substr($PICfolder,rindex($PICfolder,'/')),  substr($pic_nr_one,rindex($pic_nr_one,'/')));
        $caption =~ s/_/\\_/g; # taking care of underscores for tex
        $picture = join('', '\begin{figure}\centering\includegraphics[angle=',$pic_nr_one_rotation,',origin=c,height=0.25\textheight]{', $pic_nr_one, '}\caption*{.', $caption,'}\end{figure}'); 
    }else{
        my $caption = join('', substr($PICfolder,rindex($PICfolder,'/')),  substr($pic_nr_one,rindex($pic_nr_one,'/')));
        $caption =~ s/_/\\_/g; # taking care of underscores for tex
        $picture = join('', '\begin{figure}\centering\includegraphics[angle=',$pic_nr_one_rotation,',origin=c,width=0.25\textheight]{', $pic_nr_one, '}\caption*{.', $caption,'}\end{figure}');
    }  
    if ($pic_amount==2){
      if ($pic_nr_two_rotation == 0){
          my $caption = join('', substr($PICfolder,rindex($PICfolder,'/')),  substr($pic_nr_two,rindex($pic_nr_two,'/')));
          $caption =~ s/_/\\_/g; # taking care of underscores for tex
          $picture .= join('', '\begin{figure}\centering\includegraphics[angle=',$pic_nr_two_rotation,',origin=c,height=0.25\textheight]{', $pic_nr_two, '}\caption*{.', $caption,'}\end{figure}'); 
      }else{
          my $caption = join('', substr($PICfolder,rindex($PICfolder,'/')),  substr($pic_nr_two,rindex($pic_nr_two,'/')));
          $caption =~ s/_/\\_/g; # taking care of underscores for tex
          $picture .= join('', '\begin{figure}\centering\includegraphics[angle=',$pic_nr_two_rotation,',origin=c,width=0.25\textheight]{', $pic_nr_two, '}\caption*{.', $caption,'}\end{figure}');
      } 
    }
  $tex .= $picture; 
  }
  
  $tex .= '\vspace{2em} ~\newline';
  #post processing - replace absolute paths by relative ones
    my $bin = $FindBin::Bin;
    $bin =~ s/\+/\\\+/g; #correct plussigns
    $bin =~ s/\ /\\\ /g; #correct whitespaces
    $tex =~ s/$bin/\./g;
  
  return($tex);
}
1;
