#!/bin/bash

##
# Global variables
##

BkpDir=/bkp/mariaDB # backup path with trailing slash

BkpLogDir=/var/log/mariaDBkp


##
# Install script if it's not present
##

if ! test -f "$InstDir"/mdbkp; then # if script doesn't exist

	##
	# Install variables
	##

	InstDir=/etc/clickwork/mariaDBkp # set installation directory for the script

	ScriptDir=$(pwd)	# get script directory

	mDBPass=$(sudo grep -oP "mariaDB password is:\s+\K\w+" /root/salt) # get MariaDB root password


	##
	# Installation
	##

	echo
	echo -n "Installing script ................................ "
<<<<<<< HEAD
	install -D -m500 "$0" "$InstDir"/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; }; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create backup directory .......................... "
	# shellcheck disable=SC2174
	mkdir -p -m 600 "$BkpDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create backup log directory ...................... "
	mkdir -p "$BkpLogDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create schedule .................................. "
	ln -s "$InstDir"/mdbkp /etc/cron.daily/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create logrotate for backup logs ................. "
	echo -e "\n$BkpLogDir/*.log {\n	daily\n	missingok\n	rotate 7\n}" > /etc/logrotate.d/mariaDBkpLogs || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create logrotate for backup files ................ "
	echo -e "\n$BkpDir/*.sql.gz {\n	daily\n	missingok\n	rotate 7\n}" > /etc/logrotate.d/mariaDBkps || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Generate backup user password .................... "
	BkpUsrPass=$(openssl rand -base64 29 | tr -d "/" | cut -c1-20); echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Export backup user password to salt file ......... "
	echo -e "\nThe mariaDB Backup User password is:	$BkpUsrPass" >> /root/salt || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create autologin into mariaDB with backup user ... "
	echo -e "[client]\nuser=mariaDBkpUsr\npassword=$BkpUsrPass" > /root/.my.cnf || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"

	echo -n "Create backup user and assign permissions ........ "
	sudo mariadb -umariadmin -p"$mDBPass" <<END || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"
=======
	install -D -m500 "$0" "$InstDir"/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; }; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create backup directory .......................... "
	# shellcheck disable=SC2174
	mkdir -p -m 600 "$BkpDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create backup log directory ...................... "
	mkdir -p "$BkpLogDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create schedule .................................. "
	ln -s "$InstDir"/mdbkp /etc/cron.daily/mdbkp || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create logrotate for backup logs ................. "
	echo -e "\n$BkpLogDir/*.log {\n	daily\n	missingok\n	rotate 7\n}" > /etc/logrotate.d/mariaDBkpLogs || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create logrotate for backup files ................ "
	echo -e "\n$BkpDir/*.sql.gz {\n	daily\n	missingok\n	rotate 7\n}" > /etc/logrotate.d/mariaDBkps || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Generate backup user password .................... "
	BkpUsrPass=$(openssl rand -base64 29 | tr -d "/" | cut -c1-20); echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Export backup user password to salt file ......... "
	echo -e "\nThe mariaDB Backup User password is:	$BkpUsrPass" >> /root/salt || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create autologin into mariaDB with backup user ... "
	echo -e "[client]\nuser=mariaDBkpUsr\npassword=$BkpUsrPass" > /root/.my.cnf || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"

	echo -n "Create backup user and assign permissions ........ "
	sudo mariadb -umariadmin -p"$mDBPass" <<END || { echo -e "\n \033[1;91m[FAILED]\033[0m"; echo; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"
>>>>>>> 115d45672bfb6133d5627ddb5400b3bf2b71e255
	GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'mariaDBkpUsr'@'localhost' IDENTIFIED BY '$BkpUsrPass';
END

	echo -n "Cleanup .......................................... "
<<<<<<< HEAD
	rm -rf "$ScriptDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; exit 1; } ; echo -e "[\033[32mOK\033[0m]\n"
=======
	rm -rf "$ScriptDir" || { echo -e "\n \033[1;91m[FAILED]\033[0m"; exit 1; } ; echo -e "[\033[32mOK!\033[0m]\n"
>>>>>>> 115d45672bfb6133d5627ddb5400b3bf2b71e255

else

	##
	# Backup variables
	##

	BkpTime=$(date +%Y.%m.%d_%H:%M) # date and time for backup file name

	NoBkpDBs=("performance_schema" "information_schema" "phpmyadmin" "sys") # List of excluded databases

	mapfile -t AllDBs < <(echo "SHOW DATABASES;" | mariadb -umariadmin -p"$mDBPass" -N) # Get a list of databases; Old Syntax was SC2034 incompatible: AllDBs=($(echo "SHOW DATABASES;" | mariadb -N))

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