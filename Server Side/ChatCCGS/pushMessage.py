#!/usr/bin/python3
print("Content-type: text/plain\n")

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pushMessage.py?username=1&password=1&content=1&datestamp=1&recipient=1

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pushMessage.py?username=123&password=12345&content=hello&datestamp=2017-08-14%2013:36:22&recipient=124

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

#settings

validateDatestamps = True

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","content","recipient","datestamp"]
inp = {'username':None,'password':None,'content':None,'recipient':None,'datestamp':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["recipient"] = int(form["recipient"].value)
    inp["content"] = form["content"].value
    inp["password"] = form["password"].value
    inp["datestamp"] = form["datestamp"].value

    inp["groupID"] = None
    inp["customGroup"] = None

    if validateDatestamps:
        assert(serverTools.datestampIsValid(inp["datestamp"]))
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not serverTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

print(serverTools.pushMessage(inp))
