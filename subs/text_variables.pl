#!/usr/bin/perl
use strict;
use warnings;

# GLOBAL +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Paths of PICS
our $G_CAL_PATH = './PICs/Calendar.jpg';
our $G_PIC_PATH = './PICs/PIC.png';
our $G_SAVE_PATH = './PICs/SAVE.png';
our $G_GENERATE_PATH = './PICs/RUN.png';

## Path of Files
our $G_TMP_PATH = 'tmp';
our $G_DB_PATH = 'data/Tourenverzeichnis.sqlite3';
our $G_TRAW_PATH = './tracks/raw/';
our $G_IMG_PATH = './Bilder/';
our $G_DBG_PATH = './dbg/';
our $G_TOUR_PATH = './data/tours.tex';

## Types
our $C_TFILE = "All track files";
our $C_AFILE = "All files";
our $C_PFILE = "Pictures";

## Parameter
our $C_MW_HEIGHT = 650;
our $C_MW_WIDTH = 1200;
our $C_MW_HEIGHT_MIN = 300;
our $C_MW_WIDTH_MIN = 400;

## INITIAL VARIABLE VALUES
our $C_DATE = '';
our $C_START_TIME = '';
our $C_INTER_TIME = '00:00:00';
our $C_TOTAL_TIME ='';
our $C_GOAL = '';
our $C_LOCATION = '';
our $C_DISTANCE = '';
our $C_ELEVATION = '';
our $C_TOURNBR = 'XX';
our $C_STARTLAT = '';
our $C_STARTLON = '';
our $C_PLOT_UNIT_X = 'time';
our $C_TRACK_PATH = '';
our @C_PIC_FILES = '-';
our @C_LATS = ();
our @C_LONS = ();
our @C_ELES = ();


# German +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Main GUI
### Labels
our $L_TITLE = 'Tourenverzeichnis';
our $L_ELEVATION_PROFILE = 'Höhenprofil';
our $L_DESCRIPTION_COMMENT = 'Beschreibung und Kommentar';
our $L_DETAILS = 'Details';
our $L_TRACKFILE = 'Trackdatei';
our $L_GOAL = 'Ziel:';
our $L_TOUR = 'Tour: ';
our $L_KIND = 'Art:';
our $L_DATE = 'Datum (JJJJ-MM-TT):';
our $L_LOCATION = 'Ort:';
our $L_DISTANCE = 'Distanz:';
our $L_START_TIME = 'Startzeit (hh:mm:ss):';
our $L_INTER_TIME = 'Aufstieg (hh:mm:ss):';
our $L_TOTAL_TIME = 'Gesamtzeit (hh:mm:ss):';
our $L_OV_YEAR = 'Jahresüberblick ';
our $L_OV_EINTER = ' (Winter ';
our $L_OV_SKITOUR = ' bei Skitouren)';
our $L_OV_TTOUR = 'Touren gesamt: ';
our $L_OV_STOUR = 'Skitouren: ';
our $L_OV_BTOUR = 'Radtouren: ';
our $L_OV_HTOUR = 'Wanderungen: ';
our $L_OV_CTOUR = 'Klettern: ';

### Buttons
our $B_FILE = 'Datei';
our $B_NEW = 'Neue Tour';
our $B_OPEN = 'Tour Öffnen';
our $B_SAVE = 'Tour Speichern';
our $B_GENERATE = 'PDF erstellen';
our $B_INFO = 'Info';
our $B_ABOUT = 'About';
our $B_TRACK_SELECT = "Track auswählen \n Support für mehrere Tracks fehlt noch";
our $B_READ_TRACK = 'Track einlesen';
our $B_SELECT_PIC = 'Bilder auswählen';
our $B_YES = 'Ja';
our $B_NO = 'Nein';
our $B_OK = 'OK';

### Text
our $T_DESCRIPTION = 'Hier Beschreibung eingeben...';
our $T_BEGLEITUNG = 'Hier Begleitung eingeben...';
our $T_COMMENT = 'Hier Kommentar eingeben...';
our $T_TRACKFILE = 'Falls kein Track existiert leer lassen.';
our $T_KM = 'km';
our $T_HM = 'hm';

