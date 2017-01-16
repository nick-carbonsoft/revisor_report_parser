#!/bin/bash

# Author: Denisov Nick
# Date: 25.12.2016
# About: Parse pdf report.csv from "AC Revisor"

set -eu

TMPDIR=/tmp/revisor_report_parser/
prepare() {
	mkdir -p "$TMPDIR"
}

get_datetime() {
	local file="$1"
	local date_regex='[0-9]{2} [а-яА-Я]{3}, [0-9]{4}  [0-9]{2}:[0-9]{2}:[0-9]{2}'
	cut -f1-2 "$file" | iconv -f cp1251 | egrep -o "$date_regex" | sed 1d | sed '$!N;s/\n/ /'
}

get_url_and_domain_list() {
	local file="$1"
	local url_regex="http(s?):\/\/[^ \"\(\)\<\>]*"
	awk -F ";" '{print $6}' "$file" | egrep -o "$url_regex" |  cut -d ',' -f1
}

get_ip_list() {
	local file="$1"
	local ip_regex="([0-9]{1,3}\.){3}[0-9]{1,3}"
	awk -F "," '{print $6}' "$file" | egrep -o "$ip_regex"
}

get_url_redirect() {
	local file="$1"
	 awk -F ";" '{print $10}' "$file" | iconv -f cp1251 | sed 's/^С: //g' | sed -n '/Адрес перенаправления/,$p' | sed 1d
}

create_full_report() {
	local file="$1"
	local ip=$TMPDIR/ip
	local url=$TMPDIR/url
	local datetime=$TMPDIR/datetime
	local url_redirect=$TMPDIR/url_redirect

	get_datetime "$file" > $datetime
	get_url_and_domain_list "$file" > $url
	get_ip_list "$file"  > $ip
	get_url_redirect "$file" > $url_redirect
	paste $datetime $ip $url $url_redirect
	rm -f $datetime $ip $url
}

check_args() {
	if [ "$#" -lt 1 ]; then
		echo "Usage $0 <file.csv>"
		exit 1
	fi

	if [ ! -s "$1" ]; then
		echo "Empty $1"
		exit 2
	fi
}

main() {
	local csv
	check_args "$@"
	prepare
	csv="$1"
	create_full_report "$csv"
}

main "$@"
