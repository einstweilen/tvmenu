#!/usr/local/bin/python3

# TV Menü 1.1.1
# https://github.com/einstweilen/tvmenu

import sys
import os
import requests
import json
import unicodedata
import subprocess

os.chdir(os.path.dirname(os.path.abspath(__file__)))
if not os.path.exists('data'):
    os.makedirs('data')

pref_file = 'com.einstweilen.tvmenu'
channels_file = 'data/channels.json'
channels_backup_file = 'data/channels_backup.json'
channels_fixer = 'data/channels_fix.json'  # korrigierte und zusätzliche Channels
channels_all = 'data/channels_all.json'
channel_url = "https://raw.githubusercontent.com/mediathekview/zapp/main/app/src/main/res/raw/channels.json"

menu_kmpl = "data/menu_kmpl.txt"

# Aufrufcommandos für die Streamplayer
players = {
            "QuickTime": "open -a QuickTime\ Player.app -u",
            "VLC": "open -a VLC.app -u"
}


def read_pref(pref_key):
    try:
        pref_value = (subprocess.check_output(["defaults", "read", pref_file, pref_key],
                                              stderr=subprocess.STDOUT)).decode("utf-8").strip()
    except:
        # Standardwerte in Preferencedatei schreiben
        subprocess.run(['defaults', 'write', pref_file, 'player', '-string', 'QuickTime'])
        subprocess.run(['defaults', 'write', pref_file, 'submenus', '-bool', 'TRUE'])
        pref_value = (subprocess.check_output(["defaults", "read", pref_file, pref_key])).decode("utf-8").strip()
    return pref_value


def write_pref(pref_key, pref_type, pref_value):
    try:
        _ = (subprocess.check_output(["defaults", "read", pref_file, pref_key], stderr=subprocess.STDOUT)).decode("utf-8").strip()
    except:
        # Standardwerte in Preferencedatei schreiben
        subprocess.run(['defaults', 'write', pref_file, 'player', '-string', 'QuickTime'])
        subprocess.run(['defaults', 'write', pref_file, 'submenus', '-bool', 'TRUE'])
    subprocess.run(['defaults', 'write', pref_file, pref_key, pref_type, pref_value])
    return


def close_player(player):
    if player == "QuickTime":
        cmd = """osascript -e '
        tell application "QuickTime Player" to close every window
        '
        """
    else:
        cmd = """osascript -e '
        tell application "VLC" to close every window
        '
        """
    os.system(cmd)
    return


def get_channels():
    if not os.path.isfile(channels_all):
        # Sender von ZAPP
        if not os.path.isfile(channels_file):
            try:
                r = requests.get(channel_url)
                r.raise_for_status()
                ch_raw = r.text
                with open(channels_file, "w") as f:
                    f.write(unicodedata.normalize('NFD', ch_raw))
            except:
                # ohne shutil weil nur im Notfall ein paar KB kopiert werden
                open(channels_file, 'wb').write(open(channels_backup_file, 'rb').read())
        with open(channels_file, 'r') as file:
            channels = json.load(file)
        # Sender aus statischer Datei hinzufügen
        # z.B. Ersatz für die NDR Sender, die von ZAPP nicht im QTP funktionieren
        if not os.path.isfile(channels_fixer):
            with open(channels_fixer, "w") as f:
                f.write("[]")
        with open(channels_fixer, 'r') as file:
            channels += json.load(file)
        with open(channels_all, "w") as f:
            json.dump(channels, f)
        if os.path.isfile(menu_kmpl):
            os.remove(menu_kmpl)
    else:
        with open(channels_all, 'r') as file:
            channels = json.load(file)
    return channels


def channels_update():
    if not os.path.isfile(channels_all):
        get_channels()
    else:
        os.remove(channels_all)
    menu_ausgabe()


def stream_abspielen(der_sender):
    for sender in get_channels():
        if sender["name"] == der_sender and '@' not in sender['stream_url']:
            close_player(player)
            open_stream = f"{streamplayer} {sender['stream_url']}"
            os.system(open_stream)
            break
    exit()


def menu_ausgabe():
    try:
        with open(menu_kmpl, 'r') as file:
            menu_items = file.read()
    except:
        # anzeigbare Sender ermitteln
        menu_items = ""  # Inhalt der Sendermenüs
        sender_menu = []  # Sender die im Menü angezeigt werden
        sender_gruppen = []  # Lokalsender NDR Nds, NDR HH, NDR SH usw.
        for i in get_channels():
            if '@' not in i['stream_url']:  # Stream URLs mit @ kann QT Player nicht öffnen
                sendername = i['name']
                sender_menu.append(sendername)
                sender_gruppen.append(sendername.split()[0])
        sender_menu = sorted(sender_menu, key=str.casefold)
        sender_gruppen = sorted(sender_gruppen, key=str.casefold)
        # Sendergruppen anhand Mehrfachnennungen ermitteln
        gruppen_submenu = []  # Sendergruppen mit eigenem Submenü
        for gruppe in sender_gruppen:
            count = sender_gruppen.count(gruppe)
            if count >= gruppen_min and gruppe not in gruppen_submenu:
                gruppen_submenu.append(gruppe)
        # Senderlistenmenu
        sender_submenu = ""
        submenu_aktiv = False
        sender_menu.append("----")
        gruppe_aktuell = ""
        for sendername in sender_menu:
            gruppe = sendername.split()[0]
            if gruppe in gruppen_submenu:
                if gruppe != gruppe_aktuell:
                    if submenu_aktiv:
                        menu_items += f"{sender_submenu}\n"
                        submenu_aktiv = False
                    sender_submenu = f"SUBMENU|{gruppe}"
                    gruppe_aktuell = gruppe
                    submenu_aktiv = True
                sender_submenu = f"{sender_submenu}|{sendername}"
            else:
                if submenu_aktiv:
                    menu_items += f"{sender_submenu}\n"
                    submenu_aktiv = False
                    menu_items += f"{sendername}\n"
                else:
                    menu_items += f"{sendername}\n"
        # Einstellungsmenü
        if player == "QuickTime":
            playermenuitem = "VLC verwenden"
        else:
            playermenuitem = "QT Player verwenden"
        if submenu == "1":
            submenuitem = "Submenüs ausschalten"
        else:
            submenuitem = "Submenüs einschalten"
        menu_items += f"SUBMENU|Einstellungen|{submenuitem}|{playermenuitem}|----|Senderliste aktualisieren"
        with open(menu_kmpl, 'w') as file:
            file.writelines(menu_items)
    print(menu_items)
    return


player = read_pref('player')
streamplayer=(players[player])

submenu = read_pref('submenus')
if submenu == "1":
    gruppen_min = 2
else:
    gruppen_min = 10

def main():
    if len(sys.argv) < 2:
        menu_ausgabe()
    else:
        # Übergebene Parameter auswerten
        parameter = sys.argv[1]
        parameter = unicodedata.normalize('NFD', parameter)
        if parameter == "Senderliste aktualisieren":
            channels_update()
        elif parameter == "VLC verwenden":
            write_pref('player', '-string', 'VLC')
        elif parameter == "QT Player verwenden":
            write_pref('player', '-string', 'QuickTime')
        elif parameter == "Submenüs ausschalten":
            write_pref('submenus', '-bool', 'FALSE')
        elif parameter == "Submenüs einschalten":
            write_pref('submenus', '-bool', 'TRUE')
        else:
            stream_abspielen(parameter)
        if os.path.isfile(menu_kmpl):
            os.remove(menu_kmpl)
    exit()

if __name__ == '__main__':
    main()
