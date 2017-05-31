#!/usr/bin/python3

NORMAL = ['30 Апр, 2017  03:22:20', 'ЮФО_Б_З_00_Дарья', '347803, Ростовская область, г. Каменск-Шахтинский, ул. Школьная, д. 18', 'Широта 48°18', '421631', 'https://ligastavok20.com/, 62.138.231.137, GET', 'ФНС', '15 Янв, 2017  17:33:31', '200', 'С: http://ligastavok15.com (46.163.88.13) ']
BAD = ['30 Апр, 2017  03:22:20', 'ЮФО_Б_З_00_Дарья', '347803, Ростовская область, г. Каменск-Шахтинский, ул. Школьная, д. 18', 'Широта 48°18', '413098', 'http://vkontakte.ru/videosl14747674?q=pyccKHH&amp', 'section=search&amp', 'z=video114747674_169177344, 104.31.74.77, GET', 'ФНС', '12 Янв, 2017  19:27:38', '200', 'С: http://iknd.info/internet-kazino-azartplay.html (109.234.32.226) ']

print(len(NORMAL))
print(len(BAD))


class Entry(object):
    date = None
    user = None
    place = None
    geo = None
    number = None
    link_end = None
    blocked_by = None
    blocked_when = None
    http_code = None
    link_from = None

    def magic(self, csv_row_ambiguous):
        for n, v in enumerate(csv_row_ambiguous):
            if v.endswith('GET'):
                break
        self.link_end = "".join(csv_row_ambiguous[:n + 1])
        if len(csv_row_ambiguous[n + 1:]) == 4:
            self.blocked_by, self.blocked_when, self.http_code, self.link_from = csv_row_ambiguous[n + 1:]
        else:
            raise ValueError(csv_row_ambiguous[n + 1:])

    def from_to_analyze(self):
        pass

    def __init__(self, csv_row):
        self.date, self.user, self.place, self.geo, self.number = csv_row[0:5]
        if len(csv_row) == 10:
            self.link_end, self.blocked_by, self.blocked_when, self.http_code, self.link_from = csv_row[5:]
        else:
            self.magic(csv_row[5:])
        self.from_to_analyze()

    def __repr__(self):
        return "<Entry(date={} number={} link_end={}  " \
               "http_code={} link_from={})>".format(
                self.date,
                self.number,
                self.link_end,
                self.http_code,
                self.link_from
                )

print(Entry(NORMAL))
print(Entry(BAD))
