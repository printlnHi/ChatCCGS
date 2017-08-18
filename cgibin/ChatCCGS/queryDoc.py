#!/usr/bin/python3
doc = '''
Querying format:
Base url:
http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS

Scripts:
pushMessage.py
    Query fields:
    - username
    - password
    - content (IF CONTAINS SPACE, ESCAPE WITH %20, DO NOT WRAP IN QUOTES)
    - recipient
    - datestamp (yyyy-mm-dd hh:mm:ss) eg 2017-08-10 16:26:03.143006
    Returns a status code (see below)
    
pullMessage.py
    Query fields:
    - username
    - password
    Returns an error code (see below) OR a list of all messages pulled
    If archive is enabled then the messages pulled will be removed from the new
    messages table and archived.

validate.py
    Query fields:
    - username
    - password
    Returns an error code or "100 Continue", meaning that the username and
    password match

pushGroupMessage.py
    [WIP]
    Query fields:
    - username
    - password
    - content (see pushMessage)
    - customGroup (1 or 0) [Currently only 0 accepted]
    - group (Either class code, eg. 10ASD1 OR custom group chat ID (int))
    - datestamp
    Returns a status code


Status codes:
100 Continue = script worked entirely, nothing is wrong
204 No Content = for pullMessage, no messages to pull
400 Bad Request = required query fields are missing
401 Unauthorized = bad username/password
422 Unprocessable Entity = query input is formatted incorrectly
    (eg ID cannot be cast to int, datestamp incorrectly formatted)
500 Internal Server Error = magic server error

600 Sender is Recipient = for pushMessage, the sender is the recipient specified
601 Recipient Not Found = for pushMessage, the recipient does not exist
602 No Group = for group message scripts, either the group does not exist or the group is empty



Query string example:
http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pullMessage.py?username=1022309&password=hashedPassword123


TEST USERS LOGIN:
username = 123
password = password123

username = 124
password = password123
'''

print("Content-type: text/plain\n")
print(doc)