### Selections
our @S_TYPES = ('Skitour', 'Bergsteigen', 'Rennrad', 'Telemark-Skitour', 'Klettersteig', 'Wandern', 'Mountainbike', 'Wandern-Zipfelbob');

### CONSTANTS
our $C_TYPE = 'Skitour';
our $C_TYPE_B = 'Rennrad';

## SAVE DIALOG 
our $L_SD_TITLE = 'Info zum Speichervorgang';
our $T_SD_TEXT = "Sollten Datum und Name mit einer anderen Tour identisch sein, so werden Bilder und Tracks überschrieben. \n"
                . 'Bist du dir sicher, dass du mit dem Speichern fortfahren möchtest?';
our $T_SD_RESULT = "Der Speichervorgang wurde abgebrochen.\n";

## FINISH DIALOG
our $L_FD_TITLE = 'Info zum Speichervorgang';
our $T_FD_TEXT = "Eintrag wurde gespeichert.\n Soll das PDF erstellt werden?";

## MISSING DIALOG
our $L_MD_TITLE = 'Info zum Speichervorgang';
our $T_MD_TEXT = 'Es fehlen Informationen zu diesem Eintrag. Bitte ergänzen und erneut speichern.';

## ABOUT DIALOG
our $L_AD_TITLE = 'Programminformation';
our $T_AD_TEXT = "Diese Implementierung ist in Perl geschrieben."
    . "Neben einigen Perl-Modulen wurden folgende Elemente verwendet, auf deren"
    . " Quellen hier hingewiesen wird:\n"
    . "* Geonames.org (Lizenz: https://creativecommons.org/licenses/by/3.0/us/deed.de)\n"
    . "* Icons (Quellen: http://www.iconarchive.com/show/pretty-office-7-icons-by-custom-icon-design/Calendar-icon.html;\n"
    . "                  https://commons.wikimedia.org/wiki/File:Picture_icon-72a7cf.svg;\n"
    . "                  http://www.clker.com/clipart-running-icon-on-transparent-background-5.html;\n"
    . "                  https://www.iconsdb.com/soylent-red-icons/save-icon.html\n"
    . "        (Lizenzen: https://creativecommons.org/publicdomain/zero/1.0/; \n"
    . "                   https://creativecommons.org/licenses/by-nd/3.0/\n"
    . "* Garmin-FIT (Lizenz: https://github.com/mrihtar/Garmin-FIT/blob/master/LICENSE_LGPL_v2.1.txt)";

## ELEVATION PLOT
our $L_EP_XAXIS = 'Zeit o. Distanz';
our $L_EP_YAXIS = 'Höhe';

## WAIT PDF DIALOG
our $T_WD_PDF_TEXT1 = "Das Erstellen des PDFs dauert noch an.";
our $T_WD_PDF_TEXT2 = 'Sollte es ungewöhnlich lange dauern, überprüfe deine Internetverbindung.';
our $L_WD_PDF_TITEL = 'PDF wird erstellt';

## FINISH PDF DIALOG
our $L_FD_PDF_TITLE = 'Info zum PDF';
our $T_FD_PDF_TEXT = "Das PDF des Tourenbuchs wurde erstellt. Soll es geoeffnet werden?";

## WAIT MAP PREVIEW 
our $T_WD_MP_TEXT1 = "Das Erstellen der Karte dauert noch an";
our $T_WD_MP_TEXT2 = 'Sollte es ungewöhnlich lange dauern, überprüfe deine Internetverbindung.';
our $L_WD_MP_TITEL = 'Kartenvorschau';

## MAP PREVIEW
our $L_MAP_PREVIEW = 'Karte - Mercator-Projektion (nicht  flächen- oder richtungstreu, aber winkeltreu)';


# English ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub set_english{
    use strict;
    use warnings;
    
    # overwrite all variables
    
    return 0;
}
1;