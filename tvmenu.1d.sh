#!/usr/bin/env bash
# https://github.com/einstweilen/tvmenu
# 2023-01-02

#  <xbar.title>TV Menü</xbar.title>
#  <xbar.version>v1.0</xbar.version>
#  <xbar.author>Einstweilen</xbar.author>
#  <xbar.author.github>Einstweilen</xbar.author.github>
#  <xbar.desc>TV Streams der ÖR Sender / German public-service television broadcasters</xbar.desc>
#  <xbar.image>https://i.imgur.com/5vjg4ln.png</xbar.image>
#  <xbar.dependencies>bash</xbar.dependencies>
#  <xbar.abouturl>https://github.com/einstweilen/tvmenu</xbar.abouturl>

echo "📺" # echo "TV" Menu Icon/Text
echo "---"

if [ "$#" -eq 0 ]; then
    cached_sender="data/cached_sender.txt"
    cached_servicemenu="data/cached_servicemenu.txt"
    if [ -f "$cached_sender" ] && [ -f "$cached_servicemenu" ]; then
        cat "$cached_sender" "$cached_servicemenu"
        exit 0
    fi
fi

init(){
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cd "$DIR" || exit
    DIR_DATA="$DIR/tvmenu_data"
    mkdir -p "$DIR_DATA"
    channels_file="$DIR_DATA/channels.txt"
    channels_fixer="$DIR_DATA/channels_fix.txt"
    channels_all="$DIR_DATA/channels_all.txt"
    channels_menu_grup="$DIR_DATA/menu_gruppiert.txt"
    channels_menu_ohne="$DIR_DATA/menu_ohne.txt"
    cached_sender="$DIR_DATA/cached_sender.txt"
    cached_servicemenu="$DIR_DATA/cached_servicemenu.txt"
    channels_url='https://raw.githubusercontent.com/mediathekview/zapp/main/app/src/main/res/raw/channels.json'
    pref_file='com.einstweilen.tvmenu'
    item_selected="bash='$0' terminal=false refresh=true param1="
}

channels_fixes(){
echo "
tagesschau24|https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8
NDR Hamburg|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_hh/master.m3u8
NDR Niedersachsen|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_nds/master.m3u8
NDR Mecklenburg-Vorpommern|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_mv/master.m3u8
NDR Schleswig-Holstein|https://mcdn.ndr.de/ndr/hls/ndr_fs/ndr_sh/master.m3u8
SWR Baden-Württemberg|https://swrbwd-hls.akamaized.net/hls/live/2018672/swrbwd/master.m3u8
SWR Rheinland-Pfalz|https://swrrpd-hls.akamaized.net/hls/live/2018676/swrrpd/master.m3u8
" >> "$channels_fixer"
}

get_player(){
    defaults read "$pref_file" player 2>/dev/null || err=$?
    if [ "$err" ]; then
        defaults write "$pref_file" 'player' 'QuickTime'
        echo 'QuickTime'
    fi
}

get_submenu(){
    defaults read "$pref_file" submenus 2>/dev/null || err=$?
    if [ "$err" ]; then
        defaults write "$pref_file" 'submenus' 'an'
        echo 'aus'
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
    get_channels
    for channel in "${channels[@]}"; do
        sender="${channel%|*}"
        url="${channel##*|}"
        if [ "$sender" == "$1" ]; then
            player="$(get_player)"
            close_player_windows "$player"
            if [[ "$player" == 'QuickTime' ]]; then
                open -a 'QuickTime Player.app' -u "$url"
            else
                open -a 'VLC.app' -u "$url"
            fi
            exit 0
        fi
    done
   
    exit 1
}

