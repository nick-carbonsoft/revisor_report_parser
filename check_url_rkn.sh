#!/bin/bash

# Установить пакеты
#platform="$(uname -a | grep -o Ubuntu)"
#if [ "$platform" == "Ubuntu"]; then
#       apt-get install poppler-utils pdftk
#fi


create_full_report() {
        local txt_file
        txt_file="$(find . -name "*.txt")"
        cat "$txt_file" | egrep -o '[0-9]{2} [а-яА-Я]{3}, [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' | sed 1d | sed '$!N;s/\n/ /' > /tmp/datetime
        # Получаем список URL/доменов
        cat "$txt_file" | grep -v "С: *" | tr -d '\r\n'| grep -Eo "http(s?):\/\/[^ \"\(\)\<\>]*," |  cut -d ',' -f1 > /tmp/url
        # cat "$INPUT" | tr -d '\r\n' | grep -v "С: http(s?):\/\/[^ \"\(\)\<\>]*," | grep -Eo "http(s?):\/\/[^ \"\(\)\<\>]*," |  cut -d ',' -f1 > /tmp/url
        # Получение списка IP
        cat "$txt_file" | sed '/^$/d' | tr -d '\r\n' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > /tmp/ip
        rm -f "$txt_file"
}

main() {
        local pdf_file="$1"
        if [ $# -lt 1 ]; then
                echo "Порядок использования $(basename $0) <file.pdf>"
                exit 65
        fi

        if [ -s "$pdf_file" ]; then
                pdftotext -raw "$pdf_file"
                create_full_report
                paste /tmp/datetime /tmp/ip /tmp/url
        fi
}

main "$@"
