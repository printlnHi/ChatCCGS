#!/usr/bin/python3
print("Content-type: application/json\n")

import cgi
import cgitb; cgitb.enable()

form = cgi.FieldStorage()

print("<html>\
         <body>\
         <p>test</p>")

if "user" not in form:
    output = "User not in form"
else:
    output = str(form["user"].value)

print("<p>"+output+"</p>\
         </body>\
         </html>\
      ")