get_channels(){
    if [ ! -f "$channels_all" ]; then
        if [ ! -f "$channels_file" ]; then
            raw=$(curl -s --max-time 9 "$channels_url")
            if [ "$?" -eq 0 ]; then
                IFS=$'\n' ch_rw=($(grep '"name"' <<< "$raw")) ; unset IFS
                IFS=$'\n' url_rw=($(grep '"stream_url"' <<< "$raw")) ; unset IFS
                if [[ ${#ch_rw[*]} -eq ${#url_rw[*]} ]] && [ ${#ch_rw[*]} -gt 0 ]; then
                    t='": "'
                    for ((i=0;i<${#ch_rw[*]}; i++)); do
                        n=${ch_rw[i]}; n=${n#*"$t"} ; n=${n:0:$((${#n} - 2))}
                        u=${url_rw[i]}; u=${u#*"$t"} ; u=${u:0:$((${#u} - 2))}
                        if [[ ! "$u" == *@* ]]; then
                            n=${n//\\u00ad/}
                            url_test=$(curl -sL "$u") 
                            if grep -q EXTM3U <<< "$url_test"; then
                                echo "$n|$u" | iconv -f UTF-8 -t UTF-8-MAC >> "$channels_file"
                            fi
                        fi
                    done
                else
                    if [ ! -f "$channels_file" ] && [ -f "$channels_file.bu" ]; then
                        mv -f "$channels_file.bu" "$channels_file"
                    else
                        echo "Updatefehler" > "$channels_file"
                    fi
                fi
            else
                if [ ! -f "$channels_file" ] && [ -f "$channels_file.bu" ]; then
                    mv -f "$channels_file.bu" "$channels_file"
                else
                     echo "Updatefehler" > "$channels_file"
                fi
            fi
        fi
        if [ ! -f "$channels_fixer" ]; then
            channels_fixes
        fi
        cat "$channels_file" "$channels_fixer" | sort -f  > "$channels_all"
        rm -f "$cached_sender"
    fi
    unset channels
    IFS=$'\n' read -d '' -r -a channels < "$channels_all"
}

channels_update(){
    rm -f "$channels_all"
    mv -f "$channels_file" "$channels_file.bu"
    rm -f "$cached_sender"
    rm -f "$channels_menu_grup"
    rm -f "$channels_menu_ohne"
    menu_ausgeben
}

menu_ausgeben(){
    update_sendermenu
    update_servicemenu
    cat "$cached_sender" "$cached_servicemenu"
}

update_sendermenu(){
    if [ ! -f "$channels_menu_grup" ] || [ ! -f "$channels_menu_ohne" ] || [ ! -f "$cached_sender" ]; then
        unset sender_menu 
        unset sender_gruppen 
        get_channels
        for channel in "${channels[@]}"; do
            sender="${channel%|*}"
            url="${channel##*|}"
            sendername="$sender"
            sender_menu+=("$sendername")
            sender_gruppen+=("${sendername%% *}")
        done
        IFS=$'\n' sender_menu=($(sort -f <<<"${sender_menu[*]}")); unset IFS
        IFS=$'\n' sender_gruppen=($(sort -f <<<"${sender_gruppen[*]}")); unset IFS
        gruppen_min=2
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
        the_menu="$channels_menu_grup"
        rm -f "$the_menu"
        item_selected="bash='$0' trim=false terminal=false refresh=true param1="
        for sendername in "${sender_menu[@]}"; do
            gruppe="${sendername%% *}"
            if [[ " ${gruppen_submenu[*]} " =~ ${gruppe} ]]; then 
                if [[ ${gruppe} != "${gruppe_aktuell}" ]]; then 
                    echo "${gruppe}" >> "$the_menu"
                    gruppe_aktuell="$gruppe"
                fi
                echo "--${sendername#* } | $item_selected'${sendername}'" >> "$the_menu" 
            else
                echo "${sendername} | $item_selected'${sendername}'" >> "$the_menu"
            fi
        done
        echo '---'  >> "$the_menu"
        the_menu="$channels_menu_ohne"
        rm -f "$the_menu"
        for sendername in "${sender_menu[@]}"; do
            echo "${sendername} | $item_selected'${sendername}'"  >> "$the_menu"
        done
        echo '---'  >> "$the_menu"
    fi
    sender_menu_aktivieren
}

sender_menu_aktivieren(){
    submenu=$(get_submenu)
    if [[ $submenu == 'an' ]]; then
         cp "$channels_menu_grup" "$cached_sender" 2>/dev/null || :
    else
         cp "$channels_menu_ohne" "$cached_sender" 2>/dev/null || :
    fi
}

update_servicemenu(){
   
    the_menu="$cached_servicemenu"
    echo "Einstellungen" > "$the_menu"
    if check_VLC ; then
        player=$(get_player)
        if [[ $player == 'QuickTime' ]]; then
            echo "--VLC verwenden | $item_selected'VLC verwenden'" >> "$the_menu"
        else
            echo "--QT Player verwenden | $item_selected'QT Player verwenden'" >> "$the_menu"
        fi
    else
        echo "--VLC verwenden" >> "$the_menu"
    fi

    submenu=$(get_submenu)
    if [[ $submenu == 'an' ]]; then
        echo "--Gruppierung ausschalten | $item_selected'Gruppierung ausschalten'" >> "$the_menu"
    else
        echo "--Sender gruppieren | $item_selected'Sender gruppieren'" >> "$the_menu"
    fi
    echo "---"
    echo "--Senderliste aktualisieren | $item_selected'Senderliste aktualisieren'" >> "$the_menu"
}

init
if [ "$#" -gt 0 ]; then
    parameter="$*"
    case "$parameter" in
        'Senderliste aktualisieren')
            channels_update
            exit 0
            ;;
        'Updatefehler')
            channels_update
            exit 0
            ;;
        'VLC verwenden')
            if check_VLC ; then
                defaults write "$pref_file" 'player' 'VLC'
            fi
            ;;
        'QT Player verwenden')
            defaults write "$pref_file" 'player' 'QuickTime'
            ;;
        'Gruppierung ausschalten')
            defaults write "$pref_file" 'submenus' 'aus'
            ;;
        'Sender gruppieren')
            defaults write "$pref_file" 'submenus' 'an'
            ;;
        *)
            stream_abspielen "$parameter"
            exit 0
            ;;
    esac
    if [[ "$parameter" == 'VLC verwenden' ]] || [[ "$parameter" == 'QT Player verwenden' ]]; then
        update_servicemenu
    fi
    if [[ "$parameter" == 'Sender gruppieren' ]] || [[ "$parameter" == 'Gruppierung ausschalten' ]]; then
        update_servicemenu
        sender_menu_aktivieren
    fi
    cat "$cached_sender" "$cached_servicemenu"
    exit 0
else
    menu_ausgeben
fi
exit 0