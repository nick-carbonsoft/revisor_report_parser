#!/usr/bin/python3

import csv

with open('/home/nick/Рабочий стол/report.csv', encoding="cp1251") as report:
    table = csv.reader(report, delimiter=';', quotechar='"')
    for row in table:
        print(row)
