#!/bin/bash

# Author: Denisov Nick
# Date: 25.12.2016
# About: Parse pdf report from "AC Revisor"
# Install packets
# yum install poppler-utils


create_full_report() {
	local file="$1"
	
	file_suffix="$(echo "$file" | cut -d "." -f1)"
	txt_file="$(find . -name "$file_suffix.txt")"
	
	# Get datetime 
	cat "$txt_file" | egrep -o '[0-9]{2} [а-яА-Я]{3}, [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed 1d | sed '$!N;s/\n/ /' > /tmp/datetime
	# Get URL/domain list
	cat "$txt_file" | grep -v "С: *" | tr -d '\r\n'| grep -Eo "http(s?):\/\/[^ \"\(\)\<\>]*," |  cut -d ',' -f1 > /tmp/url
	# Get IP list
	cat "$txt_file" | sed '/^$/d' | tr -d '\r\n' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > /tmp/ip
	rm -f "$txt_file"
}

main() {
	local pdf_file="$1"
	if [ $# -lt 1 ]; then
		echo "Usage $(basename $0) <file.pdf>"
		exit 65
	fi

	if [ -s "$pdf_file" ]; then
		pdftotext -raw "$pdf_file"
		create_full_report "$pdf_file"
	    	# Merge all columns and show stdout	
		paste /tmp/datetime /tmp/ip /tmp/url
	fi
}

main "$@"
