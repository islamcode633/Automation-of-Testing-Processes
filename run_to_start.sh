#!/bin/bash


HOME_DIR_USER="$(pwd)"
PRODUCT_NAME="$(dmidecode -t baseboard | cut -d' ' -f3-4 <(grep -i "product name"))"
SERIAL_NUMBER="$(dmidecode -t baseboard | cut -d' ' -f3 <(grep -i "serial number"))"
WORK_DIR="$HOME_DIR_USER/$PRODUCT_NAME/$SERIAL_NUMBER"


if [[ -d "$WORK_DIR" ]]; then
	rm -f "$WORK_DIR/"*
else
	mkdir -p "$WORK_DIR"
fi


if cp {fmt_data.sh,logging_data.sh} "$WORK_DIR"; then
	cd "$WORK_DIR" && bash fmt_data.sh && rm -f "$WORK_DIR/"*.sh
fi
