sudo aptitude install git
cd ../subs
git clone https://github.com/mrihtar/Garmin-FIT.git
mv ./Garmin-FIT ./FIT2GPX
sudo aptitude install perl
sudo aptitude install cpanminus
# Evtl. need of changing userrights concerning perl installation directory
cpanm install Tk Tk::Chart::Lines Tk::JComboBox Tk::ToolBar Tk::StatusBar Tk::WaitBoxFixed Tk::MiniCalendar Geo::OSM::Tiles POSIX::strftime::GNU Config::Simple Image::ExifTool Tk::StayOnTop Geo::GeoNames
# move Garmin Folder to @INC