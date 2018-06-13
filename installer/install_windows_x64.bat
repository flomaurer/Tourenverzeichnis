REM INSTALL PERL
cd .\bin\Perl
strawberry-perl-5.26.2.1-64bit.msi
SET PATH=%PATH%;C:\Strawberry\c\bin;C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin
cpan install Tk Tk::Chart::Lines Tk::JComboBox Tk::ToolBar Tk::StatusBar Tk::WaitBoxFixed Tk::MiniCalendar Geo::OSM::Tiles POSIX::strftime::GNU Config::Simple Image::ExifTool Tk::StayOnTop Geo::GeoNames
REM
REM INSTALL MIKTEX
cd ..\..\bin\MikTEX
miktexsetup.exe --package-set=essential download
miktexsetup.exe --package-set=essential install
cd %USERPROFILE%\AppData\Local\Programs\MiKTeX 2.9\miktex\bin\x64
initexmf --set-config-value=[MPM]AutoInstall=yes
REM
REM do postProcessing in Perlscript
cd ..\..\
perl .\install.pl