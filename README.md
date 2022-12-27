# TV Menü für macOS
**TV Menü** ist ein Menulet für macOS, mit dem sich die Streams der öffentlich-rechtlichen Sender aus der Menüleiste heraus öffnen lassen.

![](/img/menu1.png)

Die aktuellste Version von **TV Menü** kann unter [Releases](https://github.com/einstweilen/tvmenu/releases/) heruntergeladen werden.

## Feature
* über 30 Sender im Livestream
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

### Senderliste aktualisieren
**TV Menü** verwendet die Liste der Senderadressen aus der zu Mediathekview gehörenden [ZAPP](https://github.com/mediathekview/zapp) Android App. Sollten sich die Senderadressen ändern, kann mit _Senderliste aktualisieren_  eine neue Liste von der ZAPP Projektseite geladen werden.

## History
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
Die Streamadressen der Sender werden aus dem Repository von der **ZAPP** App für Android geladen.
[ZAPP](https://github.com/mediathekview/zapp) by Christine Coenens is an open-source Android mediathek app.  

**Platypus** wird verwendet, um das Skript als Menulet in der Menüleiste anzuzeigen.
[Platypus](https://sveinbjorn.org/platypus) by Sveinbjorn Thordarson creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
