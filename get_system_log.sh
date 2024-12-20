#!/bin/bash -
###################################################################
#Name			:Islam
#Version		:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information
#Email			:gashimov.islam@bk.ru
#Program version: For Motherboard 560
###################################################################


INFORMATION_SECTOR_SEPARATOR="###################################################################"
LOG_FILE=$(dmidecode -t 1 | grep -i product | awk {'print $5'})_"$(date '+%F')"_"$(dmidecode -t 1 | grep -i "serial" | awk {'print $3'})".log


function System_Info {
	##	The function collects data about the hardware and system
	##
	##	Global var: INFORMATION_SECTOR_SEPARATOR, LOG_FILE				Options: "$@" - utilities for collecting data about the system and hardware	
	##	Local var: cmd, search_disks=name disk/partition				Return object: No


	call_disk_subsystem=$1
	[[ "$call_disk_subsystem" == "disk_subsystem" ]] && {
		shift
		for cmd; do
			for search_disks in "$(df -h | cut -d' ' -f1 | grep -iE '/dev/nvme*|/dev/sd?')"; do
				$cmd $search_disks ; $INFORMATION_SECTOR_SEPARATOR
			done
		done
	return
	}

	for cmd; do
		$cmd
		echo "$INFORMATION_SECTOR_SEPARATOR"
	done

	unset -v "cmd" "search_disks"
} >> $LOG_FILE 2>/dev/null


printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'
System_Info "lscpu" "cpufreq-info" "inxi -F" "ip a"  "lshw" "hwinfo --cpu --usb --memory --pci --disk --network --scsi" \
				"phoronix-test-suite system-info" "phoronix-test-suite system-sensors" "sensors"
System_Info "fdisk -lx" "lspci -vvv" "lsscsi -LCv" "lsblk" "lsusb" "df -h" "free -h" "dmidecode" "dmesg -H -l alert,crit,err"
System_Info "disk_subsystem" "smartctl -a " "hdparm -IH " "hddtemp"
echo -ne "Сollection of system information	--------------------------------------------------	[ OK ] \n" 
echo -ne "Done! Look at the Log File! \n"
printf -v end '%(%H:%M:%S)T' '-1'
echo $start $end ; unset -v "start" "end"
