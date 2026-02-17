#!/usr/bin/env bash
# https://github.com/einstweilen/tvmenu
# 2026-02-17

#  <xbar.title>TV Menü</xbar.title>
#  <xbar.version>v2</xbar.version>
#  <xbar.author>Einstweilen</xbar.author>
#  <xbar.author.github>Einstweilen</xbar.author.github>
#  <xbar.desc>Start TV Streams from the menu bar</xbar.desc>
#  <xbar.image>https://i.imgur.com/5vjg4ln.png</xbar.image>
#  <xbar.dependencies>bash</xbar.dependencies>
#  <xbar.abouturl>https://github.com/einstweilen/tvmenu_xbar</xbar.abouturl>

check_database(){
    if [ ! -f .tvmenu.db ]; then
    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS listenquellen (
        qname_intern TEXT, -- Ein Kürzel für die Quelle
        qname_menu TEXT, -- Die Bezeichnung der Quelle, die im Menü angezeigt wird
        qimporter TEXT, -- Die zu verwendende Importfunktion
        qurl TEXT UNIQUE -- Die Adresse der Quelle
);"

    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM listenquellen;") -eq 0 ] ; then
        declare -a quellen=(
            'oerr,D ÖRR,zapp,https://raw.githubusercontent.com/mediathekview/zapp/main/app/src/main/res/raw/channels.json'
            'sonst,D Sonstige,kodi,https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_main.m3u'
            'lokal,D lokal,kodi,https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_local.m3u'
            'magenta,MagentaTV (Multicast),magenta,https://db.iptv.blog/multicastadressliste/m3u'
            'ach,AT CH,kodi,https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_atch.m3u'
            'usuk,US UK,kodi,https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_usuk.m3u'
            'inter,International,kodi,https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/clean/clean_tv_international.m3u'
            )
        for i in "${quellen[@]}"; do
            IFS=","
                read -a qval <<< "$i"
                sqlite3 .tvmenu.db "INSERT INTO listenquellen VALUES ('${qval[0]}', '${qval[1]}', '${qval[2]}', '${qval[3]}');"
            unset IFS
        done
    fi
    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS senderlisten (liste TEXT, sendername TEXT, url TEXT, group_name TEXT);"
            # Senderlistenkürzel, Sendername, StreamURL, Gruppenname

    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS menuitems (menuart TEXT, liste TEXT, item TEXT, command TEXT);"
            # Menuart, Kürzel der Senderliste, im Menü angezeigter Text, Befehle bei Auswahl 
            # menuart: Sender G=gruppiert, N=nicht gruppiert  
            # menuart: L=Senderlisten, S=Servicemenü
    
    # Index for speed
    sqlite3 .tvmenu.db "CREATE INDEX IF NOT EXISTS idx_menuitems_lookup ON menuitems(menuart, liste);"
    
    sqlite3 .tvmenu.db "CREATE TABLE IF NOT EXISTS settings (key TEXT UNIQUE, value TEXT);"
            # key: senderliste v: Kürzel der aktuell angezeigten Liste
            # key: player QuickTime|VLC, gruppierung an|aus

    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM settings;") -lt 3 ] ; then
        # Standardeinstellungen
        settings 'senderliste' 'oerr'
        settings 'player' 'QuickTime'
        settings 'gruppierung' 'an'
    fi

    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM senderlisten;") -eq 0 ] ; then
        get_channels
        update_sendermenu
        update_settings_submenu
    fi
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
        # Sonderfall rtp Streams immer mit VLC öffnen
        if [[ $url == *@* ]]; then
            open -a 'VLC.app' -u "$url"
            exit 0
        fi
        if [[ "$player" == 'QuickTime' ]]; then
            open -a 'QuickTime Player.app' -u "$url"
        else
            open -a 'VLC.app' -u "$url"
        fi
        exit 0
    fi
    exit 1 # kein passender Senderstream in der DB gefunden
}

