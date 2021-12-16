#!/bin/bash

main() {
	echo "======================================== Configuration du firewall ========================================"
	echo "lancement du script..."
	iptables -F
	iptables -X
	echo "[+] Tables réinitialisées"
	echo "Voulez-vous restaurer une sauvegarde du firewall ?"
	read -r RepSave
	if [ $RepSave = "oui" ]
	then
		iptables-restore < firewall.txt
		echo "[+] Firewall restauré"
		echo "Fin du script..."
	elif [ $RepSave = "non" ]
	then
		iptables -t filter -A INPUT -j DROP
		iptables -t filter -A FORWARD -j DROP
		iptables -t filter -A OUTPUT -j DROP
		iptables -t filter -I INPUT -s "ip admin" -p tcp --dport 80 -j ACCEPT
		iptables -t filter -I INPUT -s "ip admin" -p tcp --dport 8080 -j ACCEPT
		iptables -t filter -I INPUT -s "ip admin" -p tcp --dport 443 -j ACCEPT
		iptables -t filter -I INPUT -s "ip admin" -p tcp --dport 21 -j ACCEPT
		iptables -t filter -I INPUT -s "ip admin" -p tcp --dport 22 -j ACCEPT
		echo "[+] Accès aux services accordés à l'administrateur"
	
		echo "Voulez vous autoriser les accès aux services FTP et HTTP au reseau local ?"
	
		read -r RepServLocal
		if [ $RepServLocal = "oui" ]
		then
			echo "[+] Accès aux services autorisés au réseau local"
			iptables -t filter -I INPUT  -s "ip réseau local" -p tcp -m tcp --dport 21 -m conntrack --ctstate ESTABLISHED,NEW -j ACCEPT
			iptables -t filter -I OUTPUT -s "ip réseau local" -p tcp -m tcp --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
			iptables -t filter -I INPUT -s "ip réseau local" -p tcp -i eth0 --dport 80 -j ACCEPT
			iptables -t filter -I INPUT -s "ip réseau local" -p tcp -i eth0 --dport 8080 -j ACCEPT
			iptables -t filter -I INPUT -s "ip réseau local" -p tcp -i eth0 --dport 443 -j ACCEPT

		elif [ $RepServLocal = "non" ]
		then
			echo "[-] Accès aux services refusé au réseau local"
		else
			echo "[!] Il faut écrire oui ou non"
		fi
	
		echo "Voulez vous autoriser les accès aux services FTP et HTTP depuis internet ?"
	
		read -r RepServInternet
		if [ $RepServInternet = "oui" ]
		then
		
			echo "[+] Accès aux services depuis internet autorisé"
			iptables -t filter -I INPUT -p tcp -i eth1 --dport 21 -m conntrack --ctstate ESTABLISHED,NEW -j ACCEPT
			iptables -t filter -I OUTPUT -p tcp -o eth1 --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
			iptables -t filter -I INPUT -p tcp -i eth1 --dport 80 -j ACCEPT
			iptables -t filter -I INPUT -p tcp -i eth1 --dport 8080 -j ACCEPT
			iptables -t filter -I INPUT -p tcp -i eth1 --dport 443 -j ACCEPT

		elif [	$RepServInternet = "non" ]
		then
			echo "[-] Accès aux services depuis internet refusé"
		else
			echo "[!] Il faut écrire oui ou non"
		fi

		echo "Voulez vous autoriser l'accès à internet depuis le serveur ?"

		read -r RepIntAccess
		if [ $RepIntAccess = "oui" ]
		then
			echo "[+] Accès à internet depuis le serveur autorisé"
			iptables -t filter -A INPUT -p tcp -i eth1 --dport 0:1024 -j ACCEPT
			iptables -t filter -A OUTPUT -p tcp -o eth1 --dport 0:1024 -j ACCEPT
		elif [ $RepIntAccess = "non" ]
		then
			echo "[-] Accès à internet depuis le serveur refusé"
		else
			echo "[!] Il faut écrire oui ou non"
		fi

		echo "Voulez vous autoriser l'accès au Web au réseau local ?"

		read -r RepWebLocal
		if [ $RepWebLocal = "oui" ]
		then
			echo "[+] Accès au Web autorisé pour le réseau local"
			iptables -t filter -I FORWARD -s "ip réseau local" -p tcp -i eth0 --dport 80 -j ACCEPT
			iptables -t filter -I FORWARD -s "ip réseau local" -p tcp -i eth0 --dport 8080 -j ACCEPT
			iptables -t filter -I FORWARD -s "ip réseau local" -p tcp -i eth0 --dport 443 -j ACCEPT

		elif [ $RepWebLocal = "non" ]
		then
			echo "[-] Accès au Web refusé pour le réseau local"
		else
			echo "[!] Il faut écrire oui ou non"
		fi
		echo "[+] Sauvegarde des configurations"
		iptables-save > firewall.txt
		echo "======================================== Résumé des configurations =========================================="
		iptables -L
		echo "fin du script..."
	
	else
		echo "[!] Il faut écrire oui ou non"
	fi
}

main
