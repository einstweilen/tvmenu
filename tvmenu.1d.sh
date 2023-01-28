#!/usr/bin/env bash
# https://github.com/einstweilen/tvmenu
# 2023-01-28

#  <xbar.title>TV Menü</xbar.title>
#  <xbar.version>v2</xbar.version>
#  <xbar.author>Einstweilen</xbar.author>
#  <xbar.author.github>Einstweilen</xbar.author.github>
#  <xbar.desc>TV Streams der ÖR Sender / German public-service television broadcasters</xbar.desc>
#  <xbar.image>https://i.imgur.com/5vjg4ln.png</xbar.image>
#  <xbar.dependencies>bash</xbar.dependencies>
#  <xbar.abouturl>https://github.com/einstweilen/tvmenu_xbar</xbar.abouturl>

check_database(){
    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS senderlisten (liste TEXT, sendername TEXT, url TEXT UNIQUE);"
            # Senderlistenkürzel, Sendername, StreamURL

    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS menuitems (menuart TEXT, liste TEXT, item TEXT, command TEXT);"
            # Menuart, Kürzel der Senderliste, im Menü angezeigter Text, Befehle bei Auswahl 
            # menuart: Sender G=gruppiert, N=nicht gruppiert  
            # menuart: L=Senderlisten, S=Servicemenü
    
    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS settings (key TEXT UNIQUE, value TEXT);"
            # key: senderliste v: Kürzel der aktuell angezeigten Liste
            # key: player QuickTime|VLC, gruppierung an|aus

    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM settings;") -lt 3 ] ; then
        settings 'senderliste' 'oerr'
        settings 'player' 'QuickTime'
        settings 'gruppierung' 'an'
    fi

    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM senderlisten;") -eq 0 ] ; then
        get_channels
        update_sendermenu
        update_settings_submenu
    fi
}

settings(){
    if [ -n "$1" ]; then
        if [ -n "$2" ]; then 
            sqlite3 .tvmenu.db "REPLACE INTO settings VALUES (\"$1\", \"$2\");"
        else
            sqlite3 .tvmenu.db "SELECT value FROM settings WHERE key=\"$1\";"
        fi
     fi
}

check_VLC(){
    mdfind kind:application -name 'VLC' 2>/dev/null | grep -q 'VLC.app' && return 0 || return 1
}

close_player_windows(){ 
    if [[ "$1" == 'QuickTime' ]]; then
        osascript -e 'tell application "QuickTime Player" to close every window' >> /dev/null 2>&1
    else
        osascript -e 'tell application "VLC" to close every window' >> /dev/null 2>&1
    fi
}

stream_abspielen(){
    url=$(sqlite3 .tvmenu.db "SELECT url FROM senderlisten WHERE liste=\"$(settings senderliste)\" AND sendername=\"$1\";")
    if [ ! -z $url ]; then
        player="$(settings player)"
        close_player_windows "$player"
        if [[ "$player" == 'QuickTime' ]]; then
            open -a 'QuickTime Player.app' -u "$url"
        else
            open -a 'VLC.app' -u "$url"
        fi
        exit 0
    fi
    exit 1 # kein passender Senderstream in der DB gefunden
}

get_channels(){
    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM senderlisten") -eq 0 ]; then
        get_channels_zapp
        get_channels_konerd
        # Doppelte und nicht abspielbare Streams löschen
        sqlite3 .tvmenu.db "DELETE FROM senderlisten WHERE rowid NOT IN (SELECT min(rowid) FROM senderlisten GROUP BY url);"
        sqlite3 .tvmenu.db "DELETE FROM senderlisten WHERE url LIKE '%@%';"
    fi
}

