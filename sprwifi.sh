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
	exit 0
}

# Function for the help panel
function helpPanel() {
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Use: :/sprwifi.sh${endColour}"
	echo -e "\n${grayColour}sprwifi - Next generation wifi cracker version 1.0${endColour}"
	echo -e "${grayColour}Developed by sporestudio${endColour}"
	echo -e "\n\n${purplecolor}${endColour}${grayColour}ATTACK MODE:${endColour}"
	echo -e "\n\t${grayColour}Handshake${endColour}"
	echo -e "\t${grayColour}PKMID${endColour}"
	echo -e "\n\n${grayColour}NETWORK CARD NAME:${endColour}"
	exit 0
}

# Verify if dependencies are installed
function dependencies() {
	tput civis # we can hide the cursor with this option
	clear
	dependencies=(aircrack-ng macchanger)

	echo -e "${yellowColour}[*]${endColour}${grayColour}Checking necessary dependencies...${endColour}"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColor} Tool${endColour}${grayColour} $program${endColour}${blueColor}...${endColour}"

		# checking the status code of the program with test
		test -f /usr/bin/$program

		if [ "$(echo $?)" == "0" ]; then
			echo -e "${greenColour}(V)${endColour}"
		else
			echo -e "${redColour}(X)${endColour}"
		fi
		sleep 1

	done
}

# Function to proceed with the attackmode
function startAttack() {
	echo "starting the attack"
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
	fi

else
	echo -e "\n${redColour}[*]Im not root{endColour}\n"
fi
