# Tourenverzeichnis - DB is filled with test data for developping
GUI zur Aufzeichnung seiner Sportaktvitäten (in Perl / PerlTk)

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

This is how to prepare your system to run the application 'Touren
verzeichnis'. Further, a short instruction (Quick start) is provi
ded within this document about how to use the application, where
which files are saved and which features are included in the code.
 			HAVE FUN BY BEING OUTDOOR		     
			
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

There is no waranty on the functionality given. Further, I don't 
provide any support or any bug fixing. There is also no waranty,
that this application will work out of the box on your system.  
You may have to solve problems on your own or change parts of the
code.							    

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## Preparation (testet on windows 8.1 and 10)

There exist two ways to install the necessary packages for this programm:
one by a script and one manually.

### Installation by script

(installation scripts not tested or finished up to now)

The scripts are recommend for anybody, who has no experience with perl or
LaTeX.

Those scripts don't provide any configuration, means, that you have to
take the default settings in all installation steps.

If perl or LaTex is already installed on your device, you probably have
to modify these scripts according to your settings.

For these scripts (Windows) are additional installers saved in 
'./installer/bin'which got their own licences. These installers were 
taken from:
* http://strawberryperl.com/
* https://miktex.org/

Further, those installers won't be updated in the GIT. So, you won't
have the latest version of programs delivered within this package and
their security patches.

Overall, on Linux (Mint, Ubuntu, ...) I would recommend to use the
scripts, as they provide the latest version of all used software and
recognize if a software is already installed. Maybe you have to adapt
these scripts to your preferred package manager.

In Windows, I would recommend the scripts as cheat sheet to write a own
installer script, or modify it (at least replace the provided installers
by their latest version from the sources above).

Or just use the instuctions below.


### manual installation

#### Windows (example)

* download miktex from https://miktex.org/
* install miktex (activate on the fly)
* download strawberry perl from http://strawberryperl.com/
* install perl 
* open a command window ('cmd' or Powershell)
* install the following packages with e.g. cpan (strawberry perl)
    `cpan install Tk Tk::Chart::Lines Tk::JComboBox Tk::ToolBar Tk::StatusBar Tk::WaitBoxFixed Tk::MiniCalendar Geo::OSM::Tiles POSIX::strftime::GNU Config::Simple Image::ExifTool Tk::StayOnTop Geo::GeoNames`
	- Tk
	- Tk::Chart::Lines
	- Tk::JComboBox
	- Tk::ToolBar
	- Tk::StatusBar
	- Tk::WaitBoxFixed
	- Tk::MiniCalendar
	- Geo::OSM::Tiles
	- POSIX::strftime::GNU
	- Config::Simple
	- Image::ExifTool
    - Tk::StayOnTop
    - Geo::GeoNames

* download [https://github.com/mrihtar/Garmin-FIT] into the subs directory
and move the folder Garmin (with FIT.pm included) to your @INC 
	(e.g. C:/Strawberry/perl/lib); 
The folder 'Garmin-FIT' in the subs directory needs to be renamed to 'FIT2GPX'.

#### Linux

TODO!!!

## Functionality + Features

The main focus of this application is to provide a easy to use 
GUI, which organizes your activities. Therefore, it archieves 
all activities in a SQLite-Database. Further, if provided 
pictures and track files are saved in an intiutive manner. A 
special feature is the generation of a PDF, which includes the 
activities' attributes, as well, as some sample pictures, an 
elevation profile and a map.

### Here, the main functions are listed:

* Adding activities
* Parsing GPX and FIT-files
* Modifiing activities
* Searching for activities
* Generating PDF (with attribiute selection)

### Here, some additions are listed:

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
* sorts DP values by date for PDF

## Usage / Quickstart

Allgemein hoffe ich, dass diese GUI sehr intuitiv zu bedienen ist.

### Dennoch hier einige Infos:

* Bitte immer eine Internetverbindung für das Programm zur Verfügung
stellen. Es werden keine Nutzerdaten oder Statistiken erhoben oder
weitergeleitet. Allerdings benötigen einige Features Daten aus dem 
Internet. Da das Programm nicht auf eine bestehende Internetverbindung
prüft, führt dies zu einem Absturz.

* Das Programm kann durch Doppelclick auf _RUN.sh /_RUN.bat gestartet 
werden. Unter Linux muss diese Datei evtl. ausführbar gemacht werden.
Sollten Fehlermeldungen erwünscht sein, kann das Script auch mit
'perl .GUI.pl' aus dem Terminal / Powershell / Komandozeile aufgerufen
werden.
* Am oberen Rand können über die Icons oder das Menu die verschiedenen
Funktionen des Programms aufgerufen werden (selbsterklärend).
* Im Menü (oben) stehen auch Informationen zu den im Programm 
verwendeten Bildern zur Verfügung.
* Am unteren Rand werdeb statistische Informationen zum aktuellen Jahr
dargestellt.

### Erstellen eines Eintrags:

1. Sollte ein GPX- / FIT-Track zur Verfügung stehen, ist dies die 
optimale Möglichkeit sich Arbeit zu sparen: Einfach 'Track auswählen' 
drücken, den Track auswählen, danach 'OK' drücken und 'Track einlesen' 
betätigen. Schon werden eine Vielzahl der Felder ausgefüllt. Zudem
öffnet sich ein Fenster zum Auswählen des Ausgangsort, falls Koordinaten 
im Track vorhanden sind. Nebenbei werden der Track auf der Karte sowie
das Höhenprofil geplottet. 
2. Nun noch die restlichen Felder ausfüllen (Aufstiegszeit!!!)
3. Zu guter letzt noch alle auf der Tour gemachten Bilder auswählen und
'Tour speichern' drücken (oben oder unten).
4. Jetzt kann ein PDF mit all deinen Einträgen erstellt werden, wenn 
gewünscht.

### Öffnen eines Eintrags um ihn zu bearbeiten:

1. Oben im Programm 'Öffnen' auswählen
2. Filter entsprechend setzen
3. Tour auswählen
4. 'OK' drücken
5. Bearbeiten
6. wieder speichern

### PDF erstellen

1. Oben 'PDF erstellen' auswählen
2. Filter setzen
3. 'OK' drücken und warten

### Eingaben zurücksetzen

1. Oben auf 'Neu' drücken

### Ort manuel auswählen

1. Ort in entsprechendes Feld eingeben
2. 'Enter- / return-Taste' drücken, um Vorschlagsliste zu aktualisieren

## Behaviour

This program got some special behaviour you should be aware of:

1. If you read a GPX file, the first position of this track gets used
as startcoordinates in the SQLite-DB, alltough you are asked for the
Name of the starting place. But, the coordinates provided by 
GEOnames, will be displayed in the PDF and not the ones of the track.
You can overwrite the values in the DB by calling the location frame
again.
2. If you open a tour, you will be asked for the start location. You
can cancel this dialog, if you simple close this Window in the upper
right corner. Oterwise, the coordinates get saved.
3. The tours in the DB are sorted the way, you inserted them. In the
PDF, they will be sorted by date.

## Bugs

* render problems in MapPreview
* character encoding
* 'uninitialized values' (see diagnostics)
* problems (delay) after recalling search window
* no recognition of missing internet-connection
* only in German
