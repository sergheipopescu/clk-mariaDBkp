#!/bin/bash
# shellcheck disable=SC2174

##
# Global variables
##

BkpDir=/bkp/mariaDB # backup path

BkpLogDir=/var/log/mariaDBkp # backup log path

InstDir=/etc/clickwork/mariaDBkp # set installation path

NoBkpDBs=("performance_schema" "information_schema" "phpmyadmin" "sys") # list of excluded databases


##
# Install script if it's not present
##

if ! [ -f "$InstDir"/mdbkp ]; then # if script doesn't exist

	##
	# Install variables
	##

	ScriptDir=$(dirname "$0")	# get current directory


	##
	# Check for .my.cnf
	##

	echo
	echo -n "Checking for .my.cnf autologin file .............. "

	if ! [ -f /root/.my.cnf ]; then

		echo -e "[\033[33m NOT FOUND \033[0m]\n"

		if [ -f /root/salt ]; then

			mDBPass=$(sudo grep -oP "mariaDB password is:\s+\K\w+" /root/salt) # get MariaDB root password

			echo -n "Creating .my.cnf autologin file .................. "
			echo -e "[client]\nuser=mariadmin\npassword=$mDBPass" > /root/.my.cnf || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

		else

			read -r -p "	Enter mariaDB login username: " mDBUsr	# ask for username
			read -r -p "	Enter mariaDB login password: " mDBPass	# ask for password

			echo
			echo -n "Creating .my.cnf autologin file .................. "
			echo -e "[client]\nuser=$mDBUsr\npassword=$mDBPass" > /root/.my.cnf || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

		fi
		

	else

		echo -e "[\033[32m OK \033[0m]\n"

	fi


	##
	# Installation
	##

	echo -n "Installing script ................................ "
	install -D -m500 "$0" "$InstDir"/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; }; echo -e "[\033[32m OK \033[0m]\n"

	echo -n "Create backup directory .......................... "
	mkdir -p -m 600 "$BkpDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

	echo -n "Create backup log directory ...................... "
	mkdir -p "$BkpLogDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

	echo -n "Create backup schedule ........................... "
	ln -sf "$InstDir"/mdbkp /etc/cron.daily/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

	echo -n "Create rotate backup schedule .................... "
	echo -e "find $BkpDir -mindepth 1 -mtime +30 -delete" > /etc/cron.daily/rotate-backups || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"
	chmod +x /etc/cron.daily/rotate-backups
	
	echo -n "Cleanup .......................................... "
	rm -rf "$ScriptDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; exit 1; } ; echo -e "[\033[32m OK \033[0m]\n"

else

	##
	# Backup variables
	##

	BkpTime=$(date +%Y.%m.%d_%H:%M) # date and time for backup file name

	mapfile -t AllDBs < <(echo "SHOW DATABASES;" | mariadb -N) # Get a list of databases; Old Syntax was SC2034 incompatible: AllDBs=($(echo "SHOW DATABASES;" | mariadb -N))

	mapfile -t BkpDBs < <(echo "${AllDBs[@]}" "${NoBkpDBs[@]}" | tr ' ' '\n' | sort | uniq -u) # extract the list of DBs to backup


	##
	# Loop through the DBs
	##

	for EachDB in "${BkpDBs[@]}"; do

		BkpFile="$BkpDir"/"$EachDB""_""$BkpTime"".sql.gz" # generate backup filename

		BkpErrLog="$BkpLogDir"/"$EachDB""_""$BkpTime"".error.log" # generate backup error log filename

		mariadb-dump --opt --routines --triggers --single-transaction "$EachDB" 2>"$BkpErrLog" | gzip >"$BkpFile" # dump and compress the database, logging errors into the error log

		[ -s "$BkpErrLog" ] || rm -f "$BkpErrLog" # delete error log if empty

	done

fi

# Alternatively, insert an if into the foor loop
#
# for EachDB in "${AllDBs[@]}"; do
#	if [[ ! " ${NoBkpDBs[*]} " =~ "${EachDB}" ]]; then
#		echo "$EachDB"
#	fi
# done