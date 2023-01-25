---

date: 2010-09-04 09:58:35+00:00
draft: false
title: Tagebuch führen für Nerds
type: post
aliases:
    -  /682-tagebuch-fuhren-fur-nerds/


tags:
- bash
- erinnerungen
- linux
- script
- shell
- tagebuch
---

Ich finde, es ist immer schön, wenn man sich zurück erinnern kann, was man vor ein paar Monaten, Jahren so gemacht hat. Das ruft Erinnerungen an schöne Momente zurück oder erinnert daran, dass man dieses oder jenes beim nächsten Mal anders machen wollte.

Für sowas eignet sich ein Tagebuch. Doch Tagebuch führen ist ja sowas von 1980. Man muss das Buch immer dabei haben, sitzt dann vor einer leeren Seite und verliert irgendwann die Lust zu schreiben.

Ich habe mir folgendermaßen Abhilfe geschaffen. Ich habe in einer einfachen Textdatei ein 80-Char-Diary gestartet, in welchem ich in 80 Zeichen meinen Tag zusammen fasste. Ein Eintrag für die Abendstunden war an jedem Tag auf meiner ToDo-Liste und so gewöhnte ich mich daran, dass jeden Tag zu schreiben.

Ich merkte in den letzten Wochen, dass mir 80 Zeichen nicht ausreichen und ich mehr schreiben will. Außerdem war es langweilig jedes Mal die Textdatei zu öffnen, zu schreiben, sie zu schließen.

Ich habe mir also ein kleines Bash-Script für dieses "Problem" geschrieben".

Wird das Script ohne Parameter aufgerufen, stellt es mir die Frage "Was ist heute passiert?", ich tippe meinen Text ein und er wird automatisch an die Datei angehängt. Eine Linie dient hierbei als Anhaltspunkt für die alte 80-Zeichen-Grenze.

Der Parameter "-s" gibt aus, seit wievielen Tagen ich das Tagebuch schon führe. Über "-p" kann ich mir das Tagebuch in der Shell ausgeben lassen und über "-e" wird es mit dem Editor nano bearbeitet.

Ich komme damit bisher super klar und bin für Verbesserungsvorschläge offen.

Ihr könnt [diary.sh als zip-File herunterladen](https://christianbaer.me/files/diary.sh.zip) oder Euch das Listing unten kopieren. In jedem Fall muss aber die Variable FILENAME noch an Speicherchort Eurer Datei angepasst werden.


    #!/bin/sh
    # /home/chris/bin/diary.sh

    FILENAME="/media/daten/Ablage/diary"
    COUNTDAYS=`cat $FILENAME | wc -l`

    while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
        case "$1" in
            -e|--edit)
                nano $FILENAME
                exit 0
            ;;
            -p|--print)
                cat $FILENAME
                exit 0
            ;;
            -s|--status)
                echo "Du führst das Tagebuch seit "$COUNTDAYS" Tagen."
                exit 0
            ;;
            *)

            ;;
        esac
        shift       # Check next set of parameters.
    done

        echo "Du führst das Tagebuch seit "$COUNTDAYS" Tagen."
        echo
        echo "Was ist heute passiert?"
        echo "--------------------------------------------------------------------------------"
        read DIARYTEXT
        echo `date +%y%m%d%a`" |"$DIARYTEXT >> $FILENAME
