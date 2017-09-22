#!/usr/bin/python3
print("Content-type: application/json\n")

#custom groups only

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/createGroup.py?username=124&password=password123&name=test1&members=[123,125,126]

import cgi
import cgitb; cgitb.enable()
import sqlite3
import CGServerTools

#settings

db = "../test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","name","members"]
inp = {'username':None,'password':None,'name':None,'members':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["name"] = form["name"].value
    inp["members"] = eval(form["members"].value)
    
    assert(type(inp["members"])==list)
    inp["members"] = list(set(inp["members"]))
    for member in inp["members"]:
        assert(type(member) == int)
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not CGServerTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

tmp = set(inp["members"])
tmp.add(inp["username"])
if len(tmp) <= 2:
    print("604 Not Enough Members")
    exit()

if not CGServerTools.studentsExist(inp["members"]):
    print("601 Recipient Not Found")
    exit()
    
out = CGServerTools.createCustomGroup(inp["username"],inp["name"],inp["members"])
if out != "500 Internal Server Error":
    for member in list(set(inp["members"] + [inp["username"]])):
        CGServerTools.addStatusMessage(member, out, "Group \"" + inp["name"] + "\" created")
    print("100 Continue")
else:
    print("500 Internal Server Error")

