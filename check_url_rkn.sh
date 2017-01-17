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
	cut -f1-2 "$file" | iconv -f cp1251 | egrep -o "$date_regex" | sed 1d | sed '$!N;s/\n/ /' || break
}

get_url_and_domain_list() {
	local file="$1"
	local url_regex="http(s?):\/\/[^ \"\(\)\<\>]*"
	awk -F ";" '{print $6}' "$file" | egrep -o "$url_regex" |  cut -d ',' -f1 || break
}

get_ip_list() {
	local file="$1"
	local ip_regex="([0-9]{1,3}\.){3}[0-9]{1,3}"
	awk -F "," '{print $6}' "$file" | egrep -o "$ip_regex" || break
}

get_url_redirect() {
	local file="$1"
	awk -F ";" '{print $10}' "$file" | iconv -f cp1251 | sed 's/^С: //g' | sed -n '/Адрес перенаправления/,$p' | sed 1d || break
}

replace_url_redirect() {
	local file1="$1"
	local file2="$2"
	local output="$TMPDIR/output"
	[[ -s $file{1,2} ]] || break
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
	local all_url="$TMPDIR/all_url"
	get_datetime "$file" > $datetime
	get_url_and_domain_list "$file" > $url
	get_ip_list "$file"  > $ip
	get_url_redirect "$file" > "$url_redirect"
	replace_url_redirect "$url" "$url_redirect" > "$all_url"
	if [[ -s "$ip" ]]; then
		paste "$datetime" "$ip" "$all_url"
		rm -f "$datetime" "$ip" "$url" "$url_redirect" "$all_url"
	fi
	paste "$datetime" "$all_url"
	rm -f "$datetime" "$url" "$url_redirect" "$all_url"
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
