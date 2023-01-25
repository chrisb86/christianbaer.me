---

date: 2018-03-23 20:32:12+00:00
draft: false
title: Telekom VDSL und Entertain mit DrayTek Vigor130 und Ubiquiti Edgerouter X
type: post
aliases:
    -  /891-telekom-vdsl-und-entertain-mit-draytek-vigor130-und-ubiquiti-edgerouter-x/

tags:
- draytek
- entertain
- netzwerk
- router
- ubiquiti
- ubnt
- vlan
---

In letzter Zeit ging mir die Fritz!Box immer mehr auf die Nerven.

Nachdem mir Anfang des Jahres nach vielen Jahren meine 7390 verstorben ist, habe ich mir eine 7490 gekauft. Schmerzlich musste ich feststellen, dass AVM immer mehr funktionen streicht, die ich in meinem Setup aber dringend benötige.

Ich betreibe z.B. Jails auf einem FreeBSD-Server. Gegenüber dem Router haben alle Jails unterschiedliche IP-Adressen, aber die selbe MAC, da sie ja die selbe Netzwerkkarte benutzen. In aktuellen Fritz!OS-Versionen ist es nicht mehr möglich, für die Jails konsistente Portweiterleitungen einzurichten, da diese immer an die MAC-Adresse gekoppelt sind und die IP in der Firewall ständig geändert wird.

Ich habe mir dann kurzfristig noch eine EdgeRouter X (ERX) von Ubiquiti dazu geordert. Die Fritz!Box hat dann die Internetverbindung aufgebaut und sämtlichen Traffic einfach an den ERX durchgereicht. Inklusive doppeltem NAT und allen anderen Nachteilen, die diese Lösung mit sich bringt. Ich habe also den Entschluss gefasst, die Fritz!Box abzuschaffen und das ganze Netzwerksetup ein mal vernüftig aufzubauen.

Nach einiger Recherche setze ich jetzt folgende Hardware ein:
• Mein VDSL-Modem ist ein DrayTek Vigor130
• Das Routing und den Aufbau der PPoE-Verbindung übernimmt der Ubiquiti EdgeRouter X.
• Als WLAN-Accesspoint kommt ein Ubiquiti UniFi AP AC Lite zum Einsatz
• Des Weiteren tun noch zwei Netgear GS108Ev3-Switches ihren Dienst.

Das Zielsetup zum Ersetzen der Fritz!Box war dann also folgendes.

Der Vigor130 soll als reines Modem zum Einsatz kommen. Der EdgeRouter soll die Internetverbindung vie Telekom VDSL aufbauen. Er soll sich um die VLANs kümmern, um Entertain nutzen zu können, DHCP anbieten, das IPv6-Subnet, das von der Telekom zugeteilt wird über Prefix-Delegation an die Clients im LAN verteilen, sowie einen L2TP-VPN-Server anbieten. Der Router soll DNS-Forwarding machen und hierfür die Nameserver nutzen, die die Telekom ihm zuweist.

Nach einegm Rumprobieren habe ich jetzt alles ans Laufen bekommen. Das Modem hängt an eth0 des ERX. Das Modem hat die IP 192.168.1.1.. eth0 des ERX hat die 192.168.1.2.. Das Interne Netz läuft als 192.168.178.0/24 und die restlichen Ethernet-Ports des ERX laufen im Switch-Modus alle auf dem selben Netz.

Das ich im Netz immer nur Teil-Lösungen gefunden habe, oder welche, die eher exotische Setups bedienen, dachte ich, ich teile meine Config mal mit Euch.
Sie sollte fast Copy-Paste-fähig sein. Die einzigen Dinge, die Du ändern musst, sind deine VDSL-Zugangsdaten und den Preshared Key des VPN.

Über SSH kannst Du dann noch VPN-User hinzufügen.



    configure

    set vpn l2tp remote-access authentication local-users username <USERNAME> password <PASSWORD>

    commit; save



Portweiterleitungen usw. lassen sich anschließend sehr gut über das Webinterface unter 192.168.178.1 einrichten.

Hier nun also die Config:

