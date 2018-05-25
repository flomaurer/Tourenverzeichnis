########################################################################
## This is how to prepare your system to run the application 'Touren- ##
## verzeichnis. Further, a short instruction (Quick start) is provi-  ##
## ded within this document about how to use the application, where   ##
## which files are saved and which features are included in the code. ##
## 			HAVE FUN BY BEING OUTDOOR		      ##
########################################################################

########################################################################
## There is no waranty on the functionality given. Further, I don't   ##
## provide any support or any bug fixing. There is also no waranty,   ##
## that this application will work out of the box on your system.     ##
## You may have to solve problems on your own or change parts of the  ##
## code.							      ##
########################################################################

1. Preparation (testet on windows 8.1 and 10)
	(installation script will be added)

	* install miktex (activate on the fly)

	* install perl (strawberry perl)

	* install the following packages with cpan (strawberry perl)
		- Tk
		- Tk::Chart::Lines
		- Tk::JComboBox
		- Tk::ToolBar
		- Tk::StatusBar
		- Tk::WaitBoxFixed
		- Tk::MiniCalendar
		- Tk::Geo::OSM::Tiles
		- POSIX::strftime::GNU
		- Confi::Simple
		- Image::ExifTool

	* download https://github.com/mrihtar/Garmin-FIT into the subs-directory
        and move the Folder Garmin (with FIT.pm included) to your @INC 
		(e.g. C:/Strawberry/perl/lib)

2. Functionality + Features

	The main focus of this application is to provide a easy to use 
	GUI, which organizes your activities. Therefore, it archieves 
	all activities in a SQLite-Database. Further, if provided 
	pictures and track files are saved in an intiutive manner. A 
	special feature is the generation of a PDF, which includes the 
	activities' attributes, as well, as some sample pictures, an 
	elevation profile and a map.

	Here, the main functions are listed:
		* Adding activities
		* Parsing GPX and FIT-files
		* Modifiing activities
		* Searching for activities
		* Generating PDF (with attribiute selection)

	Here, some additions are listed:
		* elevation plot after track parsing
		* map preview after track parsing
		* Year overview in PDF
		* Year overview in GUI
		* date selection by Calendar
		* change of Widget sizes
		* checking activity attributes before saving
		* auto-correction of date-values
		* realtime download of OSM-tiles
		* recognition of picture rotation for PDF on EXIF-info
		* realtime DB-search while typing search parameters

3. Usage
	Hopefully very intiutive.

4. Bugs
	* render problems in MapPreview
	* character encoding
	* 'uninitialized values' (see diagnostics)
	* problems after recalling search window
	* no recognition of missing internet-connection
