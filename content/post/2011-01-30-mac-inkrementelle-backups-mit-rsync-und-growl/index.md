---

date: 2011-01-30 20:59:57+00:00
draft: false
title: 'Mac: Inkrementelle Backups mit rsync und growl'
type: post
aliases:
    -  /683-mac-inkrementelle-backups-mit-rsync-und-growl/


tags:
- backup
- growl
- mac
- rsync
- time machine
---

{{< imgproc "screenshot-rsync-growl.png" Resize "700x" >}} Screenshot von meinem Desktop mit growl {{< / imgproc >}}

Ich bin seit ca. einem halben Jahr Mac-User und wirklich zufrieden mit OS X. Das Einzige, was mich stört, ist Time Machine.

Ich habe meinen Home-Folder verschlüsselt in einem FileVault und meine restlichen Daten auf einer separaten, mit Truecrypt verschlüsselten, Partition liegen. Time Machine ist relativ beschränkt, wenn es darum geht, die Backups anzupassen. Um mein Verschlüsseltes Home-Verzeichnis zu sichern, muss ich mich ausloggen, MacOS komprimiert den FileVault und schmeißt ihn dann auf das Backup-Medium. Die Sicherung des Truecrypt-Volumes ist gar nicht möglich.

Da dies für eine Backup-Strategie, welche automatisch im Hintergrund läuft, denkbar unpraktisch ist, musste eine andere Lösung her.

Ich habe also ein Bisschen gegoogelt und mir aus verschiedenen Backup-Scripts Anregungen geholt. Heraus kam ein Backup-Script, welches die Backups ähnlich anlegt, wie Time Machine.

Ich konfiguriere die Quell-Ordner, gebe das Ziel-Medium an und der Rest geschieht im Hintergrund. Da rsync in meiner Configuration nur neue und geänderte Dateien übertragen muss und nicht veränderte Dateien einfach verlinkt werden, geht das Backup relativ schnell und verbraucht sehr wenig Platz. Bei jedem Durchlauf wird ein neuer Ordner angelegt, welcher immer ein Vollbackup enthält. Wenn sich keine Dateien verändert haben, wird aber kein zusätzlicher Platz verbraucht.

Am Ende jedes Durchlaufs werde ich per growl benachrichtigt, dass das Backup gemacht wurde und ob es Fehler gab.

Alles in allem funktioniert jetzt alles so, wie ich es will. Das Script läuft stündlich per cron im Hintergrund und ich brauche mich um nichts zu kümmern. Trotzdem habe ich Gewissheit, dass alle meine Daten gesichert sind, falls etwas passiert.

Folgenden Code einfach in eine Textdatei packen, mit root-Rechten ausführen und glücklich sein :)

P.S.: Der Code funktioniert auf jedem System, af dem rsync läuft (Linux, Unix, Windows mit Cygwin). Hier muss dann aber unter Umständen auf die Benachrichtigungen verzichtet werden, wenn Ihr das Script nicht an des Benachrichtigungssystem Eures Betriebssystem anpassen wollt (z.B. notify-bin in Ubuntu).

    #!/bin/bash

    # --- Set backup parameters ---

    # What local files/folders are we backing up (without trailin "/")?

    SOURCES='/bin /private/etc /sbin /etc /usr /opt /Volumes/Macintosh/Library /Volumes/Macintosh/System /Volumes/Macintosh/Users/chris /Volumes/Macintosh/Applications /Volumes/Daten'

    # What location shall we back up to (without trailin "/")?
    DEST='/Volumes/Elements'

    # Any non-valuable stuff to exclude by name/location (seperated by ",")?
    EXCLUDE='.DS_Store,/.chris/,.Trash/,tmp/,LastPass/pipes/,log/,.log'


    # --- Get some data and make some declarations ---

    # What's the local hostname?
    HOST=`hostname -fs`

    # Get the date
    DATE=`date "+%Y-%m-%d-%H%M%S"`

    # Set the folder for backups for this host
    BACKUPPATH="$DEST/Backup/$HOST"

    # Where shall we write the error log?
    ERRORS="$BACKUPPATH/errors-$DATE.log"

    # --- Set Growl parameters ---

    # What will this script be called in the Growl prefpane?
    GROWLNAME="Backup of $HOST"

    # And what app's icon will appear in Growl notifications?
    APPICON="/Users/chris/bin/Time-Machine.icns"

    # --- Do it! ---

    # Check if $DEST is mounted. Otherwise quit script
    DESTMOUNTED=`mount | grep "$DEST"`

    if [ -z "$DESTMOUNTED" ]; then
      /bin/growlnotify --name "$GROWLNAME" --image "$APPICON"
        --message "$DEST is not mounted." "Ignoring scheduled backup"
      exit 1
    fi



    PROCS=`ps -A -o "pid=,command="`
    MYNAME="$0"
    MYBASENAME=`basename $MYNAME`
    MYPID=$$

    # The next line works like so:
    # * take the process list (for all users),
    # * filter *in* processes named like this script (making sure we're on word boundaries),
    # * filter *out* (-v) the one that *is* this script (by PID), and finally
    # * filter *out* the grep commands themselves.

    MERUNNING=`echo "$PROCS" | grep -E -e "b$MYBASENAMEb"
      | grep -E -v "b$MYPIDb" | grep -v grep`

    # Then, if anything's left (i.e. MERUNNING isn't a zero-length string...)

    if [ ! -z "$MERUNNING" ]; then
      /bin/growlnotify --name "$GROWLNAME" --image "$APPICON"
        --message "Another backup seems to be in progress" "Ignoring scheduled backup"
      exit 1
    fi

    EXPEXCLUDES=`eval "echo --exclude={$EXCLUDE} "`

    STARTTIME=`date "+%Y-%m-%d %H:%M:%S"`

    /bin/growlnotify --name "$GROWLNAME" --image "$APPICON" --message "Backup of $HOST has been startet at $STARTTIME"
    echo "Backup of $HOST has been startet at $STARTTIME" >> $ERRORS

    for D in $SOURCES; do
        mkdir -p $BACKUPPATH/$DATE.inProgress$D
        rsync -aH $EXPEXCLUDES --link-dest=$BACKUPPATH/current$D $D/ $BACKUPPATH/$DATE.inProgress$D 2>>"$ERRORS"
    done

    FINISHTIME=`date "+%Y-%m-%d %H:%M:%S"`

    NUMERRORS=`awk '{x++}END{ print x}' $ERRORS`
    NUMERRORS=$[$NUMERRORS-1]

    /bin/growlnotify --name "$GROWLNAME" --image "$APPICON" -s
      --message "Completed backup of $HOST at $FINISHTIME. There were $NUMERRORS errors." "$HOST has been backed up to $DEST."
    echo "Completed backup of $HOST at $FINISHTIME. There were $NUMERRORS errors." >> $ERRORS

    mv $BACKUPPATH/$DATE.inProgress $BACKUPPATH/$DATE

    rm -f "$BACKUPPATH/current" && ln -nsf "$BACKUPPATH/$DATE/" "$BACKUPPATH/current"
