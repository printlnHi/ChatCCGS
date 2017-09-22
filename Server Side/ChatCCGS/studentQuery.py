#!/usr/bin/python3
print("Content-type: application/json\n")

#pull for test user 2:
#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/studentQuery.py?username=124&password=password123&name=%&studentID=%

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

#settings

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","query"]
inp = {'username':None,'password':None,'query':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["query"] = form["query"].value 
    
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
    t = (inp["query"], inp["query"])

    cur.execute("SELECT ID, name FROM Students WHERE name LIKE ? OR ID LIKE ?;",t)

    data = cur.fetchall()
    
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
    print(serverTools.toMultiLine(data))

