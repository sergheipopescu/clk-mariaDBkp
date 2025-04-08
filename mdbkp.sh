#!/bin/bash

##
# Variables
##

set -a # export all variables

InstDir=/etc/clickwork/mariaDBkp # set installation directory for the script

BkpDir=/bkp/mariaDB # backup path with trailing slash

BkpLogDir=/var/log/mariaDBkp

BkpTime=$(date +%Y.%m.%d_%H:%M) # date and time for backup file name

ScriptDir=$(pwd)	# get script directory

NoBkpDBs=("performance_schema" "information_schema" "phpmyadmin" "sys") # List of excluded databases

mDBPass=$(sudo grep -oP "mariaDB password is:\s+\K\w+" /root/salt) # get MariaDB root password

mapfile -t AllDBs < <(echo "SHOW DATABASES;" | mariadb -umariadmin -p"$mDBPass" -N) # Get a list of databases; Old Syntax was SC2034 incompatible: AllDBs=($(echo "SHOW DATABASES;" | mariadb -N))

mapfile -t BkpDBs < <(echo "${AllDBs[@]}" "${NoBkpDBs[@]}" | tr ' ' '\n' | sort | uniq -u) # extract the list of DBs to backup


##
# Install script if it's not present
##

if ! test -f "$InstDir"/mdbkp; then # if script doesn't exist

	install -D -m500 "$0" "$InstDir"/mdbkp # install script (create folder path, copy the script file, set permissions on the copied file)

	# shellcheck disable=SC2174
	mkdir -p -m 600 "$BkpDir"	# create backup directory with path
	mkdir -p "$BkpLogDir"	# create backup log directory

	ln -s "$InstDir"/mdbkp /etc/cron.daily/mdbkp	# create link to cron folder for scheduling

	echo -e "\n$BkpLogDir/*.log {\n	daily\n	missingok\n	rotate 7\n}" | sudo tee /etc/logrotate.d/mariaDBkpLogs >/dev/null	# Create log logrotate conf
	echo -e "\n$BkpDir/*.sql.gz {\n	daily\n	missingok\n	rotate 7\n}" | sudo tee /etc/logrotate.d/mariaDBkps >/dev/null	# Create backup logrotate conf

	BkpUsrPass=$(openssl rand -base64 29 | tr -d "/" | cut -c1-20)	# generate password for the backup user
	echo "The mariaDB Backup User password is:	$BkpUsrPass" | sudo tee --append /root/salt >/dev/null	# write the backup user password into salt file

	echo -e "[client]\nuser=mariaDBkpUsr\npassword=$BkpUsrPass" | sudo tee /root/.my.cnf >/dev/null	# create autologin into mariaDB with Backup User creds

	sudo mariadb -umariadmin -p"$mDBPass" <<END
	GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'mariaDBkpUsr'@'localhost' IDENTIFIED BY '$BkpUsrPass';
END

	rmdir -r "$ScriptDir"	# cleanup

else

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