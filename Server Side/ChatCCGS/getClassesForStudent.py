#!/usr/bin/python
print('Content-type: text/json\n')

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/getClassesForStudent.py?username=124&password=password123&ID=124

import sqlite3
import cgi
import serverTools

db = "test.db"


form = cgi.FieldStorage()

requiredFields = ["username","password","ID"]
inp = {'username':None,"password":None,"ID":None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["ID"] = int(form["ID"].value)
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not serverTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

data = None

try:
    con = sqlite3.connect(db)
    cur = con.cursor()
    cur.execute('SELECT classID FROM Enrolments WHERE studentID = ?', (inp['username'],))
    data = cur.fetchall()
except:
    print("500 Internal Server Error")
    if con:
        con.rollback()
    exit()
finally:
    if con:
        con.close()
for t in data:
    print(t[0])