### config.boot

    firewall {
        all-ping enable
        broadcast-ping disable
        ipv6-name IPv6_WAN_IN {
            default-action drop
            description "IPv6 packets from the Internet to LAN"
            enable-default-log
            rule 1 {
                action accept
                description "Allow established sessions"
                state {
                    established enable
                    related enable
                }
            }
            rule 2 {
                action drop
                state {
                    invalid enable
                }
            }
            rule 5 {
                action accept
                description "Allow ICMPv6"
                log disable
                protocol icmpv6
            }
        }
        ipv6-name IPv6_WAN_LOCAL {
            default-action drop
            description "IPv6 packets from the Internet to the router"
            enable-default-log
            rule 1 {
                action accept
                description "Allow established sessions"
                log disable
                state {
                    established enable
                    related enable
                }
            }
            rule 2 {
                action drop
                log disable
                state {
                    invalid enable
                }
            }
            rule 5 {
                action accept
                description "Allow ICMPv6"
                log disable
                protocol icmpv6
            }
            rule 110 {
                action accept
                description "Allow DHCPv6 packets"
                destination {
                    port 546
                }
                protocol udp
                source {
                    port 547
                }
            }
        }
        ipv6-name WANv6_IN {
            default-action drop
            description "WAN inbound traffic forwarded to LAN"
            enable-default-log
            rule 10 {
                action accept
                description "Allow established/related sessions"
                state {
                    established enable
                    related enable
                }
            }
            rule 20 {
                action drop
                description "Drop invalid state"
                state {
                    invalid enable
                }
            }
        }
        ipv6-name WANv6_LOCAL {
            default-action drop
            description "WAN inbound traffic to the router"
            enable-default-log
            rule 10 {
                action accept
                description "Allow established/related sessions"
                state {
                    established enable
                    related enable
                }
            }
            rule 20 {
                action drop
                description "Drop invalid state"
                state {
                    invalid enable
                }
            }
            rule 30 {
                action accept
                description "Allow IPv6 icmp"
                protocol ipv6-icmp
            }
            rule 40 {
                action accept
                description "allow dhcpv6"
                destination {
                    port 546
                }
                protocol udp
                source {
                    port 547
                }
            }
        }
        ipv6-receive-redirects disable
        ipv6-src-route disable
        ip-src-route disable
        log-martians enable
        name WAN_IN {
            default-action drop
            description "WAN to internal"
            enable-default-log
            rule 1 {
                action accept
                description "Allow established/related"
                state {
                    established enable
                    related enable
                }
            }
            rule 3 {
                action drop
                description "Drop invalid state"
                state {
                    invalid enable
                }
            }
        }
        name WAN_IPTV {
            default-action drop
            description "Telekom Entertain"
            enable-default-log
            rule 1 {
                action accept
                description "Allow IPTV Multicast UDP"
                destination {
                    address 224.0.0.0/4
                }
                log disable
                protocol udp
                source {
                }
            }
            rule 2 {
                action accept
                description "Allow IGMP"
                log disable
                protocol igmp
            }
        }
        name WAN_LOCAL {
            default-action drop
            description "WAN to router"
            enable-default-log
            rule 1 {
                action accept
                description "Allow Ping"
                log disable
                protocol icmp
            }
            rule 2 {
                action accept
                description "Allow Multicast"
                destination {
                    address 224.0.0.0/4
                }
                log disable
                protocol all
            }
            rule 7 {
                action accept
                description "Allow established/related"
                state {
                    established enable
                    related enable
                }
            }
            rule 8 {
                action drop
                description "Drop invalid state"
                log enable
                state {
                    invalid enable
                }
            }
            rule 30 {
                action accept
                description IKE
                destination {
                    port 500
                }
                log disable
                protocol udp
            }
            rule 40 {
                action accept
                description ESP
                log disable
                protocol esp
            }
            rule 50 {
                action accept
                description NAT-T
                destination {
                    port 4500
                }
                log disable
                protocol udp
            }
            rule 60 {
                action accept
                description L2TP
                destination {
                    port 1701
                }
                ipsec {
                    match-ipsec
                }
                log disable
                protocol udp
            }
        }
        options {
            mss-clamp {
                mss 1412
            }
        }
        receive-redirects disable
        send-redirects enable
        source-validation disable
        syn-cookies enable
    }
    interfaces {
        ethernet eth0 {
            address 192.168.1.2/24
            duplex auto
            speed auto
            vif 7 {
                description "Internet (PPPoE)"
                pppoe 0 {
                    default-route auto
                    dhcpv6-pd {
                        pd 0 {
                            interface eth1 {
                                no-dns
                                prefix-id 42
                                service slaac
                            }
                            interface switch0 {
                                host-address ::dead:beef
                                prefix-id :1
                                service slaac
                            }
                            prefix-length 56
                        }
                        prefix-only
                        rapid-commit enable
                    }
                    firewall {
                        in {
                            ipv6-name IPv6_WAN_IN
                            name WAN_IN
                        }
                        local {
                            ipv6-name IPv6_WAN_LOCAL
                            name WAN_LOCAL
                        }
                    }
                    ipv6 {
                        address {
                            autoconf
                        }
                        dup-addr-detect-transmits 1
                        enable {
                        }
                    }
                    mtu 1492
                    name-server auto

                    ## Hier PPPoE-Zugangsdaten ändern
                    password KENNWORT
                    user-id ANSCHLUSSKENNUNGZUGANGSNUMMER0001@t-online.de
                }
            }
            vif 8 {
                address dhcp
                description "Telekom Entertain"
                firewall {
                    local {
                        name WAN_IPTV
                    }
                }
                mtu 1500
            }
        }
        ethernet eth1 {
            description Local
            duplex auto
            ipv6 {
                dup-addr-detect-transmits 1
            }
            speed auto
        }
        ethernet eth2 {
            description Local
            duplex auto
            speed auto
        }
        ethernet eth3 {
            description Local
            duplex auto
            speed auto
        }
        ethernet eth4 {
            description Local
            duplex auto
            speed auto
        }
        loopback lo {
        }
        switch switch0 {
            address 192.168.178.1/24
            description Local
            mtu 1500
            switch-port {
                interface eth1 {
                }
                interface eth2 {
                }
                interface eth3 {
                }
                interface eth4 {
                }
                vlan-aware disable
            }
        }
    }
    port-forward {
        auto-firewall enable
        hairpin-nat enable
        lan-interface switch0
        wan-interface pppoe0
    }
    protocols {
        igmp-proxy {
            interface eth0.8 {
                alt-subnet 0.0.0.0/0
                role upstream
                threshold 1
            }
            interface eth1 {
                alt-subnet 0.0.0.0/0
                role downstream
                threshold 1
                whitelist 239.35.0.0/16
            }
        }
    }
    service {
        dhcp-server {
            disabled false
            hostfile-update disable
            shared-network-name LAN {
                authoritative disable
                subnet 192.168.178.0/24 {
                    default-router 192.168.178.1
                    dns-server 192.168.178.1
                    lease 86400
                    start 192.168.178.100 {
                        stop 192.168.178.200
                    }
                }
            }
            static-arp disable
            use-dnsmasq disable
        }
        dns {
            forwarding {
                cache-size 1000
                listen-on switch0
                options listen-address=192.168.178.1
            }
        }
        gui {
            http-port 80
            https-port 443
            older-ciphers enable
        }
        nat {
            rule 5001 {
                description "Masquerade outgoing pppoe0"
                log disable
                outbound-interface pppoe0
                protocol all
                type masquerade
            }
            rule 5011 {
                description "Webinterface Modem"
                destination {
                    address 192.168.1.0/24
                }
                log disable
                outbound-interface eth0
                protocol all
                type masquerade
            }
        }
        ssh {
            port 22
            protocol-version v2
        }
        unms {
            disable
        }
    }
    system {
        login {
            user ubnt {
                authentication {
                    encrypted-password $6$KAQUivwa0C$tawQZnN4aM4CxmQo0RgfUQjij.YJ239CN.1B6yaPfin1jCZvsZ4kSVSlqEXurai5AQSX.XAMfC3rIVuKnmEpM1
                    plaintext-password ""
                }
                level admin
            }
        }
        ntp {
            server 0.ubnt.pool.ntp.org {
            }
            server 1.ubnt.pool.ntp.org {
            }
            server 2.ubnt.pool.ntp.org {
            }
            server 3.ubnt.pool.ntp.org {
            }
        }
        offload {
            hwnat enable
        }
        static-host-mapping {
        }
        syslog {
            global {
                facility all {
                    level notice
                }
                facility protocols {
                    level debug
                }
            }
        }
        time-zone Europe/Berlin
        traffic-analysis {
            dpi disable
            export enable
        }
    }
    vpn {
        ipsec {
            auto-firewall-nat-exclude disable
            ipsec-interfaces {
                interface pppoe0
            }
        }
        l2tp {
            remote-access {
                authentication {
                    mode local
                }
                client-ip-pool {
                    start 192.168.178.85
                    stop 192.168.178.99
                }
                dns-servers {
                    server-1 192.168.178.1
                }
                idle 1800
                ipsec-settings {
                    authentication {
                        mode pre-shared-secret

                        ## Hier Preshared Secret festlegen
                        pre-shared-secret PRESHAREDSECRET
                    }
                    ike-lifetime 3600
                    lifetime 3600
                }
                mtu 1492
                outside-address 0.0.0.0
            }
        }
    }


    /* Warning: Do not remove the following line. */
    /* === vyatta-config-version: "config-management@1:conntrack@1:cron@1:dhcp-relay@1:dhcp-server@4:firewall@5:ipsec@5:nat@3:qos@1:quagga@2:system@4:ubnt-pptp@1:ubnt-udapi-server@1:ubnt-unms@1:ubnt-util@1:vrrp@1:webgui@1:webproxy@1:zone-policy@1" === */
    /* Release version: v1.10.0.5056246.180125.0954 */
