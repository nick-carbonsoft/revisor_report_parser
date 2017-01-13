#!/bin/bash

# Author: Denisov Nick
# Date: 25.12.2016
# About: Parse pdf report from "AC Revisor"
# Install packets
# yum install poppler-utils

set -eu

TMPDIR=/tmp/revisor_report_parser/

prepare() {
	mkdir -p "$TMPDIR"
}

get_datetime() {
	local file="$1"
	local date_regex='[0-9]{2} [а-яА-Я]{3}, [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}'
	egrep -o "$date_regex" "$file" | sed 1d | sed '$!N;s/\n/ /'
}

get_url_and_domain_list() {
	local file="$1"
	local url_regex="http(s?):\/\/[^ \"\(\)\<\>]*,"
	grep -v "С: *" "$file" | tr -d '\r\n'| egrep -o "$url_regex" |  cut -d ',' -f1
}

get_ip_list() {
	local file="$1"
	local ip_regex="([0-9]{1,3}\.){3}[0-9]{1,3}"
	sed '/^$/d' "$file" | tr -d '\r\n' | egrep -o "$ip_regex"
}

create_full_report() {
	local file="$1"
	local ip=$TMPDIR/ip
	local url=$TMPDIR/url
	local datetime=$TMPDIR/datetime

	get_datetime "$file" > $datetime
	get_url_and_domain_list "$file" > $url
	get_ip_list "$file" > $ip
	paste $datetime $ip $url
	rm -f $datetime $ip $url
}

check_args() {
	if [ "$#" -lt 1 ]; then
		echo "Usage $0 <file.pdf>"
		exit 1
	fi

	if [ ! -s "$1" ]; then
		echo "Empty $1"
		exit 2
	fi
}

main() {
	local pdf="$1"
	local txt="${pdf/.pdf/.txt}"
	check_args "$@"
	prepare
	pdftotext -raw "$pdf" "$txt"
	create_full_report "$txt"
}

main "$@"
