#!/usr/bin/python3
print("Content-type: application/json\n")

#non custom groups only

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/getStudentsForGroup.py?username=124&password=password123&group=1

import cgi
import cgitb; cgitb.enable()
import sqlite3
import CGServerTools

#settings

db = "../test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","group"]
inp = {'username':None,'password':None,'group':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["group"] = int(form["group"].value)
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not CGServerTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

if not CGServerTools.groupExists(inp["group"]):
    print("602 No Group")
    exit()

if not CGServerTools.userIsInGroup(inp["username"], inp["group"]):
    print("603 Not In Group")
    exit()

studentIDs = CGServerTools.getMembersOfGroup(inp["group"])

data = []

try:
    con = sqlite3.connect(db)
    cur = con.cursor()

    #DB accessing
    for i in range(len(studentIDs)):
        cur.execute("SELECT ID,name FROM Students WHERE ID=?;",studentIDs[i])
        data.append(cur.fetchone())
    
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
    print(CGServerTools.toMultiLine(data))

