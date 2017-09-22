#!/usr/bin/python3
print("Content-type: application/json\n")
#FOR CUSTOM GROUPS ONLY
#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/groupLogQuery.py?username=124&password=password123&from=2010-01-05%2012:12:12&to=2018-02-01%2012:12:12

'''============ WIP ============'''

import cgi
import cgitb; cgitb.enable()
import sqlite3
import CGServerTools
import datetime

#settings

db = "../test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","from","to"]
inp = {'username':None,'password':None,'from':None,'to':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["from"] = form["from"].value
    inp["to"] = form["to"].value
    
    assert(CGServerTools.datestampIsValid(inp["from"]))
    assert(CGServerTools.datestampIsValid(inp["to"]))
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not CGServerTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

forUser = []

try:
    con = sqlite3.connect(db)
    cur = con.cursor()

    #provided inp["to"] and inp["from"] are both valid datestamps SQLite3 will work with them
    #DB accessing 
    t = (inp["username"], inp["from"], inp["to"])
    cur.execute("SELECT * FROM GroupStatusMessages WHERE recipientID=? AND datestamp BETWEEN ? AND ?",t)

    forUser = cur.fetchall()
    
except sqlite3.Error:
    print("500 Internal Server Error")
    if con:
        con.rollback()
        con.close()
    exit()
finally:
    if con:
        con.close()

data = forUser

if not data:
    print("204 No Content")
else:
    print(CGServerTools.toMultiLine(data))
