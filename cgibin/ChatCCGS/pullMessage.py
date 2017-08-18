#!/usr/bin/python3
print("Content-type: application/json\n")

#pull for test user 2:
#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pullMessage.py?username=124&password=12345

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

#settings

archive = False

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password"]
inp = {'username':None,'password':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    
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
    t = (inp["username"],)

    cur.execute("SELECT * FROM Messages WHERE recipientID=?;",t)

    data = cur.fetchall()

    #Archiving

    if archive:
        ids = [(x[0],) for x in data]

        cur.executemany("INSERT INTO Archived(content,datestamp,authorID,recipientID) VALUES(?,?,?,?)",[x[1:] for x in data])
        cur.executemany("DELETE FROM Messages WHERE ID=?",ids)

    con.commit()
    
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

