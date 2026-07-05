# TV Menü für macOS

Mit **TV Menü** lassen sich die Programmstreams der öffentlich-rechtlichen Sender aus der Menüleiste heraus öffnen. 
Es gibt sowohl eine Standalone Version, als auch ein Plugin für xBar (und SwiftBar).

Es ist quasi eine aktualisierbare Bookmarkliste und **kein Ersatz** für Kodi oder ähnliche Programme.

![](/img/menu1.png)

Die aktuellste Standalone Version von **TV Menü** kann unter **[Releases](https://github.com/einstweilen/tvmenu/releases/)** heruntergeladen werden.
Falls Bedarf in der Standalone Version für die zusätzlichen Senderlisten der xBar Version besteht, bitte ein **[Issue eröffnen](https://github.com/einstweilen/tvmenu/issues)**.

Wer bereits [xBar](https://xbarapp.com/) oder [SwiftBar](https://github.com/swiftbar/SwiftBar) verwendet, kann statt der Stand-Alone-Version von **TV Menü** auch die über mehr Senderlisten verfügende Plugin-Version herunterladen.
**[Plugin Download und Anleitung](#tv-men%C3%BC-als-xbar-plugin)**

## Features
* über 30 Sender im Livestream in der Standalone Version
* über 200 Sender in der Plugin Version
* **Neu: MagentaTV (Multicast)** Senderliste integriert
* **Neu: Eigene Playlists** können per URL-Datei `.webloc` oder .m3u Datei, die in den Plugin-Support-Ordner gelegt werden, automatisch importiert werden.
* **Intelligente Gruppierung**: Sender werden automatisch anhand ihres Namens gruppiert (z.B. "OK ...", "Adult Swim ..."), was für eine übersichtliche, flache Hierarchie sorgt.
* Wiedergabe mit dem QuickTime Player oder mit VLC
* die Senderstreams lassen sich im QuickTime Player im normalen Fenster, im Vollbild oder auch als Schwebendes Fenster anzeigen
* die Senderliste kann bei Bedarf aktualisiert werden

## Verwendung
Das 📺 Symbol in der Menüleiste anklicken und aus dem Menü den gewünschten Sender auswählen.

![](/img/menukmpl1.png)

Sender mit gemeinsamen Namenspräfixen werden automatisch in Gruppen zusammengefasst, um das Menü übersichtlich zu halten.

![](/img/submenu1.png)

Ein im Menü ausgewählter Sender wird im Player abgespielt, für die Wiedergabe ist der QuickTime Player voreingestellt.
Damit nicht mehrere Streams gleichzeitig wiedergegeben werden, werden alle geöffneten Fenster des Players zuerst geschlossen.

## Einstellungsmenü
![](/img/einstellungen1.png)

### Sendergruppierung ausschalten
Die automatische Gruppierung der Sender kann abgeschaltet werden, um alle Sender in einer flachen Liste anzuzeigen.

![](/img/menukmpl1.png) ![](/img/menukmpl2.png)

Screenshot mit Gruppierung (links) und ohne (rechts)

### Wiedergabeplayer wechseln
Standardmäßig ist der QuickTime Player voreingestellt. Über "zu VLC wechseln" kann auf den VLC Player umgeschaltet werden, z.B. wenn man mehrere Monitore ohne getrennte Spaces verwendet oder Streams (wie MagentaTV Multicast) abspielen will, die nur in VLC laufen.

### Senderliste aktualisieren
**TV Menü** verwendet die Liste der Senderadressen aus der zu Mediathekview gehörenden [ZAPP](https://github.com/mediathekview/zapp) Android App sowie weitere Quellen. Sollten sich die Senderadressen ändern, kann mit _Senderliste aktualisieren_ (ganz unten im Senderlisten-Menü) eine neue Liste geladen werden.

# TV Menü als xBar / SwiftBar Plugin
Das [Plugin herunterladen](https://github.com/einstweilen/tvmenu/blob/main/tvmenu.1d.sh) und in das Plugin-Verzeichnis kopieren. 
Standardmäßig unter: `~/Library/Application Support/xbar/plugins` (xBar) oder `~/Library/Application Support/SwiftBar/plugins` (SwiftBar).

![](/img/xbarpluginfolder.png)

Sollte eine "Nicht ausführbar" Fehlermeldung angezeigt werden, im Terminal `chmod +x tvmenu.1d.sh` eingeben.

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
| MagentaTV | Alle MagentaTV Multicast Sender | iptv.blog |

Bei manchen **Lokalsendern** verweigert der QuickTime Player wegen Serverzertifikatsproblemen die Wiedergabe, dann im Menü **Einstellungen** auf den VLC Player umschalten.
**MagentaTV (Multicast)** Streams benötigen zwingend den VLC Player.

### Eigene Playlists
Um eigene M3U-Playlists hinzuzufügen, entweder `.m3u` Dateien in den Ordner `~/Library/Application Support/xbar/plugins/tvmenu_playlists` legen oder `.webloc` Dateien (die lassen sich durch Ziehen aus der Browseradressbar generieren) alternativ Textdateien mit einer URL. Das Plugin lädt die darin verlinkte M3U automatisch herunter. Der Filename der Datei wird als Listenname im Menü verwendet.

### History
* 2026-02-17 MagentaTV Multicast integriert, URL-Playlists, globale Smart-Groupierung
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

> **AI-Transparenzhinweis**<br>ca. 90% des Code wurden per Hand erstellt, danach Überarbeitung per Claude/Gemini

### Reference 
Die Streamadressen der ÖRR Sender werden aus dem Repository der **ZAPP** App für Android geladen.
[ZAPP](https://github.com/mediathekview/zapp) by Christine Coenens is an open-source Android mediathek app.  

Die anderen Listen stammen aus der **[IPTV Übersicht bei den KodiNerds](https://github.com/jnk22/kodinerds-iptv)**

**Platypus** wird verwendet, um das Skript als Menulet in der Menüleiste anzuzeigen.
[Platypus](https://sveinbjorn.org/platypus) by Sveinbjorn Thordarson creates native Mac applications from command line scripts such as shell scripts or Python, Perl, Ruby, Tcl, JavaScript and PHP programs.