get_channels_zapp(){
    ch_url='https://raw.githubusercontent.com/mediathekview/zapp/main/app/src/main/res/raw/channels.json'
    raw=$(curl -s --max-time 9 "$ch_url")
    if [ "$?" -eq 0 ]; then
        IFS=$'\n' ch_raw=($(grep '"name"' <<< "$raw")) ; unset IFS
        IFS=$'\n' url_raw=($(grep '"stream_url"' <<< "$raw")) ; unset IFS
        # Sicherheitsabfrage falls beim Parsen Fehler aufgetreten sind
        if [[ ${#ch_raw[*]} -eq ${#url_raw[*]} ]] && [ ${#ch_raw[*]} -gt 0 ]; then
            t='": "' # Trennzeichen
            for ((i=0;i<${#ch_raw[*]}; i++)); do
                n=${ch_raw[i]}; n=${n#*"$t"} ; n=${n:0:$((${#n} - 2))}
                u=${url_raw[i]}; u=${u#*"$t"} ; u=${u:0:$((${#u} - 2))}
                n=${n//\\u00ad/} # Shy bedingter Trennstrich entfernen 
                sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES (\"oerr\", \"${n}\", \"${u}\");"
            done
        fi
    fi

    # Ersatz für ZAPP Streams die nicht mit QT funktionieren
    declare -a fixes=(
        'tagesschau24|https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8'
        'NDR Hamburg|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_hh/master.m3u8'
        'NDR Niedersachsen|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_nds/master.m3u8'
        'NDR Mecklenburg-Vorpommern|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_mv/master.m3u8'
        'NDR Schleswig-Holstein|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_sh/master.m3u8'
        'SWR Baden-Württemberg|https://swrbwd-hls.akamaized.net/hls/live/2018672/swrbwd/master.m3u8'
        'SWR Rheinland-Pfalz|https://swrrpd-hls.akamaized.net/hls/live/2018676/swrrpd/master.m3u8'
        )
    for fix in "${fixes[@]}"; do
        sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES (\"oerr\", \"${fix%%|*}\", \"${fix##*|}\");"
    done
}

get_channels_konerd(){
    declare -a kodinerds_channels=(
        'sonst|https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_main.m3u'
        'lokal|https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_local.m3u'
        'ach|https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_atch.m3u'
        'usuk|https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_usuk.m3u'
        'inter|https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_international.m3u'
        )
    for kodinerds in "${kodinerds_channels[@]}"; do
        kn_liste="${kodinerds%|*}"
        kn_url="${kodinerds##*|}"
        ch_raw=$(curl -s "$kn_url")
        IFS=$'\n'
            ch_info=($(grep "^#EXTINF" <<<"$ch_raw"))
            ch_url=($(grep "^http" <<<"$ch_raw"))
        unset IFS
        if [ ${#ch_info[*]} -eq ${#ch_url[*]} ]; then
            for ((i = 0 ; i < ${#ch_url[*]} ; i++)); do
                info_name=$(cut -d'"' -f 2 <<<"${ch_info[i]}")
                sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES (\"${kn_liste}\", \"${info_name}\", \"${ch_url[i]}\");"
            done
        fi
    done
    # Fix für Gruppierungserkennug
    sqlite3 .tvmenu.db "UPDATE senderlisten SET sendername = REPLACE(sendername, 'Adult Swim', 'AdultSwim');"
}

force_update(){
    sqlite3 .tvmenu.db "DELETE FROM senderliste;"
    sqlite3 .tvmenu.db "DELETE FROM menuitems;"
    get_channels
    update_sendermenu
}

update_sendermenu(){
    sqlite3 .tvmenu.db "DELETE FROM menuitems;"
    unset listen
    IFS=$'\n' read -rd '' -a listen < <(sqlite3 .tvmenu.db "SELECT DISTINCT liste FROM senderlisten;");
    unset IFS

    for akt_senderliste in "${listen[@]}"; do
        unset channels
        unset sender_menu
        IFS=$'\n' read -rd '' -a channels < <(sqlite3 .tvmenu.db "SELECT sendername FROM senderlisten WHERE liste=\"$akt_senderliste\" ORDER BY sendername COLLATE NOCASE;")
        unset IFS
        for channel in "${channels[@]}"; do
            sender="${channel%|*}"
            url="${channel##*|}"
            sendername="$sender"
            sender_menu+=("$sendername")
        done

        unset sender_gruppen
        IFS=$'\n'
            sender_menu=($(sort -f <<<"${sender_menu[*]}"))
            read -rd '' -a sender_gruppen < <(sqlite3 .tvmenu.db "SELECT SUBSTR(sendername, 1, INSTR(sendername, ' ')) FROM senderlisten GROUP BY SUBSTR(sendername, 1, INSTR(sendername, ' ')) HAVING COUNT(*) > 1;")
        unset IFS

        unset gruppen_submenu
        temp="" ; temp_c=0
        for ((i=0;i<${#sender_gruppen[*]}; i++)); do
            if [[ ${sender_gruppen[i]} == "$temp" ]]; then
                ((temp_c++))
            else
                temp="${sender_gruppen[i]}"
                temp_c=1
            fi
            if [[ temp_c -ge gruppen_min ]] && [[ ! " ${gruppen_submenu[*]} " =~ ${sender_gruppen[i]} ]]; then
                gruppen_submenu+=("${sender_gruppen[i]}")
            fi
        done

        gruppe_aktuell=""
        for sendername in "${sender_menu[@]}"; do
            gruppe="${sendername%% *}"
            if [[ " ${gruppen_submenu[*]} " =~ ${gruppe} ]]; then
                if [[ ${gruppe} != "${gruppe_aktuell}" ]]; then
                    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${gruppe}\", '');"
                    gruppe_aktuell="$gruppe"
                fi
                item="--${sendername}"
                command="$item_selected'${sendername}'"
                sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${item}\", \"${command}\");"
            else
                item="${sendername}"
                command="$item_selected'${sendername}'"
                sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${item}\", \"${command}\");"
            fi
            item="${sendername}"
            command="$item_selected'${sendername}'"
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('N', \"${akt_senderliste}\", \"${item}\", \"${command}\");"
        done
    done
    senderlisten_auswahl_anlegen
}

senderlisten_auswahl_anlegen(){
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', '---', '');"
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', 'Senderlisten', '');"
    IFS=$'\n'
        for liste in $(sqlite3 .tvmenu.db "SELECT DISTINCT liste FROM senderlisten;"); do
            command="${item_selected}list_${liste}"
            # Senderlistenkürzel in Menüdarstellung ändern
            liste=${liste/oerr/D ÖRR}
            liste=${liste/sonst/D Sonstige}
            liste=${liste/lokal/D lokal}
            liste=${liste/ach/A CH}
            liste=${liste/usuk/US UK}
            liste=${liste/inter/International}
            item="--${liste}"
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', \"${item}\", \"${command}\");"
        done
    unset IFS
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', '---', '');"
}

update_settings_submenu(){
    sqlite3 .tvmenu.db "DELETE FROM menuitems WHERE menuart='S';"

    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', 'Einstellungen', '');"
    if check_VLC ; then
        player=$(settings player)
        if [[ $player == 'QuickTime' ]]; then
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--VLC verwenden', \"$item_selected'VLC verwenden'\");"
        else
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--QT Player verwenden', \"$item_selected'QT Player verwenden'\");"
        fi
    else
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--VLC verwenden', '');"
    fi

    submenu=$(settings gruppierung)
    if [[ $submenu == 'an' ]]; then
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--Gruppierung ausschalten', \"$item_selected'Gruppierung ausschalten'\");"
    else
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--Sender gruppieren', \"$item_selected'Sender gruppieren'\");"
    fi
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--Senderlisten aktualisieren', \"$item_selected'Senderlisten aktualisieren'\");"
}

menu_ausgeben(){
    submenu=$(settings gruppierung)
    akt_senderliste=$(settings senderliste)
    if [[ $submenu == 'an' ]]; then
        menuart='G'
    else
        menuart='N'
    fi
    sqlite3 .tvmenu.db "SELECT item, command FROM menuitems WHERE menuart=\"$menuart\" AND liste=\"$akt_senderliste\";" # aktuelle Senderliste
    sqlite3 .tvmenu.db "SELECT item, command FROM menuitems WHERE menuart='L';" # Submenü Senderlisten
    sqlite3 .tvmenu.db "SELECT item, command FROM menuitems WHERE menuart='S';" # Submenü Servicemenu
}

# Main
echo "📺" # echo "TV" # Menubar Icon/Text
echo "---"

item_selected="bash='$0' terminal=false refresh=true param1="
check_database

# Übergabeparameter auswerten
if [ "$#" -gt 0 ]; then
    parameter="$*"
    case "$parameter" in
        'Senderlisten aktualisieren')
            force_update
            ;;
        'VLC verwenden')
            if check_VLC ; then
                settings 'player' 'VLC'
            fi
            ;;
        'QT Player verwenden')
            settings 'player' 'QuickTime'
            ;;
        'Gruppierung ausschalten')
            settings 'gruppierung' 'aus'
            ;;
        'Sender gruppieren')
            settings 'gruppierung' 'an'
            ;;
        [l][i][s][t]*)
            settings 'senderliste' "${parameter##*_}"
            ;;
        *)
            stream_abspielen "$parameter"
            exit 0 # Menuausgabe nicht notwendig
            ;;
    esac
    if [[ "$parameter" == 'VLC verwenden' ]] || [[ "$parameter" == 'QT Player verwenden' ]]; then
        update_settings_submenu
    fi
    if [[ "$parameter" == 'Sender gruppieren' ]] || [[ "$parameter" == 'Gruppierung ausschalten' ]]; then
        update_settings_submenu
    fi
fi
menu_ausgeben
exit 0