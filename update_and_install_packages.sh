#!/bin/bash -
###################################################################
#Name			:Islam
#Version		:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information
#Email			:gashimov.islam@bk.ru
#Program version: For Motherboard 560
###################################################################


APT_SOURCE_LIST="/etc/apt/sources.list"


[[ -f $LOG_FILE ]] && rm -f $LOG_FILE


function Update_Repository {
	echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy main restricted > $APT_SOURCE_LIST && {
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates main restricted ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy universe
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates universe ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse ; echo deb http://security.ubuntu.com/ubuntu jammy-security main restricted
		echo deb http://security.ubuntu.com/ubuntu jammy-security universe ; echo deb http://security.ubuntu.com/ubuntu jammy-security multiverse
	} >> $APT_SOURCE_LIST
	apt update
}


function Install_Utils {
	##	The function updates the repositories and installs the necessary utilities
	## 	Additional hddtemp/Phoronix test suite installation
	##
	##	Global var: APT_SOURCE_LIST		Options: "$@" - utils

	##	Local var: No					Return object: No

	apt install $@ -y
	[[ ! -f hddtemp_0.3-beta15-53_amd64.deb ]] && { 
		wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hddtemp/hddtemp_0.3-beta15-53_amd64.deb
		apt install ./hddtemp_0.3-beta15-53_amd64.deb
	}

	[[ ! -d phoronix-test-suite ]] && {
		git clone https://github.com/phoronix-test-suite/phoronix-test-suite
		sh ~/phoronix-test-suite/install-sh
	}
} 2>/dev/null


function Checking_Installed_Packages {
	##	The function checks whether all necessary packages have been installed 
	##	in the required directories
	##
	##	Global var: No												Options: "$@" - downloaded packages
	##	Local var: count_packages, package,									Return object: No
	##	########## name_installed_package, path_to_binary_file


	local -i count_packages=0
	for package; do
		name_installed_package="$(dpkg -l | grep $package | awk {'print $2'})" ; path_to_binary_file="$(whereis $package | awk {'print $2'})"
		[[ "$name_installed_package" == "$package" || "$path_to_binary_file" == "/usr/bin/$package" || "$path_to_binary_file" == "/usr/sbin/$package" ]] && {
			count_packages=$(( $count_packages + 1 ))
			echo "Package installed: $package" ; continue
		}
		echo "Package not installed: $package"
	done
	echo "[SUM] of $# packages installed $count_packages" ; echo ""

	unset -v "package" "count_packages" "name_installed_package" "path_to_binary_file"
}


function main {
	printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'
	Update_Repository
	Install_Utils "lshw" "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi" "hwinfo" "hw-probe" "cpufrequtils"
	Install_Utils "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "hdparm" "smartmontools"
	Install_Utils "sysbench" "mbw"
	Checking_Installed_Packages "lshw"  "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi"  "hwinfo" "hw-probe" "cpufrequtils" "sysbench"
	Checking_Installed_Packages "hdparm" "smartmontools" "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "mbw"
	printf -v end '%(%H:%M:%S)T' '-1'
	echo $start $end ; unset -v "start" "end"
}

main
