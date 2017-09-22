#!/usr/bin/python3
print("Content-type: application/json\n")

#non custom groups only

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/getStudentsForClass.py?username=124&password=password123&class=10EN1

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

if not serverTools.classExists(inp["class"]):
    print("602 No Group")
    exit()

if not serverTools.userIsInClass(inp["username"], inp["class"]):
    print("603 Not In Group")
    exit()

studentIDs = serverTools.getMembersOfGroup(inp["class"])

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
    print(serverTools.toMultiLine(data))

