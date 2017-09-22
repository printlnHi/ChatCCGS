#!/usr/bin/python3
print("Content-type: text/plain\n")

#custom groups only

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/addToGroup.py?username=124&password=password123&group=1&members=[123,125,126]

import cgi
import cgitb; cgitb.enable()
import sqlite3
import CGServerTools

#settings

db = "../test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","group","members"]
inp = {'username':None,'password':None,'group':None,'members':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["password"] = form["password"].value
    inp["group"] = int(form["group"].value)
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

if not CGServerTools.groupExists(inp["group"]):
    print("602 No Group")
    exit()

if not CGServerTools.userIsInGroup(inp["username"], inp["group"]):
    print("603 Not In Group")
    exit()

tmp = set(inp["members"])
tmp.add(inp["username"])
if len(tmp) <= 1:
    print("604 Not Enough Members")
    exit()

if not CGServerTools.studentsExist(inp["members"]):
    print("601 Recipient Not Found")
    exit()

alreadyIn = CGServerTools.getMembersOfGroup(inp["group"])
if len([val for val in inp["members"] if (val,) in alreadyIn]) != 0:
    print("605 User Already in Group")
    exit()

if CGServerTools.addToCustomGroup(inp["group"],inp["members"]) == "100 Continue":
    for member in (inp["members"] + [val[0] for val in alreadyIn]):
        for added in inp["members"]:
            CGServerTools.addStatusMessage(member, inp["group"], str(added)+" was added to the group")
    print("100 Continue")
else:
    print("500 Internal Server Error")

