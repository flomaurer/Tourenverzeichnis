sudo aptitude install git
cd ../subs
git clone https://github.com/mrihtar/Garmin-FIT.git
mv ./Garmin-FIT ./FIT2GPX
sudo aptitude install perl
sudo aptitude install cpanminus
# Evtl. need of changing userrights concerning perl installation directory
cpanm install Tk
cpanm install Tk::Chart::Lines
cpanm install Tk::JComboBox
cpanm install Tk::ToolBar
cpanm install Tk::StatusBar
cpanm install Tk::WaitBoxFixed
cpanm install Tk::MiniCalendar
cpanm install Tk::Geo::OSM::Tiles
cpanm install POSIX::strftime::GNU
cpanm install Config::Simple
cpanm install Image::ExifTool
