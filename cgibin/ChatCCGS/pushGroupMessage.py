#!/usr/bin/python3
print("Content-type: text/plain\n")

#http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pushGroupMessage.py?username=123&password=12345&content=hello&datestamp=2017-08-14%2013:36:22&customGroup=0&group=10ASD1

import cgi
import cgitb; cgitb.enable()
import sqlite3
import serverTools

#settings

validateDatestamps = True

db = "test.db"

#code

form = cgi.FieldStorage()

requiredFields = ["username","password","content","group","datestamp","customGroup"]
inp = {'username':None,'password':None,'content':None,'group':None,'datestamp':None,'customGroup':None}


if not all([x in form for x in requiredFields]):
    print("400 Bad Request")
    exit()

try:
    inp["username"] = int(form["username"].value)
    inp["content"] = form["content"].value
    inp["password"] = form["password"].value
    inp["datestamp"] = form["datestamp"].value
    inp["customGroup"] = int(form["customGroup"].value)

    assert(inp["customGroup"] == 0 or inp["customGroup"] == 1)

    if inp["customGroup"] == 0:
        inp["group"] = form["group"].value
    else:
        #TEMP
        assert(False)

    if validateDatestamps:
        assert(serverTools.datestampIsValid(inp["datestamp"]))
    
except:
    print("422 Unprocessable Entity")
    exit()

#Validate user

if not serverTools.validate(inp["username"],inp["password"]):
    print("401 Unauthorized")
    exit()

#print(serverTools.pushGroupMessage(inp))
