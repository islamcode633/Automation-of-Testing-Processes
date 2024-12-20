#!/bin/bash


source logging_data.sh


ALL_DEVICES_INIT=" Number of Initialized Devices"
SOME_DEVICES_NOT_INIT=" Initialization of Devices Failed"


function Check_Equality_Numbers {
	count_initialized_devices=$1
	sum_initialized_devices=$2

	if ((count_initialized_devices = sum_initialized_devices)); then
		Color_Print "$ALL_DEVICES_INIT" "$count_initialized_devices" "of $sum_initialized_devices"
	else
		Color_Print "" "$SOME_DEVICES_NOT_INIT" "$count_initialized_devices" "of $sum_initialized_devices"
	fi
}


function Color_Print {
	response="$1"
	if [[ "$response" != "" ]]; then
		printf "[ \e[32mOK\e[0m ] " && echo "$1" "$2" "$3"
		return
	fi

	error_message="$2" ; count="$3" ; amount_init="$4" ;
	printf "[ \e[31mNO\e[0m ] " && echo "$error_message" "$count" "$amount_init"
	return -1
}


function Fmt_EthInterfaces {
	eth_devices=$(ls /sys/class/net/ | grep -v lo)

	for log_name in $eth_devices; do
		mac_addr="$(ethtool -P "$log_name" | cut -d' ' -f3)"
		speed="$(ethtool "$log_name" | grep -i speed | cut -d' ' -f2)"
		Color_Print "$log_name" "$mac_addr" "$speed"
		((num_init_eth_devices+=1))
		sleep 0.3
	done

	amount_eth_devices=$(ls /sys/class/net/ | grep -v lo | wc -w)
	Check_Equality_Numbers $num_init_eth_devices $amount_eth_devices 

	unset -v "eth_devices" "logname" "mac_addr" "speed" "num_init_eth_devices" "amount_eth_devices"
}


function Fmt_MemorySlots {
	amount_mem_slots=$(inxi -m | awk '{print $6}' <(grep -i slots:))

	for ((num_init_mem_slot=1; num_init_mem_slot <= amount_mem_slots; num_init_mem_slot++)); do
		Color_Print "$(inxi -m | grep -i "device-$num_init_mem_slot:")"
		sleep 0.3
	done
	((num_init_mem_slot-=1))

	Check_Equality_Numbers $num_init_mem_slot $amount_mem_slots

	unset -v "amount_mem_slots" "num_init_mem_slot" "result"
}


function Fmt_Bios {
	Color_Print "$(dmidecode -t 0 | grep -i "bios revision")"
}


function Fmt_UsbDevices {
	# WARNING
	# Dont Output One Element
	#
	IFS=$'\n'
	num_init_usb_devices=0

	while read ; do
		Color_Print "$REPLY"
		sleep 0.3
		((num_init_usb_devices+=1))
	done < <(printf "%s" "$(lsusb | grep -iE "bus [0-9]{3} device")")

	amount_usb_devices=$(lsusb | wc -l)
	Check_Equality_Numbers $num_init_usb_devices $amount_usb_devices

	# Print Tree USB
	sleep 1
	lsusb -tv

	unset -v "num_init_devices" "amount_usb_devices"
}


function Fmt_PciDevices {
	IFS=$'\n'

	num_init_pci_devices=1
	while read ; do
		Color_Print "$REPLY"
		((num_init_pci_devices+=1))
		sleep 0.3
	done < <(printf "%s" "$(lspci)")

	amount_pci_devices=$(lspci | wc -l)
	Check_Equality_Numbers $num_init_pci_devices $amount_pci_devices 

	unset -v "num_init_pci_devices" "amount_pci_devices"
}


function Fmt_Disks {
	logname_disks_devices="$(ls /sys/class/block/ | egrep -v "sd[a-z][1-9]|nvme[0-9][a-z][1-9][a-z][1-9]|loop")"

	IFS=$'\n'
	num_init_disks_devices=1
	while read ; do
		disk_log_name="/dev/$REPLY"
		disk_model="$(fdisk -l $disk_log_name | grep -i "disk model")"
		protocol="$(smartctl -a $disk_log_name | grep -i sata | cut -d' ' -f6)"
		speed="$(smartctl -a $disk_log_name | grep -i sata | awk '{print $6}')"

		Color_Print "$disk_log_name $disk_model" "protocol: ${protocol:-Null}" "speed: ${speed:-Null}"
		((num_init_disks_devices+=1))
		sleep 0.3
	done < <(ls /sys/class/block/ | egrep -v "sd[a-z][1-9]|nvme[0-9][a-z][1-9][a-z][1-9]|loop")

	amount_disks_devices=$(ls /sys/class/block/ | egrep -v "sd[a-z][1-9]|nvme[0-9][a-z][1-9][a-z][1-9]|loop" | wc -w) 
	Check_Equality_Numbers $num_init_disks_devices $amount_disks_devices

	unset -v "num_init_disks_devices" "amount_disks_devices"
}


# ---- Formatting Data ----
###
# ----
Fmt_EthInterfaces
echo ""
Fmt_MemorySlots
echo ""
Fmt_Bios
echo ""
Fmt_UsbDevices
echo ""
Fmt_PciDevices
echo ""
Fmt_Disks


# ---- Data logging ----
### Put data the WORK_DIR ###
# ----
_getinfo_fromDMItable
_getinfo_disks
_get_HWinfo

