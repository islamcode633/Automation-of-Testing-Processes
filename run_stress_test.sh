#!/bin/bash -
###################################################################
#Name			:Islam
#Version		:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information
#Email			:gashimov.islam@bk.ru
#Program version: For Motherboard 560
###################################################################


function Stress_Test {
	##	The function conducts load tests of all system components
	##	CPU/Memory/Disk/Bus/Network/IO
	##
	##	Global var: No													Options: No
	##	Local var:	size_ram=All RAM, half_usage_ram=50% of RAM,		Return object: No
	##	##########	load=thread/system calls, time=sec


	local -i load=50 ; local -i time=60

	ping -c 10 ya.ru
	mbw -n 10 2000
	sysbench cpu --threads=100 --time=$time run
	sysbench memory --memory-block-size=16384 --time=$time run
	sysbench fileio --file-num=512 --file-block-size=65536 --file-test-mode=seqwr --time=$time run

	script -c "stress-ng -c 0 -m 0 -d 0 -i 0 -f $load -u $load --pci $load --memcpy $load --mcontend $load --matrix $load --malloc $load --kvm $load --hash $load \
	-C 0 -B 0 -t 5m --tz --metrics-brief -v"

	find . -maxdepth 1 -iname "test_file.*" -or -iname "tmp-stress-ng*" | xargs rm -rf
	unset -v "load" "time"
} > result_stress_test.log

printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'
Stress_Test
printf -v end '%(%H:%M:%S)T' '-1'
echo $start $end ; unset -v "start" "end"
