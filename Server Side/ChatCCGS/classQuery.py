#!/usr/bin/python3
print("Content-type: application/json\n")

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/classQuery.py?username=124&password=password123&class=%

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

#settings

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","class"]
inp = {'username':None,'password':None,'class':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["class"] = form["class"].value 
    
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

    #DB accessing
    t = (inp["class"],)

    cur.execute("SELECT * FROM Classes WHERE ID LIKE ?;",t)

    data = cur.fetchall()

    cur.execute('SELECT classID FROM Enrolments WHERE studentID = ?', (inp['username'],))
    data2 = cur.fetchall()

    data = [val for val in data if val in data2]
    
except sqlite3.Error:
    print("500 Internal Server Error")
    if con:
        con.rollback()
        con.close()
    exit()
finally:
    if con:
        con.close()

if not data:
    print("204 No Content")
else:
    print(data)

