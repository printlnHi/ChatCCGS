#!/usr/bin/python3
print("Content-type: application/json\n")

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/archiveQuery.py?username=124&password=password123&author=123&from=2015-01-05%2012:12:12&to=2015-02-01%2012:12:12

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools
import datetime

#settings

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","author","from","to"]
inp = {'username':None,'password':None,'author':None,'from':None,'to':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["author"] = int(form["author"].value)
    inp["from"] = form["from"].value
    inp["to"] = form["to"].value
    
    assert(serverTools.datestampIsValid(inp["from"]))
    assert(serverTools.datestampIsValid(inp["to"]))
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not serverTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

if not serverTools.studentExists(inp["author"]):
    print("601 Recipient Not Found")
    exit()

data = None
new = []

try:
    con = sqlite3.connect(db)
    cur = con.cursor()

    #provided inp["to"] and inp["from"] are both valid datestamps SQLite3 will work with them

    #DB accessing
    t = (inp["username"], inp["author"],inp["username"], inp["author"], inp["from"], inp["to"])

    cur.execute("SELECT * FROM Archived WHERE (recipientID=? OR recipientID=?) AND (authorID=? OR authorID=?) AND groupID IS NULL AND datestamp BETWEEN ? AND ?",t)

    data = cur.fetchall()

    t = (inp["author"],inp["username"],inp["from"],inp["to"])
    
    cur.execute("SELECT * FROM Messages WHERE recipientID=? AND authorID=? AND groupID IS NULL AND datestamp BETWEEN ? AND ?",t)

    new = cur.fetchall()
    
except sqlite3.Error:
    print("500 Internal Server Error")
    if con:
        con.rollback()
        con.close()
    exit()
finally:
    if con:
        con.close()

data = data + new

if not data:
    print("204 No Content")
else:
    print(serverTools.toMultiLine(data))

