#!/bin/bash


function _getinfo_fromDMItable {
	dmidecode > dmidecode.txt 
	dmidecode -t 2 > serial.txt
	dmidecode | grep -i "bios revision" >> serial.txt
	dmidecode -t 16 -t 17 > memory.txt
}


function _getinfo_disks {
	fdisk -x > disks.txt

	for logic_name_disk in "$(ls /sys/block/ | grep -v loop*)"; do
		hddtemp /dev/$logic_name_disk | grep -v "not" > temp_disks.txt
		smartctl -a /dev/$logic_name_disk | egrep -i "device model|serial" > serial_disks.txt
	done 2>/dev/null
}


function _getinfo_IPMI {
	#ipmitool sdr or impitool sensor or impitool sdr sensor
	#ipmitool get mac
	#ipmitool get version BMC
	:
}


function _get_HWinfo {
	lshw > hardware_info.txt
	lsusb -v > usb.txt
	lspci -vvv > pci.txt

	for eth_interface in $(ls /sys/class/net/ | grep -v "lo"); do
		printf "$eth_interface -> $(ethtool -P $eth_interface | awk '{print $3}')\n"
	done > eth_mac.txt

	sensors > sensors.txt 
}
