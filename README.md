# TV Menü für macOS
Mit **TV Menü** lassen sich die Programmstreams der öffentlich-rechtlichen Sender aus der Menüleiste heraus öffnen.
Es gibt sowohl eine Standalone Version, als auch ein Plugin für xBar.

Es ist quasi eine aktualisierbare Bookmarkliste und **kein Ersatz** für Kodi oder ähnliche Programme.
Mein DVB-C Empfänger ist ausgefallen und habe ich eine schnelle Lösung benötigt.

![](/img/menu1.png)

Die aktuellste Standalone Version von **TV Menü** kann unter **[Releases](https://github.com/einstweilen/tvmenu/releases/)** heruntergeladen werden.
Falls Bedarf in der Standalone Version für die zusätzlichen Senderlisten der xBar Version besteht, bitte ein **[Issue eröffnen](https://github.com/einstweilen/tvmenu/issues)**.

Wer bereits [xBar](https://xbarapp.com/) verwendet kann statt der Stand-Alone-Version von **TV Menü** auch die über mehr Senderlisten verfügende xBar-Plugin-Version herunterladen.
**[xBar Plugin Download und Anleitung](#tv-men%C3%BC-als-xbar-plugin)**

## Feature
* über 30 Sender im Livestream in der Standalone Version
* über 200 Sender in der xBar Version
* Sender mit mehreren lokalen Sendehäusern werden in Submenüs zusammengefaßt
* Wiedergabe mit dem QuickTime Player oder mit VLC
* die Senderstreams lassen sich im QuickTime Player im normalen Fenster, im Vollbild oder auch als Schwebendes Fenster anzeigen
* die Senderliste kann bei Bedarf aktualisert werden

## Download und Installation
Die aktuellste Version von **TV Menü** kann unter [Releases](https://github.com/einstweilen/tvmenu/releases/) heruntergeladen werden.

Nach dem Download **TV Menü.zip** mit einem Doppelklick entpacken und das entpackte Programm **TV Menü** in den Programmeordner kopieren. Es ist aber auch in jedem anderen Ordner ausführbar.

## Erster Start
**TV Menü** mit einem Doppelklick starten. Beim ersten Start des Programms erscheint der Hinweis, dass das Programm aus dem Internet geladen wurde und ob man es trotzdem öffnen möchte, diesen Hinweis mit Klick auf "Öffnen" bestätigen.

Jetzt erscheint in der Menüleiste das **TV Menü** Symbol 📺.

## Verwendung
Das 📺 Symbol in der Menüleiste anklicken und aus dem Menü den gewünschten Sender auswählen.

![](/img/menukmpl1.png)

Sender mit mehreren lokalen Streams werden standardmäßig in Submenüs zusammengefaßt.

![](/img/submenu1.png)

Ein im Menü ausgewählter Sender wird im Player abgespielt, für die Wiedergabe ist der QuickTime Player voreingestellt.

Je nach dem gewählten Sender und der eigenen Internetanbindung kann es 5 Sekunden dauern bis der erste Stream startet. 

Damit nicht mehrere Streams gleichzeitig wiedergegeben werden, werden alle geöffneten Fenster des Players zuerst geschlossen.
Es kann einmalig ein Hinweis erscheinen, dass der Player von **TV Menü** fernbedient wird.
Diesen Hinweis mit _OK_ bestätigen.

![](/img/qtfirst1.jpg)

![](/img/qtplayer1.jpg)

Sofern der Stream des Senders das unterstützt, kann direkt im Player ein anderer Tonkanal/Sprache ausgewählt werden.

![](/img/qtoptionen1.jpg)

## Einstellungsmenü
![](/img/einstellungen1.png)

### Sendergruppierung ein/aus 
Die Gruppierung der Sender zu Sendergruppen ein- bzw. ausschalten.

![](/img/menukmpl1.png) ![](/img/menukmpl2.png)

Screenshot mit Submenüs (links) und ohne Submenüs (rechts)

### Wiedergabeplayer wählen QuickTime Player oder VLC
Standardmäßig ist der QuickTime Player voreingestellt, bei Bedarf kann zum VLC gewechselt werden, z.B. wenn man mehrere Monitore ohne getrennte Spaces verwendet und der QuickTime Player dann im Vollbild Modus alle anderen Monitore schwarz machen würde.

Ist VLC nicht installiert, ist "VLC verwenden" im Submenü ausgegraut.

![](/img/einstellungen3.png)
### Senderliste aktualisieren
**TV Menü** verwendet die Liste der Senderadressen aus der zu Mediathekview gehörenden [ZAPP](https://github.com/mediathekview/zapp) Android App. Sollten sich die Senderadressen ändern, kann mit _Senderliste aktualisieren_  eine neue Liste von der ZAPP Projektseite geladen werden.

# TV Menü als xBar Plugin
Das [Plugin herunterladen](https://github.com/einstweilen/tvmenu/blob/main/tvmenu.1d.sh) und in das xbar/plugins Verzeichnis kopieren. Das Plugin Verzeichnis läßt sich aus dem xBar Submenü öffnen

![](/img/xbarpluginfolder.png)

Sollte eine "Nicht ausführbar" Fehlermeldung angezeigt werden, im Terminal `chmod +x tvmenu.1d.sh` eingeben.
![](/img/xbarerror.png)

**TV Menü** steht nun im xBar Plugin Browser zur Verfügung
![](/img/xbar-plugin.png)

### Senderlistenauswahl
Über das Senderlisten-Submenü kann die jeweils aktive Senderliste ausgewählt werden.
![](/img/xbar-listen.png)

| Senderliste  | Beschreibung  | Quelle  | 
|---|---|---|
| D ÖRR | 32 öffentlich-rechtliche Sender | Zapp App | 
| D Sonstige | 40 gemischte Private/ÖRR | Kodi Nerds | 
| D lokal | 68 Kleine Lokalsender | Kodi Nerds |  
| A CH | 23 Österreich und Schweiz | Kodi Nerds | 
| US UK | 27 USA und UK | Kodi Nerds |  
| International | 47 gemischt | Kodi Nerds |  

Bei den **ausländischen Sender A/CH/US/UK** beachten, dass durch Geoblocking nicht jeder Stream von einer deutschen IP aus erreichbar ist.

Bei manchen **Lokalsendern** verweigert der QuickTime Player wegen Serverzertifikatsproblemen die Wiedergabe, dann im Menü **Einstellungen** auf den VLC Player umschalten.

Sender im Detail (Stand Anfang 2023)
<details><summary>D ÖRR <em>[Zum Aufklappen anklicken]</em></summary>
3sat<br>
ARD-alpha<br>
ARTE<br>
BR Nord<br>
BR Süd<br>
Das Erste<br>
Deutsche Welle<br>
Deutsche Welle+<br>
HR<br>
KiKA<br>
MDR Sachsen<br>
MDR Sachsen-Anhalt<br>
MDR Thüringen<br>
NDR Hamburg<br>
NDR Mecklenburg-Vorpommern<br>
NDR Niedersachsen<br>
NDR Schleswig-Holstein<br>
ONE<br>
Parlamentsfernsehen Kanal 1<br>
Parlamentsfernsehen Kanal 2<br>
phoenix<br>
Radio Bremen<br>
rbb Fernsehen Berlin<br>
rbb Fernsehen Brandenburg<br>
SR<br>
SWR Baden-Württemberg<br>
SWR Rheinland-Pfalz<br>
tagesschau24<br>
WDR<br>
ZDF<br>
ZDFinfo<br>
ZDFneo<br>
</details>

<details><summary>D Sonstige <em>[Zum Aufklappen anklicken]</em></summary>
3sat<br>
ANIXE HD<br>
ARTE HD<br>
Bibel TV<br>
Bibel TV Impuls<br>
Bibel TV Musik<br>
Bild<br>
DASDING-VisualRadio<br>
DAZN FAST+<br>
DELUXE MUSIC<br>
Deutsches Musik Fernsehen<br>
ERF 1<br>
euronews deutsch<br>
EWTN katholisches TV<br>
Folx TV<br>
health.tv<br>
K-TV<br>
Magenta Musik 360 1<br>
Magenta Musik 360 2<br>
More than Sports TV<br>
MTV Germany<br>
Nickelodeon<br>
One 1 Music TV<br>
phoenix HD<br>
Red Bull TV<br>
RiC<br>
Rockland TV<br>
Schlager Deluxe<br>
ServusTV HD<br>
SWR3-VisualRadio<br>
VISIT-X.tv<br>
WELT<br>
Welt der Wunder<br>
WELT News (loop)<br>
wir24.tv<br>
ZDF HD<br>
ZDFinfo HD<br>
ZDFneo HD<br>
Zwei 2 Music TV<br>
Ö3-VisualRadio<br>
</details>

<details><summary>D lokal <em>[Zum Aufklappen anklicken]</em></summary>
a.tv<br>
ALEX Berlin<br>
allgäu.tv<br>
Baden TV<br>
BLK Regional TV<br>
Chemnitz Fernsehen<br>
Dresden Fernsehen<br>
ELBEKANAL<br>
emstv<br>
Franken Fernsehen<br>
frf24<br>
Hamburg 1<br>
KabelJournal<br>
kulturmd<br>
L-TV<br>
Leipzig Fernsehen<br>
MDF.1<br>
MyTVplus<br>
münchen.tv<br>
Niederbayern TV Passau<br>
noa4 Hamburg HD<br>
noa4 Norderstedt HD<br>
NRWision HD<br>
Oberpfalz TV<br>
OK Dessau<br>
OK Flensburg<br>
OK Fulda<br>
OK Gießen<br>
OK Kaiserslautern<br>
OK Kassel<br>
OK Kiel<br>
OK Ludwigshafen<br>
OK Magdeburg<br>
OK Merseburg-Querfurt<br>
OK naheTV (Idar-Oberstein)<br>
OK Rhein-Main (Offenbach Frankfurt)<br>
OK RheinLokal (Worms)<br>
OK Salzwedel<br>
OK Stendal<br>
OK Suedwestpfalz<br>
OK Weinstraße (Neustadt)<br>
OK Wernigerode<br>
OK4 (Adenau Andernach Koblenz Neuwied)<br>
OK54 (Trier)<br>
oldenburg eins<br>
Potsdam TV<br>
PUNKTum<br>
RAN1<br>
RBW<br>
Regio TV Schwaben<br>
RFH<br>
RFO<br>
Rhein Neckar Fernsehen<br>
rheinmaintv<br>
seenluft24<br>
Sylt1<br>
teltOwkanal<br>
Tide TV<br>
TV Halle<br>
TV Mainfranken<br>
TV Mittelrhein<br>
TV Würzburg<br>
tv.berlin<br>
tv.ingolstadt<br>
TVA<br>
TVO<br>
Westerwald TV<br>
WTV (OK Wettin)<br>
</details>

<details><summary>A CH <em>[Zum Aufklappen anklicken]</em></summary>
dorf tv<br>
Krone.TV<br>
Kronehit TV<br>
M4TV<br>
Melodie TV<br>
oe24 TV<br>
Okto<br>
ORF 2 HD<br>
ORF eins HD<br>
ORF III HD<br>
ORF SPORT +<br>
RE eins TV<br>
RTV (AT)<br>
ServusTV HD (AT)<br>
Tele M1 HD<br>
Telebasel<br>
TeleBielingue<br>
TeleBärn HD<br>
TeleZüri HD<br>
Tirol TV<br>
TVM3<br>
TVO (CH)<br>
W24 TV<br>
</details>

<details><summary>US UK <em>[Zum Aufklappen anklicken]</em></summary>
4Music<br>
ABC News<br>
AdultSwim<br>
AdultSwim - Aqua Teen Hunger Force<br>
AdultSwim - Black Jesus<br>
AdultSwim - Channel 5<br>
AdultSwim - Dream Corp LLC<br>
AdultSwim - Infomercials<br>
AdultSwim - Last Stream on the Left<br>
AdultSwim - Metalocalypse<br>
AdultSwim - Off the Air<br>
AdultSwim - Rick and Morty<br>
AdultSwim - Robot Chicken<br>
AdultSwim - Samurai Jack<br>
AdultSwim - The Eric Andre Show<br>
AdultSwim - The Venture Brothers<br>
AdultSwim - Your Pretty Face is Going to Hell<br>
Bloomberg TV<br>
CBS News<br>
CMC<br>
Create & Craft TV<br>
Hunt Channel<br>
KTVU Fox 2<br>
London Live<br>
NASA TV<br>
SBN<br>
Sky News<br>
</details>

<details><summary>International <em>[Zum Aufklappen anklicken]</em></summary>
24 Vesti<br>
4 FunTV<br>
Activa TV<br>
Al Jazeera<br>
Al Jazeera English<br>
ALBUK TV<br>
Alfa<br>
Alfa TV<br>
Arirang TV<br>
ARTE HD (FR)<br>
BFMTV<br>
Channel NewsAsia<br>
CHCH<br>
Deutsche Welle (ES)<br>
Digi 24 HD<br>
Dubai One<br>
Fjorton<br>
France 24<br>
Kanal 5<br>
KVF<br>
m2o TV<br>
Mello TV<br>
MetroTV<br>
NHK WORLD TV<br>
NKNews<br>
Press TV<br>
ProTv News<br>
Rai News 24<br>
Realitatea TV<br>
Romania TV<br>
RTÉ News Now<br>
SDF<br>
SferaTV<br>
Sitel<br>
Sky News Extra<br>
Taivas TV7<br>
Telma<br>
Three<br>
TRT World HD<br>
TV 538<br>
TV Rain<br>
TVNZ 1<br>
TVNZ 2<br>
XITE<br>
Yle Teema & Fem<br>
Yle TV1<br>
Yle TV2<br>
</details>

### Senderlistenquellen
Die Listen der Senderadressen für **TV Menü** stammen aus zwei Quellen:
* die Liste mit den öffentlich-rechtlichen Sendern stammt aus der zu Mediathekview gehörenden [ZAPP](https://github.com/mediathekview/zapp) Android App
* die anderen Listen stammen aus der [IPTV Übersicht bei den KodiNerds](https://github.com/jnk22/kodinerds-iptv)

Sollten sich die Streamadressen der Sender ändern, kann mit **Senderliste aktualisieren** eine neue Liste von der ZAPP Projektseite und der IPTV Übersicht der KodiNerds abgerufen werden.

### Umstellung von Python auf Bash
Bis zur Version 1.2.1 ([Download der letzen Python Version](https://github.com/einstweilen/tvmenu/releases/tag/1.2.1)) wurde für **TV Menü** ein Pythonskript verwendet, neuere Versionen wurden 1 zu 1 in ein Shellskript umgeschrieben.

## History
* 2023-01-28 xBar Plugin auf SQLite umgestellt, [zusätzliche Quellen von KodiNerds](https://github.com/jnk22/entertain-iptv) ergänzt
* 2023-01-02 Version als xBar Plugin ergänzt
* 2022-12-29 FIX Einstellungsdatei, Umlaute, Streams vor Übernahme prüfen
* 2022-12-27 Playerauswahl nur wenn VLC installiert ist, SWR Sendergruppe wieder im Menü gelistet
* 2022-12-26 Python durch funktionsidentisches Bash Skript ersetzt
* 2022-12-23 subprocess durch plistlib ersetzt
* 2022-12-16 schnellere Menüdarstellung durch zusätzliches Bash Skript
* 2022-12-15 Caching des Sendermenüs ergänzt
* 2022-12-14 Einstellungsmenü zum An- und Abschalten der Sendersubmenüs und Wahlmöglichkeit des Videoplayers, QuickTime Player oder VLC ergänzt
* 2022-12-13 Erste Version

### Disclaimer
The menulet is provided as is. It is tested under macOS Ventura (Intel).
ZAPP and Playtypus are open source software, you can make a donation to the developers on their websites.

### Reference 
Die Streamadressen der ÖRR Sender werden aus dem Repository der **ZAPP** App für Android geladen.
[ZAPP](https://github.com/mediathekview/zapp) by Christine Coenens is an open-source Android mediathek app.  

Die anderen Listen stammen aus der **[IPTV Übersicht bei den KodiNerds](https://github.com/jnk22/kodinerds-iptv)**

**Platypus** wird verwendet, um das Skript als Menulet in der Menüleiste anzuzeigen.
[Platypus](https://sveinbjorn.org/platypus) by Sveinbjorn Thordarson creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