get_new_channels(){
    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM senderlisten") -eq 0 ]; then
        records=$(sqlite3 .tvmenu.db "SELECT replace(Value, '\n', '') FROM listenquellen")
    fi

    result=$(sqlite3 -separator ' ' .tvmenu.db "SELECT * FROM listenquellen;")

    echo "1# $result"

    while read -r line; do
        my_array+=("$line")
        echo "> $line"
    done <<< "$result"
}


import_m3u_file() {
    local file="$1"
    local list_name="$2"
    local default_group="$3"
    
    [[ -f "$file" ]] || return 1
    
    local current_group="$default_group"
    local current_name=""
    local url=""

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        [[ -z "$line" ]] && continue

        if [[ "$line" == \#EXTINF:* ]]; then
            # Reset group to default
            current_group="$default_group"

            if [[ "$line" =~ group-title=\"([^\"]*)\" ]]; then
                current_group="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ group-title=([^,]*), ]]; then
                 current_group="${BASH_REMATCH[1]}"
            fi
            
            current_name="${line##*,}"
            current_name="${current_name#"${current_name%%[![:space:]]*}"}"
            current_name="${current_name%"${current_name##*[![:space:]]}"}"
            
        elif [[ "$line" != \#* ]]; then
             url="$line"
             if [[ -n "$current_name" ]] && [[ -n "$url" ]]; then
                 sqlite3 .tvmenu.db "INSERT INTO senderlisten VALUES ('$list_name', '$current_name', '$url', '$current_group');"
                 current_name=""
             fi
        fi
    done < "$file"
}

get_local_playlists() {
    local playlist_dir="$HOME/Library/Application Support/xbar/plugins/tvmenu_playlists"
    mkdir -p "$playlist_dir"
    shopt -s nullglob
    for pl_file in "$playlist_dir"/*; do
        [[ -f "$pl_file" ]] || continue
        
        local filename=$(basename "$pl_file")
        local name_no_ext="${filename%.*}"
        
        if [[ "$filename" == *.m3u ]]; then
            import_m3u_file "$pl_file" "$name_no_ext" "Allgemein"
        else
            local extracted_url=""
            if grep -q "<key>URL</key>" "$pl_file"; then
                extracted_url=$(grep -A 1 "<key>URL</key>" "$pl_file" | grep "<string>" | sed -e 's/.*<string>//' -e 's/<\/string>.*//' | tr -d '\t ')
            fi

            if [[ -n "$extracted_url" ]]; then
                local temp_m3u="/tmp/tvmenu_import_${name_no_ext}.m3u"
                curl -s --max-time 10 "$extracted_url" > "$temp_m3u"
                
                if [[ -s "$temp_m3u" ]]; then
                    if grep -q "#EXTM3U" "$temp_m3u" || grep -q "#EXTINF" "$temp_m3u"; then
                        import_m3u_file "$temp_m3u" "$name_no_ext" "Allgemein"
                    fi
                fi
                rm -f "$temp_m3u"
            fi
        fi
    done
    shopt -u nullglob
}

get_channels(){
    if [ $(sqlite3 .tvmenu.db "SELECT COUNT(*) FROM senderlisten") -eq 0 ]; then
        get_local_playlists
        get_channels_zapp
        get_channels_konerd
        # Doppelte und nicht abspielbare Streams löschen
        sqlite3 .tvmenu.db "DELETE FROM senderlisten WHERE rowid NOT IN (SELECT min(rowid) FROM senderlisten GROUP BY url);"
        sqlite3 .tvmenu.db "DELETE FROM senderlisten WHERE url LIKE '%@%';"
        get_channels_magenta
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
                sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES (\"oerr\", \"${n}\", \"${u}\", \"Allgemein\");"
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
        sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES (\"oerr\", \"${fix%%|*}\", \"${fix##*|}\", \"Allgemein\");"
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
        
        # Download to temp file
        local temp_m3u="/tmp/tvmenu_konerd_${kn_liste}.m3u"
        if curl -s --max-time 10 "$kn_url" > "$temp_m3u"; then
            if [[ -s "$temp_m3u" ]]; then
                 import_m3u_file "$temp_m3u" "$kn_liste" "Allgemein"
            fi
            rm -f "$temp_m3u"
        fi
    done
    # Fix für Gruppierungserkennug
    sqlite3 .tvmenu.db "UPDATE senderlisten SET sendername = REPLACE(sendername, 'Adult Swim', 'AdultSwim');"
}

get_channels_magenta(){
    local mag_url='https://db.iptv.blog/multicastadressliste/m3u'
    local raw_m3u
    raw_m3u=$(curl -s --max-time 10 "$mag_url")
    
    if [[ $? -eq 0 && -n "$raw_m3u" ]]; then
        # Parse M3U
        # Expected format:
        # #EXTINF:-1,(1) Das Erste HD
        # rtp://...
        
        while IFS= read -r line; do
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" ]] && continue
            
            if [[ "$line" == \#EXTINF:* ]]; then
                current_name="${line##*,}"
                
                if [[ "$current_name" =~ ^\([0-9]+\)[[:space:]]*(.*) ]]; then
                    current_name="${BASH_REMATCH[1]}"
                fi
                
                current_name="${current_name#"${current_name%%[![:space:]]*}"}"
                current_name="${current_name%"${current_name##*[![:space:]]}"}"

                if [[ "$current_name" == *" SD" ]]; then
                    continue
                fi
                
            elif [[ "$line" != \#* ]]; then
                 url="$line"
                 if [[ -n "$current_name" ]] && [[ -n "$url" ]]; then
                     sqlite3 .tvmenu.db "INSERT OR IGNORE INTO senderlisten VALUES ('magenta', '$current_name', '$url', 'MagentaTV (Multicast)');"
                     current_name=""
                 fi
            fi
        done <<< "$raw_m3u"
    fi
}

force_update(){
    sqlite3 .tvmenu.db "DELETE FROM senderlisten;"
    sqlite3 .tvmenu.db "DELETE FROM menuitems;"
    get_channels
    update_sendermenu
}

cluster_channels_by_prefix() {
    local akt_senderliste="$1"
    local grp="$2"
    local grp_channels=()

    while IFS= read -r channel; do
        grp_channels+=("$channel")
    done < <(sqlite3 .tvmenu.db "SELECT sendername FROM senderlisten WHERE liste=\"$akt_senderliste\" AND group_name=\"$grp\" ORDER BY sendername;")

    for sender in "${grp_channels[@]}"; do
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('N', \"${akt_senderliste}\", \"${sender}\", \"$item_selected'${sender}'\");"
    done

    local current_prefix=""
    local buffer=()
    local buffer_prefix=""

    for sender in "${grp_channels[@]}"; do
        local prefix=""
        if [[ "$sender" == *" "* ]]; then
            prefix="${sender%% *}"
        else
            prefix="NO_GROUP_$(date +%s%N)_$sender" 
        fi
        
        if [[ "$prefix" != "$current_prefix" ]]; then
            if [[ ${#buffer[@]} -gt 0 ]]; then
                if [[ ${#buffer[@]} -gt 1 ]] && [[ $(settings gruppierung) == 'an' ]]; then
                    local header="${buffer_prefix}"
                    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${header}\", '');"
                    for item in "${buffer[@]}"; do
                        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"--${item}\", \"$item_selected'${item}'\");"
                    done
                else
                    # Flat
                    for item in "${buffer[@]}"; do
                        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${item}\", \"$item_selected'${item}'\");"
                    done
                fi
            fi
            # Reset
            current_prefix="$prefix"
            if [[ "$sender" == *" "* ]]; then
               buffer_prefix="${sender%% *}"
            else
               buffer_prefix=""
            fi
            buffer=("$sender")
        else
            buffer+=("$sender")
        fi
    done
    
    # Final flush
    if [[ ${#buffer[@]} -gt 0 ]]; then
        if [[ ${#buffer[@]} -gt 1 ]] && [[ $(settings gruppierung) == 'an' ]]; then
            local header="${buffer_prefix}"
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${header}\", '');"
            for item in "${buffer[@]}"; do
                sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"--${item}\", \"$item_selected'${item}'\");"
            done
        else
            for item in "${buffer[@]}"; do
                sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('G', \"${akt_senderliste}\", \"${item}\", \"$item_selected'${item}'\");"
            done
        fi
    fi
}

update_sendermenu(){
    sqlite3 .tvmenu.db "DELETE FROM menuitems;"

    while IFS= read -r akt_senderliste; do
        if [[ -z "$akt_senderliste" ]]; then continue; fi
        local distinct_groups=()
        while IFS= read -r grp; do
            distinct_groups+=("$grp")
        done < <(sqlite3 .tvmenu.db "SELECT DISTINCT group_name FROM senderlisten WHERE liste=\"$akt_senderliste\" ORDER BY group_name;")

        if [[ ${#distinct_groups[@]} -eq 0 ]]; then continue; fi
        
        for grp in "${distinct_groups[@]}"; do
             cluster_channels_by_prefix "$akt_senderliste" "$grp"
        done
    done < <(sqlite3 .tvmenu.db "SELECT DISTINCT liste FROM senderlisten;")
    
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
            liste=${liste/ach/AT CH}
            liste=${liste/usuk/US UK}
            liste=${liste/inter/International}
            liste=${liste/magenta/MagentaTV (Multicast)}
            item="--${liste}"
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', \"${item}\", \"${command}\");"
        done
    unset IFS
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', '-----', '');"
    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('L', '', '--Senderlisten aktualisieren', \"$item_selected'Senderlisten aktualisieren'\");"
}

update_settings_submenu(){
    sqlite3 .tvmenu.db "DELETE FROM menuitems WHERE menuart='S';"

    sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', 'Einstellungen', '');"
    if check_VLC ; then
        player=$(settings player)
        if [[ $player == 'QuickTime' ]]; then
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--zu VLC wechseln', \"$item_selected'zu VLC wechseln'\");"
        else
            sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--zu QT Player wechseln', \"$item_selected'zu QT Player wechseln'\");"
        fi
    else
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--zu VLC wechseln', '');"
    fi

    submenu=$(settings gruppierung)
    if [[ $submenu == 'an' ]]; then
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--Gruppierung ausschalten', \"$item_selected'Gruppierung ausschalten'\");"
    else
        sqlite3 .tvmenu.db "INSERT INTO menuitems VALUES ('S', '', '--Sender gruppieren', \"$item_selected'Sender gruppieren'\");"
    fi
}

force_update(){
    sqlite3 .tvmenu.db "DELETE FROM senderlisten;"

    sqlite3 .tvmenu.db "CREATE INDEX IF NOT EXISTS idx_menuitems_lookup ON menuitems(menuart, liste);"
    get_channels
    update_sendermenu
    update_settings_submenu
}

menu_ausgeben(){
    read -r submenu akt_senderliste < <(sqlite3 .tvmenu.db "SELECT (SELECT value FROM settings WHERE key='gruppierung'), (SELECT value FROM settings WHERE key='senderliste');" -separator ' ')

    if [[ $submenu == 'an' ]]; then
        menuart='G'
    else
        menuart='N'
    fi
    echo "---"
    sqlite3 .tvmenu.db "SELECT item, command FROM menuitems WHERE menuart=\"$menuart\" AND liste=\"$akt_senderliste\"; SELECT item, command FROM menuitems WHERE menuart='L'; SELECT item, command FROM menuitems WHERE menuart='S';"
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
        'zu VLC wechseln')
            if check_VLC ; then
                settings 'player' 'VLC'
            fi
            update_settings_submenu
            ;;
        'zu QT Player wechseln')
            settings 'player' 'QuickTime'
            update_settings_submenu
            ;;
        'Gruppierung ausschalten')
            settings 'gruppierung' 'aus'
            update_settings_submenu
            ;;
        'Sender gruppieren')
            settings 'gruppierung' 'an'
            update_settings_submenu
            ;;
        list_*)
            settings 'senderliste' "${parameter##*_}"
            ;;
        *)
            stream_abspielen "$parameter"
            exit 0 # Menuausgabe nicht notwendig
            ;;
    esac
fi
menu_ausgeben
exit 0
