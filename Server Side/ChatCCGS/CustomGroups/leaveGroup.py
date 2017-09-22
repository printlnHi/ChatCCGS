#!/usr/bin/python3
print("Content-type: text/plain\n")

#custom groups only

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/leaveGroup.py?username=124&password=password123&group=1

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

if CGServerTools.removeMemberFromGroup(inp["username"],inp["group"]) != "100 Continue":
    print("500 Internal Server Error")
    exit()


else:
    members = [val[0] for val in CGServerTools.getMembersOfGroup(inp["group"])]
    for member in members:
        CGServerTools.addStatusMessage(member, inp["group"], str(inp["username"])+" left the group")
        
    if len(CGServerTools.getMembersOfGroup(inp["group"])) <= 2:
            if CGServerTools.disbandGroup(inp["group"]) != "100 Continue":
               print("500 Internal Server Error")
               exit()
            else:
                print('hi')
                for member in members:
                    CGServerTools.addStatusMessage(member, inp["group"], "Group was disbanded")

print("100 Continue")

