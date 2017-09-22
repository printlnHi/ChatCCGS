#!/usr/bin/python3
doc = '''
Querying format:
Base url:
http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS

sqlite3 wildcards:
% = 0 to infinite of any characters
_ = 1 of any character

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

    Returns formatted messages (one message per line):
(ID, content, datestamp, authorID, recipientID, group, customGroup)
...

validate.py
    Query fields:
    - username
    - password
    Returns an error code or "100 Continue", meaning that the username and
    password match

pushGroupMessage.py
    [NON CUSTOM GROUPS ONLY]
    Query fields:
    - username
    - password
    - content (see pushMessage)
    - group (Either class code, eg. 10ASD1 OR custom group chat ID (int), if custom group ID customGroup should be 1)
    - datestamp
    Returns a status code

studentQuery.py
    Query fields:
    - username
    - password
    - query

    DB is queried with statement:
    "SELECT ID, name FROM Students WHERE name LIKE query OR ID LIKE query;"
    This means you can use wildcards to search (%)

classQuery.py
    [NON CUSTOM GROUPS ONLY]
    Query fields:
    - username
    - password
    - class

    class is of the same nature as query in studentQuery.py
    Can use wildcards (% and _)

getClassesForStudent.py
    [NON CUSTOM GROUPS ONLY]
    Query fields:
    - username
    - password
    - ID = studentID for which to get classes for

    Returns multi line formatted classes:

    sample output for student 124:
10GY1
10CE2
10HY3
10GP1

getStudentsForClass.py
    [NON CUSTOM GROUPS ONLY]
    Query fields:
    - username
    - password
    - class
    sample output for class 10GY1:


archiveQuery.py
    Used to fetch old records for a conversation
    Query fields:
    - username
    - password
    - author = author of messages to query
    - from = starting datestamp
    - to = ending datestamp (MUST BE AFTER 'from')

    to and from must be valid datestamps (see above)

archiveGroupQuery.py
    [NON CUSTOM GROUPS ONLY]
    Query fields:
    - username
    - password
    - groupID
    - from
    - to

======= CUSTOM GROUP SCRIPTS ========
/CustomGroups/createGroup.py
    Query fields:
    - username
    - password
    - name = custom group name
    - members = array of member IDs (eg &members=[123,124,145] )

/CustomGroups/pushGroupMessage.py
    Query fields:
    - username
    - password
    - content = message content
    - group = custom group ID
    - datestamp

/CustomGroups/getStudentsForGroup.py
    Query fields:
    - username
    - password
    - group = custom group ID

/CustomGroups/addToGroup.py
[WIP] - do not use
    Query fields:
    - username
    - password
    - group = custom group ID
    - members = array of student IDs to add (see createGroup.py)

/CustomGroups/getGroupsForStudent.py
    Query fields:
    - username
    - password
    outputs list of groupIDs user is a part of: eg
(3,)
(4,)

/CustomGroups/leaveGroup.py
    Query fields:
    - username
    - password
    - group

    Removes user from specified group. If group is left with only 2
    or less members the group is removed

/CustomGroups/archiveGroupQuery.py
    Query fields:
    - username
    - password
    - groupID
    - from
    - to


Status codes:
100 Continue = script worked entirely, nothing is wrong
204 No Content = for pullMessage, no messages to pull
400 Bad Request = required query fields are missing
401 Unauthorized = bad username/password
422 Unprocessable Entity = query input is formatted incorrectly
    (eg ID cannot be cast to int, datestamp incorrectly formatted)
500 Internal Server Error = magic server error

600 Sender is Recipient = for pushMessage, the sender is the recipient specified
601 Recipient Not Found = for scripts requiring a recipient(s), the recipient is not an existing ID
602 No Group = for group message scripts, either the group does not exist or the group is empty
603 Not In Group = for group message scripts, the user is not in the group specified
604 Not Enough Members = for createGroup.py, if you haven't given enough members to create a group (3 or more)
605 User Already in Group = for adding people to groups, the user being added is already in the group


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
