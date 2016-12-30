#!/bin/bash

# Установить пакеты
#platform="$(uname -a | grep -o Ubuntu)"
#if [ "$platform" == "Ubuntu"]; then
#	apt-get install poppler-utils pdftk
#fi


create_pdf() {
	# Разбить PDF на страницы
        local INPUT="$1"
	pdftk "$INPUT" burst
}

create_txt() {
	# Передать все страницы для преобразовнания в текст
	local list_pdf
	list_pdf="$(find . -name "pg_*.pdf" | sort)"
	for pdf in pdf_list; do
		pdftotext -raw "$pdf"
	done
}

create_full_report() {
	local txt_file
	txt_file="$(find . -name "pg_*.txt" | sort)"
	for txt in txt_file; do
		if [ "$txt" == "pg_001.txt" ]; then
			# Для первой страницы, так как там дата получения отчета
			cat "$txt" | egrep -o '[0-9]{2} [а-яА-Я]{3}, [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed 1d | sed '$!N;s/\n/ /' > /tmp/datetime
		else
			cat "$txt" | egrep -o '[0-9]{2} [а-яА-Я]{3}, [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed '$!N;s/\n/ /' > /tmp/datetime
		fi
		# Получаем список URL/доменов
		cat "$txt" | grep -v "С: *" | tr -d '\r\n'| grep -Eo "http(s?):\/\/[^ \"\(\)\<\>]*," |  cut -d ',' -f1 > /tmp/url
		# cat "$INPUT" | tr -d '\r\n' | grep -v "С: http(s?):\/\/[^ \"\(\)\<\>]*," | grep -Eo "http(s?):\/\/[^ \"\(\)\<\>]*," |  cut -d ',' -f1 > /tmp/url
		# Получение списка IP
		cat "$txt" | sed '/^$/d' | tr -d '\r\n' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > /tmp/ip
	done
}

# Объединяем все файлы построчно

paste /tmp/datetime /tmp/ip /tmp/url
