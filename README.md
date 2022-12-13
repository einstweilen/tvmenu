# TV Menü für macOS
**TV Menü** ist ein Python Skript für macOS, mit dem sich die Streams der öffentlich-rechtlichen Sender aus der Menüleiste heraus im QuickTime Player ansehen lassen.

![](/img/menu1.jpg)

Die aktuellste Version von **TV Menü** steht als ZIP-Datei unter [Releases](https://github.com/einstweilen/tvmenu/releases/) zur Verfügung.

## Feature
* über 30 Sender im Livestream
* Sender mit mehreren lokalen Streams werden zur besseren Übersicht in Submenüs zusammengefaßt

![](/img/submenu1.jpg)

* sollten sich die Streamadressen eines Senders zukünftig ändern, kann mit "Senderliste aktualisieren" eine neue Liste abgerufen werden

![](/img/refresh1.jpg)

* Die aufgerufenen Senderstreams lassen sich im QuickTime Player im normalen Fenster, im Vollbild oder auch als Schwebendes Fenster anzeigen.

![](/img/qtplayer1.jpg)

* Falls es vom Sender im Stream unterstützt wird, ist auch das Sprachmenü auswählbar

![](/img/qtoptionen1.jpg)


## Download und Installation
Die aktuelle Version von **TV Menü** steht als ZIP-Datei unter [Releases](https://github.com/einstweilen/tvmenu/releases/) zur Verfügung.

Nach dem Download **TV Menü.zip** mit einem Doppelklick entpacken und das entpackte Programm **TV Menü** in den Programmeordner kopieren. Es ist aber auch in jedem anderen Ordner ausführbar.

## Erster Start
**TV Menü** mit einem Doppelklick starten. Beim ersten Start des Programms erscheint der Hinweis, dass das Programm aus dem Internet geladen wurde und ob man es trotzdem öffnen möchte, diesen Hinweis mit Klick auf "Öffnen" bestätigen.

Jetzt erscheint in der Menüleiste das **TV Menü** Symbol 📺.

## Verwendung
Das 📺 Symbol in der Menüleiste anklicken und aus dem Menü den gewünschten Sender auswählen. Sender mit mehreren lokalen Streams werden zur besseren Übersicht in Submenüs zusammengefaßt


![](/img/menukmpl1.jpg)

Wird ein Sender ausgewählt öffnet sich der QuickTime Player und spielt den Stream ab. Je nach dem gewählten Sender und der eigenen Internetanbindung kann es 5 Sekunden dauern bis der erste Stream startet. 

Damit nicht mehrere Streams gleichzeitig wiedergegeben werden, werden alle geöffneten QuickTime Player Fenster zuerst geschlossen. Es kann einmalig ein Hinweis erscheinen, dass der QuickTime Player von **TV Menü** fernbedient wird.
Diesen Hinweis mit OK bestätigen.

![](/img/qtfirst1.jpg)

## History
2022-12-13 Erste Version

### Disclaimer
The menulet is provided as is. It is tested under macOS Ventura (Intel).
ZAPP and Playtypus are open source software, you can make a donation to the developers on their websites.

### Reference 
Die Streamadressen der Sender werden aus dem Repository von der ZAPP App für Android geladen.
[ZAPP](https://github.com/mediathekview/zapp) by Christine Coenens is an open-source Android mediathek app.  

Platypus wird verwendet, um das Skript als Menulet in der Menüleiste anzuzeigen.
[Platypus](https://sveinbjorn.org/platypus) by Sveinbjorn Thordarson creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
