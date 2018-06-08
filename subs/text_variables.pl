#!/usr/bin/perl
use strict;
use warnings;

# GLOBAL +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Paths of PICS
our $G_CAL_PATH = './PICs/Calendar.jpg';
our $G_PIC_PATH = './PICs/PIC.png';
our $G_SAVE_PATH = './PICs/SAVE.png';
our $G_GENERATE_PATH = './PICs/RUN.png';


# German +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Main GUI
### Labels
our $L_TITLE = 'Tourenverzeichnis';
our $L_ELEVATION_PROFILE = 'Höhenprofil';
our $L_DESCRIPTION_COMMENT = 'Beschreibung und Kommentar';
our $L_DETAILS = 'Details';
our $L_TRACKFILE = 'Trackdatei';
our $L_GOAL = 'Ziel:';
our $L_TOURNBR = 'Tour: XX';
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
our $C_DATE = '';
our $C_START_TIME = '';
our $C_INTER_TIME = '00:00:00';
our $C_TOTAL_TIME ='';
our $C_TFILE = "All track files";
our $C_AFILE = "All files";


## SAVE DIALOG 
our $L_SD_TITLE = 'Info zum Speichervorgang';
our $T_SD_TEXT = "Sollten Datum und Name mit einer anderen Tour identisch sein, so werden Bilder und Tracks überschrieben. \n"
                . 'Bist du dir sicher, dass du mit dem Speichern fortfahren möchtest?';

## FINISH DIALOG
our $L_FD_TITLE = 'Info zum Speichervorgang';
our $T_FD_TEXT = "Eintrag wurde gespeichert.\n Soll das PDF erstellt werden?";

## MISSING DIALOG
our $L_MD_TITLE = 'Info zum Speichervorgang';
our $T_MD_TEXT = 'Es fehlen Informationen zu diesem Eintrag. Bitte ergänzen und erneut speichern.';

# English ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub set_english{
    use strict;
    use warnings;
    
    # overwrite all variables
    
    return 0;
}
1;