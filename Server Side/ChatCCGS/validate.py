#!/usr/bin/python3
print("Content-type: text/plain\n")

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

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

if serverTools.validate(inp["username"],inp["password"]):
    print("100 Continue")
else:
    print("401 Unauthorized")
