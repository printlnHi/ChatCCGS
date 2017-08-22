#!/usr/bin/python
print('Content-type: text/plain\n')

import sqlite3

conn = sqlite3.connect('test.db')

data = conn.execute('SELECT ID, Name FROM Students')

sending = {}

for d in data:
    print(str(d[0]) + ':' + str(d[1]))

conn.close()
