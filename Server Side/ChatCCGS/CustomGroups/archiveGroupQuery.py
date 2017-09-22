#!/usr/bin/python3
print("Content-type: application/json\n")
#FOR CUSTOM GROUPS ONLY
#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/archiveGroupQuery.py?username=120&password=password123&groupID=10EN1&from=2010-01-05%2012:12:12&to=2018-02-01%2012:12:12

import cgi
import cgitb; cgitb.enable()
import sqlite3
import CGServerTools
import datetime

#settings

db = "../test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","groupID","from","to"]
inp = {'username':None,'password':None,'groupID':None,'from':None,'to':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["groupID"] = int(form["groupID"].value)
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

if not CGServerTools.groupExists(inp["groupID"]):
    print("602 No Group")
    exit()


if not CGServerTools.userIsInGroup(inp["username"], inp["groupID"]):
    print("603 Not In Group")
    exit()

forUser = []
fromUser = []
fromUserNonPulled = []

try:
    con = sqlite3.connect(db)
    cur = con.cursor()

    #provided inp["to"] and inp["from"] are both valid datestamps SQLite3 will work with them
    #DB accessing 
    t = (inp["username"], inp["groupID"], inp["from"], inp["to"])
    cur.execute("SELECT * FROM Archived WHERE recipientID=? AND groupID=? AND customGroup=1 AND datestamp BETWEEN ? AND ?",t)

    forUser = cur.fetchall()
    t = (inp["username"], inp["groupID"], inp["from"], inp["to"])
    cur.execute("SELECT * FROM Archived WHERE authorID=? AND groupID=? AND customGroup=1 AND datestamp BETWEEN ? AND ?",t)
    fromUser = cur.fetchall()
    t = (inp["username"], inp["groupID"], inp["from"], inp["to"])
    cur.execute("SELECT * FROM Messages WHERE authorID=? AND groupID=? AND customGroup=1 AND datestamp BETWEEN ? AND ?",t)
    fromUserNonPulled = cur.fetchall()
    
except sqlite3.Error:
    print("500 Internal Server Error")
    if con:
        con.rollback()
        con.close()
    exit()
finally:
    if con:
        con.close()

data = forUser + CGServerTools.removeDuplicates(fromUser + fromUserNonPulled)

if not data:
    print("204 No Content")
else:
    print(CGServerTools.toMultiLine(data))
