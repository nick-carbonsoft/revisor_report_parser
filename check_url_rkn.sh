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
	cut -f1-2 "$file" | iconv -f cp1251 | egrep -o "$date_regex" | sed 1d | sed 's/  / /g' | sed '$!N;s/\n/  /' || return 0
}

get_url_and_domain_list() {
	local file="$1"
	local url_regex="http(s?):\/\/[^ \"\(\)\<\>]*"
	awk -F ";" '{print $6}' "$file" | egrep -o "$url_regex" |  cut -d ',' -f1 || return 0
}

get_ip_list() {
	local file="$1"
	local ip_regex="([0-9]{1,3}\.){3}[0-9]{1,3}"
	awk -F "," '{print $7}' "$file" | egrep -o "$ip_regex" || return 0
}

get_url_redirect() {
	local file="$1"
	awk -F ";" '{print $10}' "$file" | iconv -f cp1251 | sed 's/^С: //g' | sed -n '/Адрес перенаправления/,$p' | sed 1d | cut -d ' ' -f1 || return 0
}

get_ip_redirect() {
	local file="$1"
	awk -F ";" '{print $10}' "$file" | iconv -f cp1251 | sed 's/^С: //g' | sed -n '/Адрес перенаправления/,$p' | sed 1d | cut -d ' ' -f2 | tr -d '()' || return 0
}

get_records_id() {
    local file="$1"
    local id_regexp=''
    awk -F ";" '{print $5}' "$file" | iconv -f cp1251 | grep [0-9]
}

replace_redirect() {
	local file1="$1"
	local file2="$2"
	local output="$TMPDIR/output"
	for file in $file{1,2}; do
		cat -n "$file" > "$file.enum"
	done
	join $file{1,2}.enum > "$output"
	while read _ original replacement; do
		[ -n "$replacement" ] && echo "$replacement" || echo "$original"
	done < "$output"
	rm -f $output $file{1,2}.enum
}


create_full_report() {
	local file="$1"
	local ip="$TMPDIR/ip"
	local url="$TMPDIR/url"
	local datetime="$TMPDIR/datetime"
	local url_redirect="$TMPDIR/url_redirect"
    local ip_redirect="$TMPDIR/ip_redirect"
	local all_url="$TMPDIR/all_url"
    local all_ip="$TMPDIR/all_ip"
    local records_id="$TMPDIR/id"
	get_datetime "$file" > $datetime
	get_url_and_domain_list "$file" > $url
	get_ip_list "$file"  > $ip
	get_url_redirect "$file" > "$url_redirect"
    get_ip_redirect "$file" > "$ip_redirect"
    get_records_id "$file" > "$records_id"
	replace_redirect "$url" "$url_redirect" > "$all_url"
    replace_redirect "$ip" "$ip_redirect" > "$all_ip"

	if [[ -s "$ip" ]]; then
		paste "$datetime" "$records_id" "$all_ip" "$all_url"
		rm -f "$datetime" "$records_id" "$all_ip" "$url" "$url_redirect" "$all_url"
	else
		paste "$datetime" "$records_id" "$all_url"
		rm -f "$datetime" "$records_id" "$url" "$url_redirect" "$all_url"

	fi
}

check_args() {
	local extension=${1##*.}
	if [ "$#" -lt 1 ]; then
		echo "Usage $0 <file.csv>"
		exit 1
	fi

	if [ ! -s "$1" ]; then
		echo "Empty $1"
		exit 2
	fi
	if [ $extension != "csv" ]; then
		echo "Only <file.csv> format, we use $1"
		exit 3
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
