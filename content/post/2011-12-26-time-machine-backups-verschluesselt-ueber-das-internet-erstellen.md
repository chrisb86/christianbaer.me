---

date: 2011-12-26 23:43:21+00:00
draft: false
title: Time Machine Backups verschlüsselt über das Internet erstellen
type: post
aliases:
    -  /433-time-machine-backups-verschluesselt-ueber-das-internet-erstellen/


tags:
- afp
- apple
- backups
- dns-sd
- ssh
- time machine
- tunnel
---

An Tagen wie diesen (z.B. Weihnachten) stellt sich immer wieder ein Problem. Das NAS steht zu Hause, man selbst ist zum Beispiel bei seinen Eltern und das über Tage hinweg. Der paranoide Nerd hat dann immer wieder das gleiche Problem: Was ist mit den Backups. Was soll ich nur machen, wenn die Festplatte des MacBooks nach zwei Tagen abraucht?

Genau diesem (meinem) Problem habe ich mich über Weihnachten mal angenommen. Zu Hause steht meine Synology Disk Station. Sie ist im Netzwerk u.A. per AFP (Apple Filing Protocol) als Time Machine-Volume ansprechbar. SSH läuft, die Authentifizierung läuft schon seit Längerem über Keys und der SSH-Port ist über den Router freigegeben, welcher wiederum per DDNS erreichbar ist.

Ich habe also ein Script gebastelt, welches all diese Faktoren kombiniert und es mir ermöglicht, auf meine Disk Station per AFP zuzugreifen und Backups zu machen.

Das Script stellt eine Verbindung zum SSH-Server im NAS her, und Tunnelt den dortigen AFP-Port per SSH auf einen Port meines Rechners. Über diesen Port kann ich dann über eine verschlüsselte Verbindung auf mein NAS zugreifen. Der Tunnel bzw. der durch den Tunnel angebotene Service wird dem Betriebssystem per dns-sd bekannt gemacht, was dazu führt, dass es ihn "entdeckt" und im Finder aufführt, als wäre ich im heimischen Netzwerk.

Wird das Script noch mal aufgerufen, prüft es, ob schon ein Tunnel besteht. Wenn dies nicht der Fall ist, versucht es einen zu erstellen. Dadurch bietet es sich an, das Script per cron regelmäßig ausführen zu lassen um den Tunnel dauerhaft aufrecht zu erhalten.

Alles in allem ist das bisher eine sehr coole Sache :) Gigabyteweise Time Machine Backups mit 128kb Upstream machen jedoch keinen Spaß.

Ich habe das Projekt wie immer [auf github gehostet](https://github.com/chrisb86/ssh-ds) und Pflege es auch dort. Über Anregungen und Commits würde ich mich freuen.

Anbei zusätzlich auch noch mal das aktuelle Listing des Codes.

    #!/bin/sh

    ## CONFIG

    REMOTEUSER="user" # The ssh user name on remote server
    REMOTEHOST="remote.host.name" # The ssh user password on remote server
    LABEL="DiskStation" # The label for the service, that's registered with dns-sd

    ## NO NEED TO EDIT BELOW THIS LINE

    VERSION="2011-12-27"

    VERBOSE=false

    REMOTELOGIN="$REMOTEUSER@$REMOTEHOST"

    createTunnel() {
        # Create tunnel to port 548 on remote host and make it avaliable at port 12345 at localhost
        # Also tunnel ssh for connection testing purposes
        ssh -gNf
        -L 12345:127.0.0.1:548
        -L 19922:127.0.0.1:22
        -C $REMOTELOGIN &

        if [[ $? -eq 0 ]]; then
            # Register AFP as service via dns-sd
            dns-sd -R $LABEL _afpovertcp._tcp . 12345 > /dev/null &

            if [ $VERBOSE = "true" ]; then echo Tunnel to $REMOTEHOST created successfully; fi
            exit 0
        else
            if [ $VERBOSE = "true" ]; then echo An error occurred creating a tunnel to $REMOTEHOST RC was $?; fi
            exit 1
        fi
    }

    killTunnel() {
        MYPID=`ps aux | egrep -w "$REMOTEHOST|dns-sd -R $LABEL" | grep -v egrep | awk '{print $2}'`
        for i in $MYPID; do kill $i; done
        echo All processes killed
    }

    help() {
        echo "ssh-ds  version $VERSION

    ssh-ds is a small shell script that tunnels the AFP port of your disk station
    (and propably every other NAS with AFP and SSH services running) over ssh to your client computer.

    Put your settings in the config section in the script itself!

    Options
     -v, --verbose               increase verbosity
     -k, --kill                  kill all ssh-ds processes
     -h, --help                  show this screen
    "
    exit 0
    }

    # Yippieeh, commandline parameters

    while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
        case "$1" in
            -k|--kill)
                killTunnel
                exit 0
            ;;
            -v|--verbose)
                VERBOSE=true
            ;;
            -h|--help)
                help
            ;;
            *)

            ;;
        esac
        shift       # Check next set of parameters.
    done

    ## Run the 'ls' command remotely.  If it returns non-zero, create a new connection
    ssh -q -p 19922 $REMOTEUSER@localhost ls > /dev/null
    if [[ $? -ne 0 ]]; then
        createTunnel
    else
        if [ $VERBOSE = "true" ]; then echo Tunnel to $REMOTEHOST is active; fi
    fi
